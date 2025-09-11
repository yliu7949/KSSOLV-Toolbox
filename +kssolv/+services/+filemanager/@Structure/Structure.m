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

        function showMoleculeDisplay(this)
            % 使用 Data 数据中的文件路径以打开对应结构的渲染界面
            kssolv.ui.components.figuredocument.MoleculeDisplay(this.data.rawFileContent, this.data.fileType, this.name).Display();
        end

        function importedFileCount = importStructureFromFile(this)
            % 打开导入结构文件对话框，创建并添加 Structure 节点，渲染结构
            import kssolv.ui.util.Localizer.message

            if ismac
                % 在 Mac 平台上 uigetfile 对话框存在缺陷，无法过滤和选中 .vasp 等文件
                % 因此只能使用 uigetfile('*') 选择所有文件后再判断选中文件的扩展名
                % 参考资料：https://ww2.mathworks.cn/matlabcentral/answers/484281-why-am-i-unable-to-select-a-file-when-i-use-uigetfile-function-on-the-newest-mac-operation-system
                [files, path] = uigetfile('*', message("KSSOLV:dialogs:ImportStructureFromFile"), 'MultiSelect', 'on');
            else
                [files, path] = uigetfile({'*.cif', 'CIF Files (*.cif)'; ...
                    '*.vasp;*.poscar', 'VASP Files (*.vasp, *.poscar)'; ...
                    '*.*', 'All Files (*.*)'}, ...
                    message("KSSOLV:dialogs:ImportStructureFromFile"), 'MultiSelect', 'on');
            end

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
                [~, filename, ext] = fileparts(files{i});
                ext = lower(ext);

                % 解析文件并创建结构节点
                structure = kssolv.services.filemanager.Structure(filename);

                % 根据文件扩展名进行解析
                switch ext
                    case '.cif'
                        structure.data = kssolv.services.fileparser.CIFReader(fullPath);

                        if ~isempty(structure.data)
                            this.addChildrenItem(structure);
                            importedFileCount = importedFileCount + 1;

                            % 读取文件内容并展示结构
                            cifFileContent = fileread(fullPath);
                            displayObj = kssolv.ui.components.figuredocument.MoleculeDisplay(cifFileContent, "cif", structure.name);
                            displayObj.Display();
                        end

                    case {'.vasp', '.poscar'}
                        structure.data = kssolv.services.fileparser.POSCARReader(fullPath);

                        if ~isempty(structure.data)
                            this.addChildrenItem(structure);
                            importedFileCount = importedFileCount + 1;

                            % 读取文件内容并展示结构
                            vaspFileContent = fileread(fullPath);
                            displayObj = kssolv.ui.components.figuredocument.MoleculeDisplay(vaspFileContent, "vasp", structure.name);
                            displayObj.Display();
                        end

                    otherwise
                        warning('Unsupported file format: %s', ext);
                end
            end
        end
    end

    methods (Static)
        function importedStructures = getAllImportedStructures()
            % 输出当前使用的工程中 Structure 节点下的所有数据结构体
            project = kssolv.ui.util.DataStorage.getData('Project');
            if isempty(project)
                importedStructures = cell.empty;
                return
            end

            structureItem = project.findChildrenItem('Structure');
            importedStructures = cell(size(structureItem.children, 1), 1);
            for i = 1:size(structureItem.children, 1)
                temp = structureItem.children{i}.data.KSSOLVSetupObject;
                temp.node.label = structureItem.children{i}.label;
                temp.node.name = structureItem.children{i}.name;
                importedStructures{i, 1} = temp;
            end
        end
    end
end

