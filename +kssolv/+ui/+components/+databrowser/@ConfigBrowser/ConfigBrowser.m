classdef ConfigBrowser < matlab.ui.internal.databrowser.AbstractDataBrowser & ...
        matlab.mixin.SetGet
    %CONFIGBROWSER 自定义的 Data Browser 组件，Workflow 中工作节点具体配置的编辑器

    %   开发者：杨柳
    %   版权 2024 合肥瀚海量子科技有限公司

    properties (SetAccess = {?kssolv.ui.components.figuredocument.Workflow})
        nodeID (1, :) char
        nodeData kssolv.services.workflow.WorkflowNodeData
    end

    properties (Access = private)
        nodeIdValue
        nodeLabelValue
        nodeModuleValue
        nodeTaskValue
        accordion
        inputCheckbox
        inputTable
        environmentLabelValue
        timeLimitValue
        outputSaveCheckbox
        outputPassCheckbox
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
            % 保存 ConfigBrowser 至 DataStorage
            kssolv.ui.util.DataStorage.setData('ConfigBrowser', this);
        end

        function updateUI(this)
            this.nodeIdValue.Text = this.nodeID;
            this.nodeLabelValue.Value = this.nodeData.label;
            this.nodeModuleValue.Value = strcat(char(this.nodeData.task.module), ' Module');

            moduleType = kssolv.services.workflow.module.ModuleType(this.nodeData.task.module);
            this.nodeTaskValue.Items = kssolv.services.workflow.module.getTaskNames(moduleType);
            if ~isempty(this.nodeTaskValue.Items)
                this.nodeTaskValue.Value = this.nodeData.task.TASK_NAME;
            else
                this.nodeTaskValue.Value = {};
            end

            this.inputCheckbox.Value = this.nodeData.task.canAccessOtherTaskOutputs;
            if ~this.nodeData.task.supportParallel
                this.environmentLabelValue.Enable = false;
            else
                this.environmentLabelValue.Enable = true;
                if this.nodeData.task.supportGPU
                    this.environmentLabelValue.Items = {'None', 'GPU', 'Processes', 'Threads'};
                else
                    this.environmentLabelValue.Items = {'None', 'Processes', 'Threads'};
                end
            end
            this.timeLimitValue.Value = this.nodeData.task.executionTimeLimit;
            this.outputSaveCheckbox.Value = this.nodeData.task.saveOutputToProjectResults;
            this.outputPassCheckbox.Value = this.nodeData.task.canShareOutputWithOtherTasks;
            this.insertOptionsAccordionPanel();
        end
    end

    methods (Access = protected)
        function buildUI(this)
            % 创建网格布局
            g = uigridlayout(this.Figure);
            g.BackgroundColor = 'white';
            g.Padding = 5;
            g.RowHeight = {'fit', 'fit', '1x'};
            g.ColumnWidth = {'1x'};

            % titleLayout
            titleLayout = uigridlayout(g);
            titleLayout.BackgroundColor = 'white';
            titleLayout.Padding = 0;
            titleLayout.ColumnWidth = {'1x', 26};
            titleLayout.RowHeight = {26};

            % titleLayout 中的标题和帮助按钮
            titleLabel = uilabel(titleLayout);
            titleLabel.Text = 'Node Configuration in Workflow';
            titleLabel.FontSize = 13;
            helpButton = kssolv.ui.components.custom.CustomButton(titleLayout);
            helpButton.HorizontalAlignment = 'center';
            helpButton.LayoutBackgroundColor = 'white';
            matlab.ui.control.internal.specifyIconID(helpButton, 'help', 18);
            helpButton.Tooltip = 'Open related documentation';

            % basicLayout
            basicLayout = uigridlayout(g);
            basicLayout.BackgroundColor = 'white';
            basicLayout.Padding = 0;
            basicLayout.ColumnWidth = {103, '1x'};
            basicLayout.RowHeight = {'fit'};

            nodeId = uilabel(basicLayout);
            nodeId.HorizontalAlignment = 'right';
            nodeId.Text = "Node ID: ";
            this.nodeIdValue = uilabel(basicLayout);
            this.nodeIdValue.Text = this.nodeID;
            this.nodeIdValue.HorizontalAlignment = 'left';

            % 折叠面板
            this.accordion = matlab.ui.container.internal.Accordion('Parent', g);

            % General AccordionPanel
            accordionPanel1 = matlab.ui.container.internal.AccordionPanel('Parent', this.accordion);
            accordionPanel1.BackgroundColor = 'white';
            accordionPanel1.Title = 'General';

            g1 = uigridlayout(accordionPanel1);
            g1.BackgroundColor = 'white';
            g1.ColumnWidth = {80, '1x'};
            g1.RowHeight = {'fit', 'fit', 'fit'};

            nodeLabelTooltip = 'Tooltip';
            nodeLabel = uilabel(g1);
            nodeLabel.HorizontalAlignment = 'right';
            nodeLabel.Text = "Label: ";
            nodeLabel.Tooltip = nodeLabelTooltip;
            this.nodeLabelValue = uieditfield(g1);
            this.nodeLabelValue.Tooltip = nodeLabelTooltip;

            nodeModuleTooltip = 'Tooltip';
            nodeModule = uilabel(g1);
            nodeModule.HorizontalAlignment = 'right';
            nodeModule.Text = "Module: ";
            nodeModule.Tooltip = nodeModuleTooltip;
            this.nodeModuleValue = uidropdown(g1);
            moduleEnumMembers = enumeration('kssolv.services.workflow.module.ModuleType');
            moduleNames = arrayfun(@(x) char(x), moduleEnumMembers, 'UniformOutput', false);
            this.nodeModuleValue.Items = strcat(moduleNames, ' Module');
            this.nodeModuleValue.ValueIndex = 2;
            this.nodeModuleValue.Tooltip = nodeModuleTooltip;
            this.nodeModuleValue.ValueChangedFcn = @(src, event) this.moduleSelectionChanged(src, event);

            nodeTaskTooltip = 'Tooltip';
            nodeTask = uilabel(g1);
            nodeTask.HorizontalAlignment = 'right';
            nodeTask.Text = "Task: ";
            nodeTask.Tooltip = nodeTaskTooltip;
            this.nodeTaskValue = uidropdown(g1);
            moduleType = kssolv.services.workflow.module.ModuleType(this.nodeModuleValue.ValueIndex);
            initialTaskNames = kssolv.services.workflow.module.getTaskNames(moduleType);
            this.nodeTaskValue.Items = initialTaskNames;
            this.nodeTaskValue.Tooltip = nodeTaskTooltip;
            this.nodeTaskValue.ValueChangedFcn = @(src, event) this.taskSelectionChanged(src, event);

            % Input AccordionPanel
            accordionPanel2 = matlab.ui.container.internal.AccordionPanel('Parent', this.accordion);
            accordionPanel2.BackgroundColor = 'white';
            accordionPanel2.Title = 'Input';

            g2 = uigridlayout(accordionPanel2);
            g2.BackgroundColor = 'white';
            g2.ColumnWidth = {'1x'};
            g2.RowHeight = {'fit', 120};

            this.inputCheckbox = uicheckbox(g2, "Value", 1);
            this.inputCheckbox.Text = 'Use last node output as input';
            this.inputCheckbox.ValueChangedFcn = @(src, event) this.inputCheckBoxChanged(src, event);
            this.inputTable = kssolv.ui.components.custom.VariableTable(g2);
            this.inputTable.LayoutBackgroundColor = 'white';

            % Execution Resources AccordionPanel
            accordionPanel3 = matlab.ui.container.internal.AccordionPanel('Parent', this.accordion);
            accordionPanel3.BackgroundColor = 'white';
            accordionPanel3.Title = 'Execution Resources';

            g3 = uigridlayout(accordionPanel3);
            g3.BackgroundColor = 'white';
            g3.ColumnWidth = {80, '1x'};
            g3.RowHeight = {'fit', 'fit'};

            environmentLabelTooltip = 'Parallel environment settings';
            environmentLabel = uilabel(g3);
            environmentLabel.HorizontalAlignment = 'right';
            environmentLabel.Text = "Parallel: ";
            environmentLabel.Tooltip = environmentLabelTooltip;
            this.environmentLabelValue = uidropdown(g3);
            this.environmentLabelValue.Items = {'None', 'GPU', 'Processes', 'Threads'};
            this.environmentLabelValue.Tooltip = environmentLabelTooltip;
            this.environmentLabelValue.ValueChangedFcn = @(src, event) this.environmentSelectionChanged(src, event);

            timeLimitLabelTooltip = 'Execution time limit';
            timeLimitLabel = uilabel(g3);
            timeLimitLabel.HorizontalAlignment = 'right';
            timeLimitLabel.Text = "Time limit: ";
            timeLimitLabel.Tooltip = timeLimitLabelTooltip;
            this.timeLimitValue = uidropdown(g3);
            this.timeLimitValue.Items = {'No Limit', '30 minutes', '1 hour', '2 hours'};
            this.timeLimitValue.Tooltip = timeLimitLabelTooltip;
            this.timeLimitValue.ValueChangedFcn = @(src, event) this.timeLimitSelectionChanged(src, event);

            % Output AccordionPanel
            accordionPanel4 = matlab.ui.container.internal.AccordionPanel('Parent', this.accordion);
            accordionPanel4.BackgroundColor = 'white';
            accordionPanel4.Title = 'Output';
            accordionPanel4.collapse();

            g4 = uigridlayout(accordionPanel4);
            g4.BackgroundColor = 'white';
            g4.ColumnWidth = {'1x'};
            g4.RowHeight = {'fit', 'fit'};

            this.outputSaveCheckbox = uicheckbox(g4);
            this.outputSaveCheckbox.Text = 'Save output to Results';
            this.outputSaveCheckbox.ValueChangedFcn = @(src, event) this.outputSaveCheckboxChanged(src, event);
            this.outputPassCheckbox = uicheckbox(g4, "Value", 1);
            this.outputPassCheckbox.Text = 'Pass output to the next nodes';
            this.outputPassCheckbox.ValueChangedFcn = @(src, event) this.outputPassCheckboxChanged(src, event);

            % 插入 Options Panel 和 Advanced Options Panel
            this.insertOptionsAccordionPanel();
        end
    end

    methods (Access = private)
        function moduleSelectionChanged(this, src, ~)
            moduleType = kssolv.services.workflow.module.ModuleType(src.ValueIndex);
            taskNames = kssolv.services.workflow.module.getTaskNames(moduleType);
            this.nodeTaskValue.Items = taskNames;
            if ~isempty(taskNames)
                this.nodeTaskValue.ValueIndex = 1;
            end
            this.taskSelectionChanged(this.nodeTaskValue);
        end

        function taskSelectionChanged(this, src, ~)
            moduleType = kssolv.services.workflow.module.ModuleType(this.nodeModuleValue.ValueIndex);
            this.nodeData.task = kssolv.services.workflow.module.getTaskInstance(moduleType, src.Value);
            this.updateUI();
        end

        function inputCheckBoxChanged(this, ~, event)
            this.nodeData.task.canAccessOtherTaskOutputs = event.Value;
        end

        function environmentSelectionChanged(this, ~, event)
            this.nodeData.task.usedParallelType = event.Value;
        end

        function timeLimitSelectionChanged(this, ~, event)
            this.nodeData.task.executionTimeLimit = event.Value;
        end

        function outputSaveCheckboxChanged(this, ~, event)
            this.nodeData.task.saveOutputToProjectResults = event.Value;
        end

        function outputPassCheckboxChanged(this, ~, event)
            this.nodeData.task.canShareOutputWithOtherTasks = event.Value;
        end

        function insertOptionsAccordionPanel(this)
            if ~isempty(this.nodeData) && ~isempty(this.nodeData.task) && ~isempty(this.nodeData.task.optionsUI)
                this.nodeData.task.optionsUI.attachUIToAccordion(this.accordion);
            end
        end
    end

    methods (Hidden)
        function app = qeShow(this)
            % 用于在单元测试中测试 ConfigBrowser，可通过下面的命令使用：
            % kssolv.ui.components.databrowser.ConfigBrowser().qeShow();

            persistent appWindow
            if ~isempty(appWindow)
                delete(appWindow);
            end

            % 创建 AppContainer
            appOptions.Tag = sprintf('kssolv(%s)',char(matlab.lang.internal.uuid));
            appOptions.Title = kssolv.ui.util.Localizer.message('KSSOLV:toolbox:UnitTestTitle');
            appOptions.ToolstripEnabled = true;
            app = matlab.ui.container.internal.AppContainer(appOptions);
            appWindow = app;

            % 将 Browser 添加到 App Container
            this.addToAppContainer(app);
            % 展示界面
            app.Visible = true;
        end
    end
end

