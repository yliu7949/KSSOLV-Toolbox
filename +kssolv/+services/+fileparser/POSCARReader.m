classdef POSCARReader < handle
    % POSCARREADER 用于读取和解析 POSCAR 文件的类
    % POSCAR 文件格式的定义可参考：https://www.vasp.at/wiki/index.php/POSCAR

    %   开发者：付礼中 杨柳
    %   版权 2024 合肥瀚海量子科技有限公司

    properties
        filePath                % POSCAR 文件路径
        fileContent             % POSCAR 文件内容
        rawFileContent string   % 原始 POSCAR 文件内容
        POSCARObject   struct   % 从 POSCAR 文件中解析出的数据结构
    end

    properties (Access = private)
        currentLineIndex        % 当前处理的行的索引
    end

    methods
        function this = POSCARReader(filePath)
            % 构造函数，初始化读取和解析 POSCAR 文件
            this.filePath = filePath;
            this.readFile();
            this.parseFile();
        end

        function readFile(this)
            % 读取文件内容
            fid = fopen(this.filePath, 'r');
            if fid == -1
                error('KSSOLV:FileParser:POSCARReader:OpenFileError', ...
                    'Cannot open this POSCAR file: %s', this.filePath);
            end
            fileRawContent = textscan(fid, '%s', 'Delimiter', '\n', 'Whitespace', '');
            fclose(fid);
            this.fileContent = fileRawContent{1};
            this.rawFileContent = strjoin(this.fileContent, '\n');
        end

        function parseFile(this)
            % 解析文件内容
            this.POSCARObject = struct();
            this.currentLineIndex = 1;
            try
                this.extractCommentLine();
                this.extractScalingFactor();
                this.extractLatticeVectors();
                this.extractAtomSpecies();
                this.extractSelectiveDynamics();
                this.extractAtomicCoordinates();
            catch ME
                error('KSSOLV:FileParser:POSCARReader:ExtractDataError', ...
                    'Error extracting data from %s: %s', this.filePath, ME.message);
            end
        end
    end

    methods (Access = private)
        function extractCommentLine(this)
            % 提取注释行
            this.POSCARObject.name = this.fileContent{this.currentLineIndex};
            this.currentLineIndex = this.currentLineIndex + 1;
        end

        function extractScalingFactor(this)
            % 提取缩放因子
            scaling = strsplit(this.fileContent{this.currentLineIndex});
            this.POSCARObject.scalingFactor = str2double(scaling);
            this.currentLineIndex = this.currentLineIndex + 1;
        end

        function extractLatticeVectors(this)
            % 提取晶格矢量
            latticeVectors = zeros(3, 3, 'double');
            for i = 1:3
                latticeVectors(i, :) = str2double(strsplit(this.fileContent{this.currentLineIndex}));
                this.currentLineIndex = this.currentLineIndex + 1;
            end
            this.POSCARObject.latticeVectors = latticeVectors;

            % 根据缩放因子进行调整
            if isscalar(this.POSCARObject.scalingFactor)
                % 如果仅有一个缩放因子
                if this.POSCARObject.scalingFactor > 0
                    % 如果该缩放因子为正值
                    C = this.POSCARObject.scalingFactor * latticeVectors;
                else
                    % 如果该缩放因子为负值，则绝对值为晶胞的体积
                    scaling = nthroot(abs(this.POSCARObject.scalingFactor) / abs(det(latticeVectors)), 3);
                    C = scaling * latticeVectors;
                end
            else
                % 如果有三个缩放因子，则分别对 xyz 进行缩放
                C = latticeVectors * diag(this.POSCARObject.scalingFactor);
            end

            this.POSCARObject.C = C;
        end

        function extractAtomSpecies(this)
            % 提取原子种类和数量并构造 atomList
            species = strsplit(this.fileContent{this.currentLineIndex});
            this.currentLineIndex = this.currentLineIndex + 1;
            atomNumber = str2double(strsplit(this.fileContent{this.currentLineIndex}));
            this.currentLineIndex = this.currentLineIndex + 1;

            % 预分配 atomList，提升性能
            atomList = cell(1, sum(atomNumber));
            startIndex = 1;
            for i = 1:length(species)
                % 当前种类的原子数量
                numAtoms = atomNumber(i);
                endIndex = startIndex + numAtoms - 1;
                
                % 将当前种类的原子名称填充到 atomList
                atomList(startIndex:endIndex) = repmat(species(i), 1, numAtoms);
                
                % 更新起始索引
                startIndex = endIndex + 1;
            end

            this.POSCARObject.atomList = string(atomList);
        end

        function extractSelectiveDynamics(this)
            % 提取选择性动力学
            this.POSCARObject.isSelectiveDynamics = false;
            if upper(this.fileContent{this.currentLineIndex}(1)) == 'S'
                % 如果这一行包含 Selective dynamics 字样（实际上仅判断首字母）
                this.POSCARObject.isSelectiveDynamics = true;
                this.currentLineIndex = this.currentLineIndex + 1;
            end
        end

        function extractAtomicCoordinates(this)
            % 提取原子坐标
            isDirectMode = true;
            if upper(this.fileContent{this.currentLineIndex}(1)) == 'C' ...
                    || upper(this.fileContent{this.currentLineIndex}(1)) == 'K'
                % 如果该行首字母大写后是字母 C 或 K，则为 Cartesian Mode
                isDirectMode = false;
            end
            this.currentLineIndex = this.currentLineIndex + 1;

            ionPositons = zeros(length(this.POSCARObject.atomList), 3, 'double');
            for i = 1:length(this.POSCARObject.atomList)
                lineData = strsplit(this.fileContent{this.currentLineIndex});
                ionPositons(i, :) = str2double(lineData(1:3));
                this.currentLineIndex = this.currentLineIndex + 1;
            end
            this.POSCARObject.ionPositons = ionPositons;

            if isDirectMode
                % 如果为 Direct Mode
                this.POSCARObject.xyzList = ionPositons * this.POSCARObject.C;
            else
                % 如果为 Cartesian Mode
                this.POSCARObject.xyzList = ionPositons * diag(this.POSCARObject.scalingFactor);
            end
        end
    end
end

