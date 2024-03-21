classdef ProjectBrowser < matlab.ui.internal.databrowser.AbstractDataBrowser
    %PROJECTBROWSER 自定义的 Data Browser 组件，存放 ks 项目文件的 TreeTable 视图
    %   开发者：杨柳
    %   版权 2024 合肥瀚海量子科技有限公司
    
    properties
        Property1
    end
    
    methods
        function this = ProjectBrowser()
            %PROJECTBROWSER 构造此类的实例
            title = kssolv.ui.util.Localizer.message('KSSOLV:toolbox:ProjectBrowserTitle');
            % 调用超类构造函数
            this = this@matlab.ui.internal.databrowser.AbstractDataBrowser('ProjectBrowser', title);          
            % 自定义 widget 和 layout
            buildUI(this);
            % 设定 FigurePanel 的 Tag
            this.Panel.Tag = 'ProjectBrowser';
        end
    end

    methods (Access = protected)
        function buildUI(this)
            fig = this.Figure;
            g = uigridlayout(fig);
            g.BackgroundColor = "white";
            g.Padding = [0 0 0 0];
            g.RowHeight = {'1x'};
            g.ColumnWidth = {'1x'};
            
            htmlFile = fullfile(fileparts(mfilename('fullpath')), 'TreeTable', 'TreeTable.html');
            uihtml(g, "HTMLSource", htmlFile);
        end
    end

    methods (Hidden)
        function app = qeShow(this)
            % 用于在单元测试中测试 ProjectBrowser，可通过下面的命令使用：
            % b = kssolv.ui.components.databrowser.ProjectBrowser();
            % b.qeShow()

            % 创建 AppContainer          
            appOptions.Tag = sprintf('kssolv(%s)',char(matlab.lang.internal.uuid));
            appOptions.Title = kssolv.ui.util.Localizer.message('KSSOLV:toolbox:UnitTestTitle');
            appOptions.ToolstripEnabled = true;
            app = matlab.ui.container.internal.AppContainer(appOptions);

            % 将 Browser 添加到 App Container
            this.addToAppContainer(app);
            % 展示界面
            app.Visible = true;
        end
    end
end

