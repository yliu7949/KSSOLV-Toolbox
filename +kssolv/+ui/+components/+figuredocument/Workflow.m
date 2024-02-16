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
            this.DocumentGroupTag = 'Workflow';
        end
    end

    methods
        function Display(this)
            %DISPLAY 在 Document Group 中展示工作流画布
            figOptions.Title = '工作流'; 
            figOptions.DocumentGroupTag = this.DocumentGroupTag; 
            document = matlab.ui.internal.FigureDocument(figOptions);

            fig = document.Figure;
            g = uigridlayout(fig);
            g.RowHeight = {400, '1x'};
            g.ColumnWidth = {400, '1x'};

            % 创建一个 uiaxes 对象并将其放置在网格布局中
            canvasAxes = uiaxes(g);
            canvasAxes.Layout.Row = 1;
            canvasAxes.Layout.Column = 1;
            %% 配置 uiaxes 属性
            % 关闭坐标轴
            canvasAxes.XAxis.Visible = 'off';
            canvasAxes.YAxis.Visible = 'off';
            canvasAxes.XLim = [0 200];
            canvasAxes.YLim = [0 200];
            % 关闭右上角的 Toolbar
            canvasAxes.Toolbar = [];
            % 打开网格线，设置网格线样式
            axis(canvasAxes, 'square');
            grid(canvasAxes, 'on');
            grid(canvasAxes, 'minor');
            hold(canvasAxes, 'on');

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

