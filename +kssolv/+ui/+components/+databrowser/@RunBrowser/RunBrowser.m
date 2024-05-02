classdef RunBrowser < matlab.ui.internal.databrowser.AbstractDataBrowser
    %RUNBROWSER 自定义的 Data Browser 组件，存放运行相关控件
    
    %   开发者：杨柳
    %   版权 2024 合肥瀚海量子科技有限公司
    
    properties
        Widgets   % 小组件
    end
    
    methods
        function this = RunBrowser()
            %RUNBROWSER 构造此类的实例
            title = kssolv.ui.util.Localizer.message('KSSOLV:toolbox:RunBrowserTitle');
            % 调用超类构造函数
            this = this@matlab.ui.internal.databrowser.AbstractDataBrowser('RunBrowser', title);          
            % 自定义 widget 和 layout
            buildUI(this);
            % 设定 FigurePanel 的 Tag
            this.Panel.Tag = 'RunBrowser';
            % 将该 Browser 放在界面右侧
            this.Panel.Region = "right";
        end
    end

    methods (Access = protected)
        function buildUI(this)
            % 创建网格布局
            g = uigridlayout(this.Figure);
            g.Padding = [0 0 0 0];
            g.RowHeight = {'fit', '1x'};
            g.ColumnWidth = {'1x'};

            % 创建 buttonPanelLayout
            buttonPanelLayout = uigridlayout(g);
            buttonPanelLayout.ColumnWidth = {25, 'fit', 25, 'fit', 25, '1x', 25, 'fit'};
            buttonPanelLayout.RowHeight = {'1x'};
            buttonPanelLayout.Padding = 10;
            buttonPanelLayout.RowSpacing = 5;
            buttonPanelLayout.ColumnSpacing = 5;

            import kssolv.ui.components.databrowser.RunBrowser.createButton
            import matlab.ui.internal.toolstrip.Icon

            % 运行按钮，Row = 1，Column = 1
            runButtonTooltip = 'Run simulation';
            runButtonIcon = 'playControl';
            runButton = createButton(buttonPanelLayout, 1, 1, ...
                runButtonTooltip, runButtonIcon);
            % 运行标签，Row = 1，Column = 2
            runLabel = uilabel(buttonPanelLayout);
            runLabel.Text = "运行";
            runLabel.Layout.Row = 1;
            runLabel.Layout.Column = 2;

            % 停止按钮，Row = 1，Column = 3
            stopButtonTooltip = 'Stop simulation';
            stopButtonIcon = 'stop';
            stopButton = createButton(buttonPanelLayout, 1, 3, ...
                stopButtonTooltip, stopButtonIcon);
            % 停止标签，Row = 1，Column = 4
            stopLabel = uilabel(buttonPanelLayout);
            stopLabel.Text = "停止";
            stopLabel.Layout.Row = 1;
            stopLabel.Layout.Column = 4;

            % 清空按钮，Row = 1，Column = 7
            clearButtonTooltip = 'Clear output';
            clearButtonIcon = 'clear';
            clearButton = createButton(buttonPanelLayout, 1, 7, ...
                clearButtonTooltip, clearButtonIcon);
            % 清空标签，Row = 1，Column = 8
            clearLabel = uilabel(buttonPanelLayout);
            clearLabel.Text = "清空";
            clearLabel.Layout.Row = 1;
            clearLabel.Layout.Column = 8;

            % 添加到 Widgets
            this.Widgets.ButtonPanel = struct('RunButton', runButton, ...
                'StopButton', stopButton, 'ClearButton', clearButton);
        end
    end

    methods (Access = private, Static)
        function button = createButton(buttonPanelLayout, row, column, tooltip, icon, buttonText)
            % 创建按钮
            arguments
                buttonPanelLayout
                row
                column
                tooltip
                icon
                buttonText = ""
            end
            button = uibutton(buttonPanelLayout, "Interruptible", "off");
            button.Layout.Row = row;
            button.Layout.Column = column;
            button.Tooltip = tooltip;

            if buttonText == ""
                button.Text = '';
                matlab.ui.control.internal.specifyIconID(button, icon, 16);
            else
                buttonPanelLayout.ColumnWidth{column} = 'fit';
                button.Text = buttonText;
            end
            button.IconAlignment = "center";
        end
    end

    methods (Hidden)
        function app = qeShow(this)
            % 用于在单元测试中测试 RunBrowser，可通过下面的命令使用：
            % b = kssolv.ui.components.databrowser.RunBrowser();
            % b.qeShow()

            % 创建 AppContainer          
            appOptions.Tag = sprintf('kssolv(%s)',char(matlab.lang.internal.uuid));
            appOptions.Title = kssolv.ui.util.Localizer.message('KSSOLV:toolbox:UnitTestTitle');
            appOptions.ToolstripEnabled = true;
            app = matlab.ui.container.internal.AppContainer(appOptions);

            % 将 RunBrowser 添加到 App Container
            this.addToAppContainer(app);
            % 展示界面
            app.Visible = true;
        end
    end
end

