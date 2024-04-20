classdef POSCARReader < handle
    % POSCARReader 用于读取和解�? POSCAR 文件的类

    %   �?发�?�：付礼�? 杨柳
    %   版权 2024 合肥瀚海量子科技有限公司

    properties
        filePath           % POSCAR 文件路径
        fileContent        % POSCAR 文件内容
        POSCARObject struct   % �? POSCAR 文件中解析出的数据结�?
    end

    properties (Access = private)
        currentLineIndex   % 当前处理的行的索�?
    end
    
    methods
        function this = POSCARReader(filePath)
            % 构�?�函数，初始化读取和解析 POSCAR 文件
            this.filePath = filePath;
            this.readFile();
            try
                this.extractData();
            catch ME
                error('KSSOLV:FileParser:POSCARReader:ExtractDataError', ...
                    'Error extracting data from %s: %s', this.filePath, ME.message);
            end
        end

        function readFile(this)
            % 读取文件内容
            fid = fopen(this.filePath, 'r');
            if fid == -1
                error('KSSOLV:FileParser:POSCARReader:OpenFileError', 'Cannot open this POSCAR file: %s', this.filePath);
            end
            fileRawContent = textscan(fid, '%s', 'Delimiter', '\n', 'Whitespace', '');
            fclose(fid);
            this.fileContent = fileRawContent{1};
        end
    end

    methods (Access = private)
        function extractData(this)
            % 从文件内容中提取数据
            this.POSCARObject = struct();
            this.currentLineIndex = 1;
            totalLines = length(this.fileContent);


            %Get the comment line
            name = this.fileContent{this.currentLineIndex};
            this.currentLineIndex = this.currentLineIndex + 1;
            this.POSCARObject.name = name;

            %Get scaling factor; negative scaling factor represents the desired cell volume
            seperate_scaling = false;
            volume_scaling = false;
            scaling = strsplit(this.fileContent{this.currentLineIndex});
            if length(scaling) == 1
                scaling = str2double(scaling);
                if scaling < 0
                    volume_scaling = true;
                    volume = -scaling;
                end
            else
                seperate_scaling = true;
                scaling = str2double(scaling);
            end
            this.currentLineIndex = this.currentLineIndex + 1;

            %Read lattice vectors
            a1=str2double(strsplit(this.fileContent{this.currentLineIndex}));
            this.currentLineIndex = this.currentLineIndex + 1;
            a2=str2double(strsplit(this.fileContent{this.currentLineIndex}));
            this.currentLineIndex = this.currentLineIndex + 1;
            a3=str2double(strsplit(this.fileContent{this.currentLineIndex}));
            this.currentLineIndex = this.currentLineIndex + 1;

            if ~seperate_scaling
                if ~volume_scaling
                    C=scaling*[a1;a2;a3];
                else
                    C=[a1;a2;a3];
                    scaling=nthroot((volume/abs(det(C))),3);
                    C=scaling*C;
                end
            else
                C=[a1;a2;a3];
                C=C*diag(scaling);
            end
            this.POSCARObject.C = C;

            %Read atom species
            species = strsplit(this.fileContent{this.currentLineIndex});
            this.currentLineIndex = this.currentLineIndex + 1;
            num = str2double(strsplit(this.fileContent{this.currentLineIndex}));
            this.currentLineIndex = this.currentLineIndex + 1;
            n_species = length(species);
            n_atoms = sum(num);
            a = cell(1,n_species);
            atomlist = cell(1,n_atoms);
            idx = 1;
            for i = 1:n_species
                a(i) = species(i);
                for j = 1:num(i)
                    atomlist(idx) =a(i);
                    idx =idx+1;
                end
            end
            this.POSCARObject.atomlist = atomlist;

            is_selectivedymanics = false;
            tmpline = upper(this.fileContent{this.currentLineIndex});
            this.currentLineIndex = this.currentLineIndex + 1;
            if tmpline(1) == 'S'
                is_selectivedymanics = true;
                tmpline = upper(this.fileContent{this.currentLineIndex});
                this.currentLineIndex = this.currentLineIndex + 1;
            end
            this.POSCARObject.is_selectivedymanics = is_selectivedymanics;
            
            is_direct = true;
            if tmpline(1) == 'C' || tmpline(1) == 'K'
                is_direct = false;
            end

            %Read atomic coordinates
            coeffs=zeros(n_atoms,3);
            for i = 1:n_atoms
                tmpline=strsplit(this.fileContent{this.currentLineIndex});
                this.currentLineIndex = this.currentLineIndex + 1;
                coeffs(i,:)=str2double(tmpline(1:3));
            end

            if is_direct
                xyzlist=coeffs*C;
            else
                if ~seperate_scaling
                    xyzlist=coeffs*scaling;
                else
                    xyzlist=coeffs*diag(scaling);
                end
            end
            this.POSCARObject.xyzlist = xyzlist;
        end
    end
end

