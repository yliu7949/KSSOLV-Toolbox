classdef RelaxationTaskUI < kssolv.services.workflow.module.AbstractTaskUI
    %RELAXATIONTASKUI 与 relaxationTask 的选项相关的 UI 控件

    properties (Dependent)
        options
    end

    properties
        widgets
    end

    properties (Access = private)
        relaxationMethodValueDropdown
        relaxationToleranceEditField
        maxRelaxationIterationsSpinner
    end

    methods (Access = protected)
        function setup(this)
            % Options AccordionPanel
            this.widgets.accordionPanel1 = matlab.ui.container.internal.AccordionPanel();
            this.widgets.accordionPanel1.BackgroundColor = 'white';
            this.widgets.accordionPanel1.Title = 'Options';

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
            this.relaxationMethodValueDropdown = uidropdown(g1);
            this.relaxationMethodValueDropdown.Items = {'fminunc', 'nlcg2', ...
                'bfgs', 'fire'};
            this.relaxationMethodValueDropdown.Tooltip = relaxationMethodLabelTooltip;

            % 结构优化收敛阈值编辑框
            relaxationToleranceTooltip = 'Set relaxation tolerance';
            relaxationToleranceLabel = uilabel(g1);
            relaxationToleranceLabel.Layout.Row = 2;
            relaxationToleranceLabel.Layout.Column = 1;
            relaxationToleranceLabel.HorizontalAlignment = 'right';
            relaxationToleranceLabel.Text = "RelaxTolerance:";
            relaxationToleranceLabel.Tooltip = relaxationToleranceTooltip;

            this.relaxationToleranceEditField = uieditfield(g1, 'text');
            this.relaxationToleranceEditField.Layout.Row = 2;
            this.relaxationToleranceEditField.Layout.Column = 2;
            this.relaxationToleranceEditField.Value = '1e-2';
            this.relaxationToleranceEditField.Tooltip = relaxationToleranceTooltip;

            % 结构优化最大步数数值输入框（默认值 100）
            maxRelaxationIterationsTooltip = 'Set maximum relaxation iterations';
            maxRelaxationIterationsLabel = uilabel(g1);
            maxRelaxationIterationsLabel.Layout.Row = 3;
            maxRelaxationIterationsLabel.Layout.Column = 1;
            maxRelaxationIterationsLabel.HorizontalAlignment = 'right';
            maxRelaxationIterationsLabel.Text = "MaxRelaxSteps:";
            maxRelaxationIterationsLabel.Tooltip = maxRelaxationIterationsTooltip;

            this.maxRelaxationIterationsSpinner = uispinner(g1, 'Value', 100);
            this.maxRelaxationIterationsSpinner.Layout.Row = 3;
            this.maxRelaxationIterationsSpinner.Layout.Column = 2;
            this.maxRelaxationIterationsSpinner.Tooltip = maxRelaxationIterationsTooltip;
        end
    end

    methods
        function attachUIToAccordion(this, accordion)
            arguments
                this
                accordion matlab.ui.container.internal.Accordion
            end

            if size(accordion.Children, 1) >= 4
                if accordion.Children(3).Title == "Options"
                    % 移除旧的 Options AccordionPanel
                    accordion.Children(3).Parent = [];
                end

                if accordion.Children(3).Title == "Advanced Options"
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
            output = struct();
            output.relaxmethod = this.relaxationMethodValueDropdown.Value;
            output.relaxtol = str2double(this.relaxationToleranceEditField.Value);
            output.maxrelaxiter = this.maxRelaxationIterationsSpinner.Value;
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

