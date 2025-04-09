classdef MoleculeDisplay < handle
    %MOLECULEDISPLAY 三维渲染分子结构和晶体结构的组件

    %   开发者：杨柳
    %   版权 2024 合肥瀚海量子科技有限公司

    properties
        DocumentGroupTag
        structureFileContent string
        structureFileType string
        tag string
    end

    methods
        function this = MoleculeDisplay(structureFileContent, structureFileType, tag)
            %MOLECULEDISPLAY 构造此类的实例
            arguments
                structureFileContent string = ""
                structureFileType string = ""
                tag string = ""
            end
            if structureFileContent == ""
                structureFilePath = fullfile(fileparts(mfilename('fullpath')), ...
                    'test', 'MoS2_mp-2815_conventional_standard.cif');
                this.structureFileContent = fileread(structureFilePath);
                this.structureFileType = "cif";
            else
                this.structureFileContent = structureFileContent;
                this.structureFileType = structureFileType;
            end
            this.tag = tag;
            this.DocumentGroupTag = 'Structure';

            appContainer = kssolv.ui.util.DataStorage.getData('AppContainer');
            group = appContainer.getDocumentGroup(this.DocumentGroupTag);
            if isempty(group)
                % 若 appContainer 没有 Tag 为 'Structure' 的 DocumentGroup，
                % 则创建 DocumentGroup 并添加到 appContainer 中
                group = matlab.ui.internal.FigureDocumentGroup();
                group.Tag = this.DocumentGroupTag;
                group.Title = this.DocumentGroupTag;
                group.DefaultRegion = 'left';
                appContainer.add(group);
            end
        end

        function Display(this)
            %DISPLAY 在 Document Group 中展示渲染的分子/晶体结构
            appContainer = kssolv.ui.util.DataStorage.getData('AppContainer');
            document = appContainer.getDocument(this.DocumentGroupTag, this.tag);
            if ~isempty(document)
                % 如果具有相同 tag 的 document 存在，则选中它
                document.Selected = true;
                return
            end

            figOptions.Title = kssolv.ui.util.Localizer.message('KSSOLV:toolbox:DocumentStructureTitle');
            figOptions.DocumentGroupTag = this.DocumentGroupTag;
            if this.tag ~= ""
                figOptions.Tag = this.tag;

                project = kssolv.ui.util.DataStorage.getData('Project');
                figOptions.Title = project.findChildrenItem(this.tag).label;
            end
            document = matlab.ui.internal.FigureDocument(figOptions);

            % 添加 html 组件
            fig = document.Figure;
            g = uigridlayout(fig);
            g.RowHeight = {'1x'};
            g.ColumnWidth = {'1x'};
            htmlFile = fullfile(fileparts(mfilename('fullpath')), '3Dmol', '3Dmol.html');
            h = uihtml(g, "HTMLSource", htmlFile);

            % 将包含结构信息的文件的内容发送到 html 组件中
            eventData = struct('type', this.structureFileType, 'data', this.structureFileContent);
            h.Data = jsonencode(eventData, "PrettyPrint", true);

            % 添加到 App Container
            appContainer.add(document);
        end
    end

    methods (Hidden)
        function app = qeShow(this)
            % 用于在单元测试中测试 MoleculeDisplay，可通过下面的命令使用：
            % m = kssolv.ui.components.figuredocument.MoleculeDisplay();
            % m.qeShow()

            % 创建 App Container
            appOptions.Tag = sprintf('kssolv(%s)',char(matlab.lang.internal.uuid));
            appOptions.Title = kssolv.ui.util.Localizer.message('KSSOLV:toolbox:UnitTestTitle');
            appOptions.ToolstripEnabled = true;
            app = matlab.ui.container.internal.AppContainer(appOptions);

            % 保存 app 至 DataStorage
            import kssolv.ui.util.DataStorage.*
            setData('AppContainer', app);

            % 添加 Document Group
            group = matlab.ui.internal.FigureDocumentGroup();
            group.Tag = 'DocumentGroupTest';
            group.Title = 'DocumentGroupTest';
            group.DefaultRegion = 'left';
            app.add(group);

            % 展示界面
            app.Visible = true;

            % 展示 MolecularDisplay
            this.DocumentGroupTag = 'DocumentGroupTest';
            this.Display();
        end
    end
end

