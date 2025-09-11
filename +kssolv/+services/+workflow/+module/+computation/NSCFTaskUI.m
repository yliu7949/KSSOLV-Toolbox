classdef NSCFTaskUI < kssolv.services.workflow.module.AbstractTaskUI
    %NSCFTASKUI 与 NSCFTask 的选项相关的 UI 控件

    %   开发者：杨柳
    %   版权 2025 合肥瀚海量子科技有限公司

    properties (Dependent)
        options
    end

    properties (Transient)
        widgets
    end

    methods (Access = protected)
        function setupDefaultOptions(this)
            this.defaultOptions = struct('eigmethod', 'lobpcg', ...
                'maxcgiter', 20, 'maxphiiter', 30, 'GACE', false, 'HT', false);
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

            % eigmethod - 对角化方法
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

            % maxcgiter - 最大 CG 迭代步数
            maxCGIterationLabelTooltip = 'Maximum LOBPCG iterations';
            maxCGIterationLabel = uilabel(g1);
            maxCGIterationLabel.HorizontalAlignment = 'right';
            maxCGIterationLabel.Text = "Max CG steps: ";
            maxCGIterationLabel.Tooltip = maxCGIterationLabelTooltip;
            this.widgets.maxCGIterationValueSpinner = uispinner(g1);
            this.widgets.maxCGIterationValueSpinner.Limits = [0 300];
            this.widgets.maxCGIterationValueSpinner.Value = options.maxcgiter;
            this.widgets.maxCGIterationValueSpinner.ValueChangedFcn = @(src, event) this.markDirty();
            this.widgets.maxCGIterationValueSpinner.Tooltip = maxCGIterationLabelTooltip;

            % maxphiiter - 最大 NSCF 迭代步数
            maxPHIIterationLabelTooltip = 'Maximum NSCF iterations';
            maxPHIIterationLabel = uilabel(g1);
            maxPHIIterationLabel.HorizontalAlignment = 'right';
            maxPHIIterationLabel.Text = "Max NSCF steps: ";
            maxPHIIterationLabel.Tooltip = maxPHIIterationLabelTooltip;
            this.widgets.maxPHIIterationValueSpinner = uispinner(g1);
            this.widgets.maxPHIIterationValueSpinner.Limits = [0 300];
            this.widgets.maxPHIIterationValueSpinner.Value = options.maxphiiter;
            this.widgets.maxPHIIterationValueSpinner.ValueChangedFcn = @(src, event) this.markDirty();
            this.widgets.maxPHIIterationValueSpinner.Tooltip = maxPHIIterationLabelTooltip;

            % Advanced Options AccordionPanel
            this.widgets.accordionPanel2 = matlab.ui.container.internal.AccordionPanel();
            this.widgets.accordionPanel2.BackgroundColor = 'white';
            this.widgets.accordionPanel2.Title = message('KSSOLV:toolbox:ConfigBrowserAdvancedOptionsPanelTitle');
            this.widgets.accordionPanel2.collapse();

            g2 = uigridlayout(this.widgets.accordionPanel2);
            g2.BackgroundColor = 'white';
            g2.ColumnWidth = {120, '1x'};
            g2.RowHeight = {'fit', 'fit'};

            % 是否使用 GACE
            this.widgets.GACECheckbox = uicheckbox(g2);
            this.widgets.GACECheckbox.Layout.Row = 1;
            this.widgets.GACECheckbox.Layout.Column = 2;
            this.widgets.GACECheckbox.Text = 'Use GACE';
            this.widgets.GACECheckbox.Value = options.GACE;
            this.widgets.GACECheckbox.ValueChangedFcn = @(src, event) this.markDirty();

            % 是否使用 HT
            this.widgets.HTCheckbox = uicheckbox(g2);
            this.widgets.HTCheckbox.Layout.Row = 2;
            this.widgets.HTCheckbox.Layout.Column = 2;
            this.widgets.HTCheckbox.Text = 'Use HT';
            this.widgets.HTCheckbox.Value = options.HT;
            this.widgets.HTCheckbox.ValueChangedFcn = @(src, event) this.markDirty();
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
            this.privateOptions.maxcgiter = this.widgets.maxCGIterationValueSpinner.Value;
            this.privateOptions.maxphiiter = this.widgets.maxPHIIterationValueSpinner.Value;
            this.privateOptions.GACE = this.widgets.GACECheckbox.Value;
            this.privateOptions.HT = this.widgets.HTCheckbox.Value;
            output = this.privateOptions;
        end
    end

    methods (Hidden, Static)
        function this = qeShow(debug)
            % 用于在单元测试中测试 NSCFTaskUI，可通过下面的命令使用：
            % kssolv.services.workflow.module.computation.NSCFTaskUI.qeShow();
            arguments
                debug logical = false
            end

            accordion = kssolv.services.workflow.module.AbstractTaskUI.qeShow(debug);
            this = kssolv.services.workflow.module.computation.NSCFTaskUI();
            this.attachUIToAccordion(accordion);
        end
    end
end

