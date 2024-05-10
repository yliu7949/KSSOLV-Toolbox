classdef Structure < kssolv.services.filemanager.AbstractItem
    %STRUCTURE 定义了KSSOLV Toolbox 结构类和相关操作函数

    %   开发者：杨柳
    %   版权 2024 合肥瀚海量子科技有限公司
    
    methods
        function this = Structure(label, type)
            %STRUCTURE 构造函数
            arguments
                label string = "Structure"
                type string = "Structure"
            end
            this = this@kssolv.services.filemanager.AbstractItem(label, type);
        end
        
        function showMoleculerDisplay(this)
            % 使用 Data 数据中的文件路径以打开对应结构的渲染界面
            kssolv.ui.components.figuredocument.MoleculerDisplay(this.data.rawFileContent).Display();
        end

        function importedFileCount = importStructureFromFile(this)
            import kssolv.ui.util.Localizer.message
            [files, path] = uigetfile({'*.cif';'*.vasp';'*.*'}, ...
                message("KSSOLV:dialogs:ImportStructureFromFile"), 'MultiSelect', 'on');
        
            % 检查用户是否点击了取消按钮
            if isequal(files, 0)
                importedFileCount = 0;
                return
            end
        
            % 确保 files 是一个 cell 数组，方便统一处理
            if ~iscell(files)
                files = {files};
            end
        
            % 初始化成功导入的文件计数
            importedFileCount = 0;
        
            % 遍历所有选中的文件
            for i = 1:length(files)
                fullPath = fullfile(path, files{i});
                [~, filename, ~] = fileparts(files{i});
        
                % 解析文件并创建结构节点
                structure = kssolv.services.filemanager.Structure(filename);
                structure.data = kssolv.services.fileparser.CIFReader(fullPath);
                if ~isempty(structure.data)
                    this.addChildrenItem(structure);
                    importedFileCount = importedFileCount + 1;
        
                    % 渲染结构文件中的结构
                    cifFileContent = fileread(fullPath);
                    displayObj = kssolv.ui.components.figuredocument.MoleculerDisplay(cifFileContent);
                    displayObj.Display();
                end
            end
        end
    end
end

