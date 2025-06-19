classdef QuickAccessBar < handle
    %QUICKACCESSBAR 设置右上角快捷访问栏

    %   开发者：杨柳 林海饶
    %   版权 2024-2025 合肥瀚海量子科技有限公司

    properties (Access = private)
        HelpButton
        RedoButton
        UndoButton
    end

    methods
        function this = QuickAccessBar()
            % 构造函数
            this.createQuickAccessBar();
        end

        function createQuickAccessBar(this)
            % 创建并配置 QuickAccessBar 相关组件

            % 添加帮助按钮，链接到 KSSOLV 帮助文档
            this.HelpButton = matlab.ui.internal.toolstrip.qab.QABHelpButton();
            % this.HelpButton.ButtonPushedFcn = @(varargin) doc('kssolv');

            this.RedoButton = matlab.ui.internal.toolstrip.qab.QABRedoButton();
            this.RedoButton.ButtonPushedFcn = @(varargin) disp('Redo called!');

            this.UndoButton = matlab.ui.internal.toolstrip.qab.QABUndoButton();
            this.UndoButton.ButtonPushedFcn = @(varargin) disp('Undo called!');
        end

        function addToAppContainer(this, appContainer)
            appContainer.add(this.HelpButton);
            appContainer.add(this.RedoButton);
            appContainer.add(this.UndoButton);
        end
    end

    methods (Static, Hidden)
        function app = qeShow()
            % 用于在单元测试中测试 QuickAccessBar，可通过下面的命令使用：
            % kssolv.ui.components.others.QuickAccessBar.qeShow();

            % 创建 AppContainer
            appOptions.Tag = sprintf('kssolv(%s)',char(matlab.lang.internal.uuid));
            appOptions.Title = kssolv.ui.util.Localizer.message('KSSOLV:toolbox:UnitTestTitle');
            appOptions.ToolstripEnabled = true;
            app = matlab.ui.container.internal.AppContainer(appOptions);

            % 添加 QuickAccessBar
            quickAccessBar = kssolv.ui.components.others.QuickAccessBar();
            quickAccessBar.addToAppContainer(app)

            % 设定 Status Context
            statusTestContext = matlab.ui.container.internal.appcontainer.ContextDefinition();
            statusTestContext.Tag = 'kssolvTestContext';
            statusTestContext.StatusComponentTags = {quickAccessBar.HelpButton.Tag};
            app.Contexts = [app.Contexts {statusTestContext}];

            % 设定 Active Context
            app.ActiveContexts = 'kssolvTestContext';

            % 展示界面
            app.Visible = true;
        end
    end
end