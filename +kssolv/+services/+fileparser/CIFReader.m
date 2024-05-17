classdef CIFReader < handle
    % CIFREADER 用于读取和解析 .cif 文件的类

    %   开发者：付礼中 杨柳
    %   版权 2024 合肥瀚海量子科技有限公司

    properties
        filePath                   % CIF 文件路径
        KSSOLVSetupObject struct   % 包含 KSSOLV 构建分子/晶体结构所需要的数据
        rawFileContent    string   % CIF 文件原始内容
    end

    properties (Hidden)
        fileContent                % CIF 文件内容
        CIFObject         struct   % 从 CIF 文件中解析出的数据结构
    end

    properties (Access = private)
        currentLineIndex           % 当前处理的行的索引
    end
    
    methods
        function this = CIFReader(filePath)
            % 构造函数，初始化读取和解析 .cif 文件
            this.filePath = filePath;
            this.KSSOLVSetupObject = struct();
            this.readFile();
            try
                this.extractData();
            catch ME
                error('KSSOLV:FileParser:CIFReader:ParseFileError', ...
                    'Error extracting data from %s: %s', this.filePath, ME.message);
            end
            this.buildKSSOLVSetupObject();
        end

        function readFile(this)
            % 读取文件内容
            fid = fopen(this.filePath, 'r');
            if fid == -1
                error('KSSOLV:FileParser:CIFReader:OpenFileError', 'Cannot open this CIF file: %s', this.filePath);
            end
            fileRawContent = textscan(fid, '%s', 'Delimiter', '\n', 'Whitespace', '');
            fclose(fid);
            this.fileContent = fileRawContent{1};
            this.rawFileContent = fileread(this.filePath);
        end
    end

    methods (Access = private)
        function extractData(this)
            % 从文件内容中提取数据
            this.CIFObject = struct();
            this.currentLineIndex = 1;
            totalLines = length(this.fileContent);
            
            while this.currentLineIndex <= totalLines
                line = this.fileContent{this.currentLineIndex};
                if startsWith(line, 'data_')
                    this.extractName(line);
                elseif startsWith(line, '_')
                    this.processEntry(line);
                elseif startsWith(line, 'loop_')
                    this.processLoop();
                end
                this.currentLineIndex = this.currentLineIndex + 1;
            end
        end
        
        function extractName(this, line)
            % 提取数据名称
            dataLine = regexp(line, 'data_\S*', 'match');
            this.CIFObject.name = dataLine{1}(6:end);
        end
        
        function processEntry(this, line)
            % 处理单个数据项
            fieldLine = regexp(line, '_\S{1,}', 'match');
            field = fieldLine{1}(1:end);
            valueIndex = regexp(line, '_\S{1,}\s*', 'end');
            value = regexp(line(valueIndex + 1:end), '\S{1,}', 'match');
            switch field
                case '_symmetry_space_group_name_H-M'
                    combinedString = strjoin(value, '');
                    this.CIFObject.spaceGroup = combinedString(2:end-1);
                case '_cell_length_a'
                    this.CIFObject.a = str2double(value{1});
                case '_cell_length_b'
                    this.CIFObject.b = str2double(value{1});
                case '_cell_length_c'
                    this.CIFObject.c = str2double(value{1});
                case '_cell_angle_alpha'
                    this.CIFObject.alpha = str2double(value{1});
                case '_cell_angle_beta'
                    this.CIFObject.beta = str2double(value{1});
                case '_cell_angle_gamma'
                    this.CIFObject.gamma = str2double(value{1});
                case '_symmetry_Int_Tables_number'
                    % 国际晶体学对称性表中的对称性编号
                    this.CIFObject.symmetryIntTablesNumber = int64(str2double(value{1}));
                case '_chemical_formula_structural'
                    this.CIFObject.chemicalFormulaStructural = value{1};
                case '_chemical_formula_sum'
                    combinedString = strjoin(value, '');
                    this.CIFObject.chemicalFormulaSum = combinedString(2:end-1);
                case '_cell_volume'
                    this.CIFObject.volume = str2double(value{1});
                case '_cell_formula_units_Z'
                    % 每个单位晶胞包含的分子或离子的数量
                    this.CIFObject.cellFormulaUnitsZ = int64(str2double(value{1}));
            end
        end
        
        function processLoop(this)
            % 处理 loop_ 结构
            totalLines = length(this.fileContent);
            % 预分配 fields 字段
            fields = cell(totalLines, 1);
            fieldCount = 0;
            values = [];
        
            % 收集字段名
            this.currentLineIndex = this.currentLineIndex + 1; % 跳过 'loop_' 这一行
            while this.currentLineIndex <= totalLines && startsWith(this.fileContent{this.currentLineIndex}, ' _')
                fieldLine = regexp(this.fileContent{this.currentLineIndex}, '_\S+', 'match');
                field = fieldLine{1}(1:end);
                fieldCount = fieldCount + 1;
                fields{fieldCount} = field;
                this.currentLineIndex = this.currentLineIndex + 1;
            end
            % 调整大小以匹配实际使用的字段数量
            fields = fields(1:fieldCount);
        
            % 收集值到临时数组 valueMatrix 中，预分配大小
            valueMatrix = cell(totalLines, length(fields));
            valueCount = 0;
            while this.currentLineIndex <= totalLines && startsWith(this.fileContent{this.currentLineIndex}, '  ')
                valuesLine = strtrim(this.fileContent{this.currentLineIndex});
                if isempty(valuesLine)
                    % 跳过文件末尾的空行
                    break;
                end
                if startsWith(fields{1,1}, '_symmetry')
                    pattern = '(\d+)\s+([''"].*[''"])';
                    values = regexp(valuesLine, pattern, 'tokens');
                    if ~isempty(values)
                        values = [values{:}];
                    end
                elseif startsWith(fields{1,1}, '_atom')
                    pattern = '\S+';
                    values = regexp(valuesLine, pattern, 'match');
                end

                values = kssolv.services.fileparser.CIFReader.convertValues(values);
                valueCount = valueCount + 1;
                valueMatrix(valueCount, 1:numel(values)) = values;
                this.currentLineIndex = this.currentLineIndex + 1;
            end
            % 调整大小以匹配实际使用的数量
            valueMatrix = valueMatrix(1:valueCount, :);
        
            % 将值分配给结构体中的字段
            for i = 1:numel(fields)
                fieldValues = valueMatrix(:, i);
                switch fields{i}
                    case '_symmetry_equiv_pos_site_id'
                        this.CIFObject.equivalentPositionSiteId = fieldValues;
                    case '_symmetry_equiv_pos_as_xyz'
                        this.CIFObject.equivalentPositionAsXyz = fieldValues;
                    case '_atom_site_type_symbol'
                        this.CIFObject.atomTypeSymbol = fieldValues;
                    case '_atom_site_label'
                        this.CIFObject.atomLabel = fieldValues;
                    case '_atom_site_symmetry_multiplicity'
                        this.CIFObject.atomSymmetryMultiplicity = fieldValues;
                    case '_atom_site_fract_x'
                        this.CIFObject.atomFractionalX = cell2mat(fieldValues);
                    case '_atom_site_fract_y'
                        this.CIFObject.atomFractionalY = cell2mat(fieldValues);
                    case '_atom_site_fract_z'
                        this.CIFObject.atomFractionalZ = cell2mat(fieldValues);
                    case '_atom_site_occupancy'
                        this.CIFObject.atomOccupancy = cell2mat(fieldValues);
                end
            end
            % 调整索引以在循环后继续正确处理
            this.currentLineIndex = this.currentLineIndex - 1;
        end

        function buildKSSOLVSetupObject(this)
            % 使用 CIFObject 中的数据来计算 KSSOLVSetupObject
            this.KSSOLVSetupObject.name = this.CIFObject.name;

            % 获取晶胞参数
            a = this.CIFObject.a;
            b = this.CIFObject.b;
            c = this.CIFObject.c;
            alpha = this.CIFObject.alpha;
            beta = this.CIFObject.beta;
            gamma = this.CIFObject.gamma;
        
            % 计算晶胞向量
            a1 = [a, 0, 0];
            a2 = [b * cosd(gamma), b * sind(gamma), 0];
            tmpCos = ((c * sind(beta))^2 + (b * sind(gamma))^2 - ...
                       ((b^2 + c^2 - 2 * b * c * cosd(alpha)) - ...
                        (b * cosd(gamma) - c * cosd(beta))^2)) / ...
                      (2 * (c * sind(beta)) * (b * sind(gamma)));
            tmpSin = sqrt(1 - tmpCos^2);
            a3 = [c * cosd(beta), c * sind(beta) * tmpCos, c * sind(beta) * tmpSin];
            C = [a1; a2; a3];
            this.KSSOLVSetupObject.C = C ./ 0.5291772083;
        
            % 读取原子信息
            nAtoms = length(this.CIFObject.atomLabel);
            atomList = strings(1, nAtoms);
            for i = 1:nAtoms
                atomList(i) = regexprep(this.CIFObject.atomLabel{i}, '\d', '');
            end
            this.KSSOLVSetupObject.atomList = atomList;
        
            % 计算原子坐标
            latticeVectors = [this.CIFObject.atomFractionalX, ...
                      this.CIFObject.atomFractionalY, ...
                      this.CIFObject.atomFractionalZ];
            this.KSSOLVSetupObject.xyzList = latticeVectors * C;
        end
    end

    methods (Access = private, Static)
        function values = convertValues(values)
            % 将字符串值转换为数字（如果可能）
            for i = 1:length(values)
                num = str2double(values{i});
                if ~isnan(num)
                    values{i} = num;
                end
            end
        end
    end
end

