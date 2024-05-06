classdef InfoBrowser < matlab.ui.internal.databrowser.AbstractDataBrowser
    %INFOBROWSER 自定义的 Data Browser 组件，显示 Project Browser 里对应项的具体信息
    
    %   开发者：杨柳
    %   版权 2024 合肥瀚海量子科技有限公司
    
    properties
        Widgets
    end
    
    methods
        function this = InfoBrowser()
            %INFOBROWSER 构造此类的实例
            title = kssolv.ui.util.Localizer.message('KSSOLV:toolbox:InfoBrowserTitle');
            % 调用超类构造函数
            this = this@matlab.ui.internal.databrowser.AbstractDataBrowser('InfoBrowser', title);          
            % 自定义 widget 和 layout
            buildUI(this);
            % 设定 FigurePanel 的 Tag
            this.Panel.Tag = 'InfoBrowser';
            % 添加 ProjectBrowser 的监听器
            projectBrowser = kssolv.ui.util.DataStorage.getData('ProjectBrowser');
            addlistener(projectBrowser, 'currentSelectedItem', 'PostSet', ...
                    @this.handleCurrentSelectedItem);
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
            
            htmlFile = fullfile(fileparts(mfilename('fullpath')), 'html', 'index.html');
            h = uihtml(g, "HTMLSource", htmlFile);
            this.Widgets.html = h;
        end
    end

    methods (Access = private)
        function handleCurrentSelectedItem(this, ~, event)
            project = kssolv.ui.util.DataStorage.getData('Project');
            name = event.AffectedObject.currentSelectedItem;
            item = project.findChildrenItem(name);
            this.Widgets.html.Data = item.encode();
        end
    end

    methods (Hidden)
        function app = qeShow(this)
            % 用于在单元测试中测试 InfoBrowser，可通过下面的命令使用：
            % b = kssolv.ui.components.databrowser.InfoBrowser();
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

