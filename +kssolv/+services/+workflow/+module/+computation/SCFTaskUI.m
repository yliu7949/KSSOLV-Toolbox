classdef SCFTaskUI < kssolv.services.workflow.module.AbstractTaskUI
    %SCFTASKUI 与 SCFTask 的选项相关的 UI 控件

    %   开发者：杨柳
    %   版权 2024-2025 合肥瀚海量子科技有限公司

    properties (Dependent)
        options
    end

    properties (Transient)
        widgets
    end

    methods (Access = protected)
        function setupDefaultOptions(this)
            this.defaultOptions = struct('eigmethod', 'davidson_qe', ...
                'maxscfiter', 100, 'force', false, 'exxmethod', 'default');
        end

        function setup(this, options)
            arguments
                this
                options (1, 1) struct = this.defaultOptions
            end

            import kssolv.ui.util.Localizer.*

            % Options AccordionPanel
            this.widgets.accordionPanel1 = matlab.ui.container.internal.AccordionPanel();
            this.widgets.accordionPanel1.BackgroundColor = 'white';
            this.widgets.accordionPanel1.Title = message('KSSOLV:toolbox:ConfigBrowserOptionsPanelTitle');

            g1 = uigridlayout(this.widgets.accordionPanel1);
            g1.BackgroundColor = 'white';
            g1.ColumnWidth = {120, '1x'};
            g1.RowHeight = {'fit', 'fit', 'fit'};

            % 对角化方法
            eigMethodLabelTooltip = 'Iterative diagonalization method';
            eigMethodLabel = uilabel(g1);
            eigMethodLabel.HorizontalAlignment = 'right';
            eigMethodLabel.Text = "DiagMethod: ";
            eigMethodLabel.Tooltip = eigMethodLabelTooltip;
            this.widgets.eigMethodValueDropdown = uidropdown(g1);
            this.widgets.eigMethodValueDropdown.Items = {'davidson_qe', 'lobpcg', ...
                'eigs', 'ppcg', 'davidson', 'davidson2', 'davpcg'};
            this.widgets.eigMethodValueDropdown.Value = options.eigmethod;
            this.widgets.eigMethodValueDropdown.ValueChangedFcn = @(src, event) this.markDirty();
            this.widgets.eigMethodValueDropdown.Tooltip = eigMethodLabelTooltip;

            % 最大迭代步数
            maxSCFIterationLabelTooltip = 'Max SCF iteration steps';
            maxSCFIterationLabel = uilabel(g1);
            maxSCFIterationLabel.HorizontalAlignment = 'right';
            maxSCFIterationLabel.Text = "Max SCF steps: ";
            maxSCFIterationLabel.Tooltip = maxSCFIterationLabelTooltip;
            this.widgets.maxSCFIterationValueSpinner = uispinner(g1);
            this.widgets.maxSCFIterationValueSpinner.Limits = [0 300];
            this.widgets.maxSCFIterationValueSpinner.Value = options.maxscfiter;
            this.widgets.maxSCFIterationValueSpinner.ValueChangedFcn = @(src, event) this.markDirty();
            this.widgets.maxSCFIterationValueSpinner.Tooltip = maxSCFIterationLabelTooltip;

            % 是否计算力
            this.widgets.forceComputeCheckbox = uicheckbox(g1);
            this.widgets.forceComputeCheckbox.Layout.Row = 3;
            this.widgets.forceComputeCheckbox.Layout.Column = 2;
            this.widgets.forceComputeCheckbox.Text = 'Calculate force';
            this.widgets.forceComputeCheckbox.Value = options.force;
            this.widgets.forceComputeCheckbox.ValueChangedFcn = @(src, event) this.markDirty();

            % Advanced Options AccordionPanel
            this.widgets.accordionPanel2 = matlab.ui.container.internal.AccordionPanel();
            this.widgets.accordionPanel2.BackgroundColor = 'white';
            this.widgets.accordionPanel2.Title = message('KSSOLV:toolbox:ConfigBrowserAdvancedOptionsPanelTitle');
            this.widgets.accordionPanel2.collapse();

            g2 = uigridlayout(this.widgets.accordionPanel2);
            g2.BackgroundColor = 'white';
            g2.ColumnWidth = {120, '1x'};
            g2.RowHeight = {'fit'};

            % 计算杂化泛函的方法
            exxMethodLabelTooltip = 'Method to calculate hybrid functional';
            exxMethodLabel = uilabel(g2);
            exxMethodLabel.HorizontalAlignment = 'right';
            exxMethodLabel.Text = "ExxMethod: ";
            exxMethodLabel.Tooltip = exxMethodLabelTooltip;
            this.widgets.exxMethodValueDropdown = uidropdown(g2);
            this.widgets.exxMethodValueDropdown.Items = {'ace', 'normal', 'default', 'qrcp', 'kmeans'};
            this.widgets.exxMethodValueDropdown.Value = options.exxmethod;
            this.widgets.exxMethodValueDropdown.ValueChangedFcn = @(src, event) this.markDirty();
            this.widgets.exxMethodValueDropdown.Tooltip = exxMethodLabelTooltip;
        end
    end

    methods
        function attachUIToAccordion(this, accordion)
            arguments
                this
                accordion matlab.ui.container.internal.Accordion
            end

            import kssolv.ui.util.Localizer.*

            if size(accordion.Children, 1) >= 4
                if strcmp(accordion.Children(3).Title, message('KSSOLV:toolbox:ConfigBrowserOptionsPanelTitle'))
                    % 移除旧的 Options AccordionPanel
                    accordion.Children(3).Parent = [];
                end

                if strcmp(accordion.Children(3).Title, message('KSSOLV:toolbox:ConfigBrowserAdvancedOptionsPanelTitle'))
                    % 移除旧的 Advanced Options AccordionPanel，注意在 Children 中的位置仍然是第三个
                    accordion.Children(3).Parent = [];
                end
            end

            % 将两个 accordionPanel 添加到 accordion
            if isempty(accordion.Children)
                this.widgets.accordionPanel1.Parent = accordion;
                this.widgets.accordionPanel2.Parent = accordion;
            elseif size(accordion.Children, 1) >= 3
                existingPanels = accordion.Children;

                for i = 1:numel(existingPanels)
                    existingPanels(i).Parent = [];
                end

                existingPanels(1).Parent = accordion;
                existingPanels(2).Parent = accordion;
                this.widgets.accordionPanel1.Parent = accordion;
                this.widgets.accordionPanel2.Parent = accordion;

                for i = 3:numel(existingPanels)
                    existingPanels(i).Parent = accordion;
                end
            end
        end

        function detachUIFromAccordion(this)
            this.widgets.accordionPanel1.Parent = [];
            this.widgets.accordionPanel2.Parent = [];
        end

        function output = get.options(this)
            % 获取控件对应的值
            this.privateOptions.eigmethod = this.widgets.eigMethodValueDropdown.Value;
            this.privateOptions.maxscfiter = this.widgets.maxSCFIterationValueSpinner.Value;
            this.privateOptions.force = this.widgets.forceComputeCheckbox.Value;
            this.privateOptions.exxmethod = this.widgets.exxMethodValueDropdown.Value;
            output = this.privateOptions;
        end
    end

    methods (Hidden, Static)
        function this = qeShow(debug)
            % 用于在单元测试中测试 SCFTaskUI，可通过下面的命令使用：
            % kssolv.services.workflow.module.computation.SCFTaskUI.qeShow();
            arguments
                debug logical = false
            end

            accordion = kssolv.services.workflow.module.AbstractTaskUI.qeShow(debug);
            this = kssolv.services.workflow.module.computation.SCFTaskUI();
            this.attachUIToAccordion(accordion);
        end
    end
end

