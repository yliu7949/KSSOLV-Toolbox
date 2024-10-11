classdef ConfigBrowser < matlab.ui.internal.databrowser.AbstractDataBrowser
    %CONFIGBROWSER 自定义的 Data Browser 组件，Workflow 中工作节点具体配置的编辑器
    
    %   开发者：杨柳
    %   版权 2024 合肥瀚海量子科技有限公司
    
    properties
        Property1
    end
    
    methods
        function this = ConfigBrowser()
            %CONFIGBROWSER 构造此类的实例
            title = kssolv.ui.util.Localizer.message('KSSOLV:toolbox:ConfigBrowserTitle');
            % 调用超类构造函数
            this = this@matlab.ui.internal.databrowser.AbstractDataBrowser('ConfigBrowser', title);          
            % 自定义 widget 和 layout
            buildUI(this);
            % 设定 FigurePanel 的 Tag
            this.Panel.Tag = 'ConfigBrowser';
            % 将该 Browser 放在界面右侧
            this.Panel.Region = "right";
        end
    end

    methods (Access = protected)
        function buildUI(this)
            import kssolv.ui.components.custom.*

            % 创建网格布局
            g = uigridlayout(this.Figure);
            g.BackgroundColor = "white";
            g.Padding = [0 0 0 0];
            g.RowHeight = {'fit', '1x'};
            g.ColumnWidth = {'1x'};

            % 创建 buttonPanelLayout
            buttonPanelLayout = uigridlayout(g);
            buttonPanelLayout.BackgroundColor = "white";
            buttonPanelLayout.Padding = 5;
            buttonPanelLayout.ColumnWidth = {'1x', 30};
            buttonPanelLayout.RowHeight = {30};

            % 文字标签
            label = uilabel(buttonPanelLayout);
            label.Text = '<b style="font-size:12px;color:#616161">Node Settings</b>';
            label.Interpreter = "html";
            % 帮助按钮，Row = 1，Column = 2
            button = CustomButton(buttonPanelLayout);
            button.Layout.Row = 1;
            button.Layout.Column = 2;
            matlab.ui.control.internal.specifyIconID(button, 'help', 18);
            % button.LayoutBackgroundColor = "black";

            % 折叠面板
            % togglePanel = TogglePanel(g);
            % togglePanel.BackgroundColor = [0.5 0.5 0.5];
        end
    end

    methods (Hidden)
        function [app, this] = qeShow(this)
            % 用于在单元测试中测试 ConfigBrowser，可通过下面的命令使用：
            % b = kssolv.ui.components.databrowser.ConfigBrowser();
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

