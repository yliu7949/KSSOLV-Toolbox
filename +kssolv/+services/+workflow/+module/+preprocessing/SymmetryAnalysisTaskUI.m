classdef SymmetryAnalysisTaskUI < kssolv.services.workflow.module.AbstractTaskUI
    %SYMMETRYANALYSISTASKUI 与 SymmetryAnalysisTask 的选项相关的 UI 控件

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
            this.defaultOptions = struct('symmetryThreshold', 1e-7, ...
                'symmetryPrecision', 1e-5, 'withTimeReversal', false, 'angleTolerance', -1.0);
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
            g1.RowHeight = {'fit', 'fit'};

            % symmetryThreshold - 晶格参数比较中的数值精度阈值
            symmetryThresholdTooltip = 'Threshold for numerical precision in lattice parameter comparisons';
            symmetryThresholdLabel = uilabel(g1);
            symmetryThresholdLabel.Layout.Row = 1;
            symmetryThresholdLabel.Layout.Column = 1;
            symmetryThresholdLabel.HorizontalAlignment = 'right';
            symmetryThresholdLabel.Text = "SymmetryThreshold:";
            symmetryThresholdLabel.Tooltip = symmetryThresholdTooltip;

            this.widgets.symmetryThresholdEditField = uieditfield(g1, 'text');
            this.widgets.symmetryThresholdEditField.Layout.Row = 1;
            this.widgets.symmetryThresholdEditField.Layout.Column = 2;
            this.widgets.symmetryThresholdEditField.Value = num2str(options.symmetryThreshold);
            this.widgets.symmetryThresholdEditField.ValueChangedFcn = @(src, event) this.markDirty();
            this.widgets.symmetryThresholdEditField.Tooltip = symmetryThresholdTooltip;

            % symmetryPrecision - spglib 的对称性精度
            symmetryPrecisionTooltip = 'Symmetry precision for spglib';
            symmetryPrecisionLabel = uilabel(g1);
            symmetryPrecisionLabel.Layout.Row = 2;
            symmetryPrecisionLabel.Layout.Column = 1;
            symmetryPrecisionLabel.HorizontalAlignment = 'right';
            symmetryPrecisionLabel.Text = "SymmetryPrecision:";
            symmetryPrecisionLabel.Tooltip = symmetryPrecisionTooltip;

            this.widgets.symmetryPrecisionEditField = uieditfield(g1, 'text');
            this.widgets.symmetryPrecisionEditField.Layout.Row = 2;
            this.widgets.symmetryPrecisionEditField.Layout.Column = 2;
            this.widgets.symmetryPrecisionEditField.Value = num2str(options.symmetryPrecision);
            this.widgets.symmetryPrecisionEditField.ValueChangedFcn = @(src, event) this.markDirty();
            this.widgets.symmetryPrecisionEditField.Tooltip = symmetryPrecisionTooltip;

            % Advanced Options AccordionPanel
            this.widgets.accordionPanel2 = matlab.ui.container.internal.AccordionPanel();
            this.widgets.accordionPanel2.BackgroundColor = 'white';
            this.widgets.accordionPanel2.Title = message('KSSOLV:toolbox:ConfigBrowserAdvancedOptionsPanelTitle');
            this.widgets.accordionPanel2.collapse();

            g2 = uigridlayout(this.widgets.accordionPanel2);
            g2.BackgroundColor = 'white';
            g2.ColumnWidth = {120, '1x'};
            g2.RowHeight = {'fit', 'fit'};

            % withTimeReversal - 是否在计算路径时考虑时间反演对称性
            withTimeReversalCheckboxTooltip = 'Whether to include time-reversal symmetry in the path calculation';
            this.widgets.withTimeReversalCheckbox = uicheckbox(g2);
            this.widgets.withTimeReversalCheckbox.Layout.Row = 1;
            this.widgets.withTimeReversalCheckbox.Layout.Column = 2;
            this.widgets.withTimeReversalCheckbox.Text = 'WithTimeReversal';
            this.widgets.withTimeReversalCheckbox.Tooltip = withTimeReversalCheckboxTooltip;
            this.widgets.withTimeReversalCheckbox.Value = options.withTimeReversal;
            this.widgets.withTimeReversalCheckbox.ValueChangedFcn = @(src, event) this.markDirty();

            % angleTolerance - spglib 的 angle_tolerance（如果设置为 -1 则不使用）
            angleToleranceTooltip = 'Angle tolerance for spglib (typically unused if set to -1)';
            angleToleranceLabel = uilabel(g2);
            angleToleranceLabel.Layout.Row = 2;
            angleToleranceLabel.Layout.Column = 1;
            angleToleranceLabel.HorizontalAlignment = 'right';
            angleToleranceLabel.Text = "AngleTolerance:";
            angleToleranceLabel.Tooltip = angleToleranceTooltip;

            this.widgets.angleToleranceEditField = uieditfield(g2, 'text');
            this.widgets.angleToleranceEditField.Layout.Row = 2;
            this.widgets.angleToleranceEditField.Layout.Column = 2;
            this.widgets.angleToleranceEditField.Value = num2str(options.angleTolerance);
            this.widgets.angleToleranceEditField.ValueChangedFcn = @(src, event) this.markDirty();
            this.widgets.angleToleranceEditField.Tooltip = angleToleranceTooltip;
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
            this.privateOptions.symmetryThreshold = str2double(this.widgets.symmetryThresholdEditField.Value);
            this.privateOptions.symmetryPrecision = str2double(this.widgets.symmetryPrecisionEditField.Value);
            this.privateOptions.withTimeReversal = this.widgets.withTimeReversalCheckbox.Value;
            this.privateOptions.angleTolerance = str2double(this.widgets.angleToleranceEditField.Value);

            output = this.privateOptions;
        end
    end

    methods (Hidden, Static)
        function this = qeShow(debug)
            % 用于在单元测试中测试 SymmetryAnalysisTaskUI，可通过下面的命令使用：
            % kssolv.services.workflow.module.preprocessing.SymmetryAnalysisTaskUI.qeShow();
            arguments
                debug logical = false
            end

            accordion = kssolv.services.workflow.module.AbstractTaskUI.qeShow(debug);
            this = kssolv.services.workflow.module.preprocessing.SymmetryAnalysisTaskUI();
            this.attachUIToAccordion(accordion);
        end
    end
end

