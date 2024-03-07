classdef Workflow
    %WORKFLOW 工作流组件
    %   开发者：杨柳
    %   版权 2024 合肥瀚海量子科技有限公司
    
    properties
        DocumentGroupTag
    end
    
    methods
        function this = Workflow()
            %WORKFLOW 构造此类的实例
            this.DocumentGroupTag = 'DocumentGroup';
        end
    end

    methods
        function Display(this)
            %DISPLAY 在 Document Group 中展示工作流画布
            figOptions.Title = '工作流'; 
            figOptions.DocumentGroupTag = this.DocumentGroupTag; 
            document = matlab.ui.internal.FigureDocument(figOptions);

            % 添加 html 组件
            fig = document.Figure;
            g = uigridlayout(fig);
            g.RowHeight = {'1x'};
            g.ColumnWidth = {'1x'};
            htmlFile = fullfile(fileparts(mfilename('fullpath')), 'workflow', 'index.html');
            uihtml(g, "HTMLSource", htmlFile);

            % 添加到 App Container
            appContainer = kssolv.ui.util.DataStorage.getData('AppContainer');
            appContainer.add(document);
        end
    end

    methods (Hidden)
        function app = qeShow(this)
            % 用于在单元测试中测试 Workflow，可通过下面的命令使用：
            % w = kssolv.ui.components.figuredocument.Workflow();
            % w.qeShow()

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

            % 展示 Workflow 画布
            this.DocumentGroupTag = 'DocumentGroupTest';
            this.Display();
        end
    end
end

