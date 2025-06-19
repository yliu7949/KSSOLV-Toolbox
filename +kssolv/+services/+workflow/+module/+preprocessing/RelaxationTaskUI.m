classdef RelaxationTaskUI < kssolv.services.workflow.module.AbstractTaskUI
    %RELAXATIONTASKUI 与 relaxationTask 的选项相关的 UI 控件

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
            this.defaultOptions = struct('relaxmethod', 'fminunc', ...
                'relaxtol', 1e-2, 'maxrelaxiter', 100);
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

            % 结构优化方法
            relaxationMethodLabelTooltip = 'Relaxation method';
            relaxationMethodLabel = uilabel(g1);
            relaxationMethodLabel.HorizontalAlignment = 'right';
            relaxationMethodLabel.Text = "RelaxMethod: ";
            relaxationMethodLabel.Tooltip = relaxationMethodLabelTooltip;
            this.widgets.relaxationMethodValueDropdown = uidropdown(g1);
            this.widgets.relaxationMethodValueDropdown.Items = {'fminunc', 'nlcg2', ...
                'bfgs', 'fire'};
            this.widgets.relaxationMethodValueDropdown.Value = options.relaxmethod;
            this.widgets.relaxationMethodValueDropdown.ValueChangedFcn = @(src, event) this.markDirty();
            this.widgets.relaxationMethodValueDropdown.Tooltip = relaxationMethodLabelTooltip;

            % 结构优化收敛阈值编辑框
            relaxationToleranceTooltip = 'Set relaxation tolerance';
            relaxationToleranceLabel = uilabel(g1);
            relaxationToleranceLabel.Layout.Row = 2;
            relaxationToleranceLabel.Layout.Column = 1;
            relaxationToleranceLabel.HorizontalAlignment = 'right';
            relaxationToleranceLabel.Text = "RelaxTolerance:";
            relaxationToleranceLabel.Tooltip = relaxationToleranceTooltip;

            this.widgets.relaxationToleranceEditField = uieditfield(g1, 'text');
            this.widgets.relaxationToleranceEditField.Layout.Row = 2;
            this.widgets.relaxationToleranceEditField.Layout.Column = 2;
            this.widgets.relaxationToleranceEditField.Value = num2str(options.relaxtol);
            this.widgets.relaxationToleranceEditField.ValueChangedFcn = @(src, event) this.markDirty();
            this.widgets.relaxationToleranceEditField.Tooltip = relaxationToleranceTooltip;

            % 结构优化最大步数数值输入框（默认值 100）
            maxRelaxationIterationsTooltip = 'Set maximum relaxation iterations';
            maxRelaxationIterationsLabel = uilabel(g1);
            maxRelaxationIterationsLabel.Layout.Row = 3;
            maxRelaxationIterationsLabel.Layout.Column = 1;
            maxRelaxationIterationsLabel.HorizontalAlignment = 'right';
            maxRelaxationIterationsLabel.Text = "MaxRelaxSteps:";
            maxRelaxationIterationsLabel.Tooltip = maxRelaxationIterationsTooltip;

            this.widgets.maxRelaxationIterationsSpinner = uispinner(g1);
            this.widgets.maxRelaxationIterationsSpinner.Layout.Row = 3;
            this.widgets.maxRelaxationIterationsSpinner.Layout.Column = 2;
            this.widgets.maxRelaxationIterationsSpinner.Value = options.maxrelaxiter;
            this.widgets.maxRelaxationIterationsSpinner.ValueChangedFcn = @(src, event) this.markDirty();
            this.widgets.maxRelaxationIterationsSpinner.Tooltip = maxRelaxationIterationsTooltip;
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

            % 将 accordionPanel 添加到 accordion
            if isempty(accordion.Children)
                this.widgets.accordionPanel1.Parent = accordion;
            elseif size(accordion.Children, 1) >= 3
                existingPanels = accordion.Children;

                for i = 1:numel(existingPanels)
                    existingPanels(i).Parent = [];
                end

                existingPanels(1).Parent = accordion;
                existingPanels(2).Parent = accordion;
                this.widgets.accordionPanel1.Parent = accordion;

                for i = 3:numel(existingPanels)
                    existingPanels(i).Parent = accordion;
                end
            end
        end

        function detachUIFromAccordion(this)
            this.widgets.accordionPanel1.Parent = [];
        end

        function output = get.options(this)
            % 获取控件对应的值
            this.privateOptions.relaxmethod = this.widgets.relaxationMethodValueDropdown.Value;
            this.privateOptions.relaxtol = str2double(this.widgets.relaxationToleranceEditField.Value);
            this.privateOptions.maxrelaxiter = this.widgets.maxRelaxationIterationsSpinner.Value;
            this.isDirty = false;

            output = this.privateOptions;
        end
    end

    methods (Hidden, Static)
        function this = qeShow(debug)
            % 用于在单元测试中测试 RelaxationTaskUI，可通过下面的命令使用：
            % kssolv.services.workflow.module.preprocessing.RelaxationTaskUI.qeShow();
            arguments
                debug logical = false
            end

            accordion = kssolv.services.workflow.module.AbstractTaskUI.qeShow(debug);
            this = kssolv.services.workflow.module.preprocessing.RelaxationTaskUI();
            this.attachUIToAccordion(accordion);
        end
    end
end

