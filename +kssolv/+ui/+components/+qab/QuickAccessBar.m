classdef QuickAccessBar < handle
    %QUICKACCESSBAR 设置右上角快捷访问栏

    %   开发者：杨柳 林海饶
    %   版权 2024-2025 合肥瀚海量子科技有限公司

    properties (Access = private)
        HelpButton
        RedoButton
        UndoButton
        SaveButton
    end

    methods
        function this = QuickAccessBar()
            % 构造函数
            this.createQuickAccessBar();
        end

        function createQuickAccessBar(this)
            % 创建并配置 QuickAccessBar 相关组件

            % 创建帮助按钮，链接到 KSSOLV 帮助文档
            this.HelpButton = kssolv.ui.components.qab.QABHelpButton();

            % 创建重做按钮
            this.RedoButton = kssolv.ui.components.qab.QABRedoButton();
            this.RedoButton.ButtonPushedFcn = @(src, data) callbackRedoButton(this);

            % 创建撤销按钮
            this.UndoButton = kssolv.ui.components.qab.QABUndoButton();
            this.UndoButton.ButtonPushedFcn = @(src, data) callbackUndoButton(this);

            % 创建保存按钮
            this.SaveButton = kssolv.ui.components.qab.QABSaveButton();
            this.SaveButton.ButtonPushedFcn = @(src, data) callbackSaveButton(this);
        end

        function addToAppContainer(this, appContainer)
            appContainer.add(this.HelpButton);
            appContainer.add(this.RedoButton);
            appContainer.add(this.UndoButton);
            appContainer.add(this.SaveButton);
        end
    end

    methods (Access = private)
        function callbackRedoButton(~)
            kssolv.ui.components.figuredocument.Workflow.sendEventToWorkflowUI('workflowRedo');
        end

        function callbackUndoButton(~)
            kssolv.ui.components.figuredocument.Workflow.sendEventToWorkflowUI('workflowUndo');
        end

        function callbackSaveButton(~)
            import kssolv.ui.util.Localizer.*
            project = kssolv.ui.util.DataStorage.getData('Project');
            if ~project.isDirty
                return
            end
            ksFile = kssolv.ui.util.DataStorage.getData('ProjectFilename');
            if ksFile == ""
                % ksFile 为空说明当前未打开某个 .ks 文件，需要选择保存为 .ks 文件的路径
                [file, location] = uiputfile({'*.ks', 'KSSOLV Files (*.ks)'}, ...
                    message('KSSOLV:dialogs:SaveKSFileTitle'), 'untitled');
                if isequal(file, 0) || isequal(location, 0)
                    % 用户点击了"取消"按钮
                    kssolv.ui.util.DataStorage.getData('AppContainer').bringToFront();
                    return
                else
                    % 用户选择了具体的文件路径
                    ksFile = fullfile(location, file);
                    kssolv.ui.util.DataStorage.setData('ProjectFilename', ksFile);
                    project.saveToKsFile(ksFile);
                end
                kssolv.ui.util.DataStorage.getData('AppContainer').bringToFront();
            else
                % ksFile 不为空说明当前已打开某个 .ks 文件，直接保存文件
                project.saveToKsFile(ksFile);
            end
        end
    end

    methods (Static, Hidden)
        function app = qeShow()
            % 用于在单元测试中测试 QuickAccessBar，可通过下面的命令使用：
            % kssolv.ui.components.qab.QuickAccessBar.qeShow();

            % 创建 AppContainer
            appOptions.Tag = sprintf('kssolv(%s)',char(matlab.lang.internal.uuid));
            appOptions.Title = kssolv.ui.util.Localizer.message('KSSOLV:toolbox:UnitTestTitle');
            appOptions.ToolstripEnabled = true;
            app = matlab.ui.container.internal.AppContainer(appOptions);

            % 添加 QuickAccessBar
            quickAccessBar = kssolv.ui.components.qab.QuickAccessBar();
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