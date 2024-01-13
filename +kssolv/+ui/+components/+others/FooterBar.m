classdef FooterBar < handle
    %FOOTERBAR 自定义的底部状态栏组件
    %   开发者：杨柳
    %   版权 2024 合肥瀚海量子科技有限公司
    properties (Access = private)
        StatusBar
        StatusProgress
        StatusLabel
    end

    methods
        function this = FooterBar()
            % 构造函数
            this.createComponents();
        end

        function createComponents(this)
            % 创建并配置 Status 相关组件
            this.StatusBar = matlab.ui.internal.statusbar.StatusBar();
            this.StatusBar.Tag = 'StatusBar';
            
            this.StatusProgress = matlab.ui.internal.statusbar.StatusProgressBar();
            this.StatusProgress.Indeterminate = true;
            this.StatusProgress.Tag = 'StatusProgress';
            this.StatusProgress.Region = 'right';
            
            this.StatusLabel = matlab.ui.internal.statusbar.StatusLabel();
            this.StatusLabel.Tag = 'StatusLabel';
            this.StatusLabel.Region = 'right';
        end

        function addToAppContainer(this, appContainer)
            appContainer.add(this.StatusBar);
            appContainer.add(this.StatusProgress);
            appContainer.add(this.StatusLabel);
        end

        function updateProgress(this, value)
            % 更新进度条
            this.StatusProgress.Value = value;
        end

        function setText(this, text)
            % 设置状态文本
            this.StatusLabel.Text = text;
        end
    end

    methods (Hidden)
        function app = qeShow(this)
            % 用于在单元测试中测试 FooterBar，可通过下面的命令使用：
            % f = kssolv.ui.components.others.FooterBar();
            % f.qeShow();

            % 创建 AppContainer          
            appOptions.Tag = sprintf('kssolv(%s)',char(matlab.lang.internal.uuid));
            appOptions.Title = kssolv.ui.util.Localizer.message('KSSOLV:toolbox:UnitTestTitle');
            appOptions.ToolstripEnabled = true;
            app = matlab.ui.container.internal.AppContainer(appOptions);

            % 添加 FooterBar
            footerBar = kssolv.ui.components.others.FooterBar();
            footerBar.addToAppContainer(app);

            % 设定 Status Context
            statusTestContext = matlab.ui.container.internal.appcontainer.ContextDefinition();
            statusTestContext.Tag = 'kssolvTestContext';
            statusTestContext.StatusComponentTags = {this.StatusProgress.Tag, this.StatusLabel.Tag};
            app.Contexts = [app.Contexts {statusTestContext}];
            app.ActiveContexts = 'kssolvTestContext';

            % 设定 Label
            this.setText('Hello');

            % 展示界面
            app.Visible = true;
        end
    end
end
