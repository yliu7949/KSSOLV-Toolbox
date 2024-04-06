classdef Project < kssolv.services.filemanager.AbstractItem
    %PROJECT 定义了以".ks"为扩展名的 KSSOLV Toolbox 项目文件类和相关操作函数
    
    %   开发者：杨柳
    %   版权 2024 合肥瀚海量子科技有限公司
    
    methods
        function this = Project()
            %PROJECT 构造函数
            this = this@kssolv.services.filemanager.AbstractItem("Project", "Project");
            this.name = "Project";
        end

        function saveToKsFile(this, filename)
            % 将项目数据结构体保存到 .ks 文件中
            arguments
                this
                filename (1,1) string = this.label + '.ks'
            end
        
            % 检查filename是否为绝对路径，并检查目录是否存在，不存在则创建
            folderPath = fileparts(filename);
            if ~isempty(folderPath) && ~exist(folderPath, 'dir')
                warning('off');
                mkdir(folderPath);
                warning('on');
            end
        
            data = this;
            try
                save(filename, 'data', "-mat", "-v7.3");
            catch ME
                error('KSSOLV:FileManager:Project:FileSaveError', ...
                      'Error saving the Project file: %s', ME.message);
            end
        end
    end

    methods (Static)
        function data = loadKsFile(fileName)
            % 从 .ks 文件中加载项目数据结构体
            try
                load(fileName, "-mat", 'data');
            catch ME
                error('KSSOLV:FileManager:Project:FileLoadError', ...
                      'Error loading the Project file: %s', ME.message);
            end
        end
    end
end

