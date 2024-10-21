classdef SCFTaskUI < kssolv.services.workflow.module.AbstractTaskUI
    %SCFTASKUI 与 SCFTask 的选项相关的 UI 控件

    properties (Dependent)
        options
    end

    properties (Access = private)
        eigMethodValueDropdown
        maxSCFIterationValueSpinner
        forceComputeCheckbox
        exxMethodValueDropdown
    end

    methods
        function this = setup(this, accordion)
            arguments
                this
                accordion matlab.ui.container.internal.Accordion
            end

            if size(accordion.Children, 1) >= 4
                if accordion.Children(3).Title == "Options"
                    % 删除旧的 Options AccordionPanel
                    delete(accordion.Children(3));
                end

                if accordion.Children(3).Title == "Advanced Options"
                    % 删除旧的 Advanced Options AccordionPanel，注意在 Children 中的位置仍然是第三个
                    delete(accordion.Children(3));
                end
            end

            % Options AccordionPanel
            accordionPanel1 = matlab.ui.container.internal.AccordionPanel();
            accordionPanel1.BackgroundColor = 'white';
            accordionPanel1.Title = 'Options';

            g1 = uigridlayout(accordionPanel1);
            g1.BackgroundColor = 'white';
            g1.ColumnWidth = {120, '1x'};
            g1.RowHeight = {'fit', 'fit', 'fit'};

            % 对角化方法
            eigMethodLabelTooltip = 'Iterative diagonalization method';
            eigMethodLabel = uilabel(g1);
            eigMethodLabel.HorizontalAlignment = 'right';
            eigMethodLabel.Text = "DiagMethod: ";
            eigMethodLabel.Tooltip = eigMethodLabelTooltip;
            this.eigMethodValueDropdown = uidropdown(g1);
            this.eigMethodValueDropdown.Items = {'davidson_qe', 'lobpcg', ...
                'eigs', 'ppcg', 'davidson', 'davidson2', 'davpcg'};
            this.eigMethodValueDropdown.Tooltip = eigMethodLabelTooltip;

            % 最大迭代步数
            maxSCFIterationLabelTooltip = 'Max SCF iteration steps';
            maxSCFIterationLabel = uilabel(g1);
            maxSCFIterationLabel.HorizontalAlignment = 'right';
            maxSCFIterationLabel.Text = "Max SCF steps: ";
            maxSCFIterationLabel.Tooltip = maxSCFIterationLabelTooltip;
            this.maxSCFIterationValueSpinner = uispinner(g1);
            this.maxSCFIterationValueSpinner.Limits = [0 300];
            this.maxSCFIterationValueSpinner.Value = 100;
            this.eigMethodValueDropdown.Tooltip = maxSCFIterationLabelTooltip;

            % 是否计算力
            this.forceComputeCheckbox = uicheckbox(g1);
            this.forceComputeCheckbox.Layout.Row = 3;
            this.forceComputeCheckbox.Layout.Column = 2;
            this.forceComputeCheckbox.Text = 'Calculate force';

            % Advanced Options AccordionPanel
            accordionPanel2 = matlab.ui.container.internal.AccordionPanel();
            accordionPanel2.BackgroundColor = 'white';
            accordionPanel2.Title = 'Advanced Options';
            accordionPanel2.collapse();

            g2 = uigridlayout(accordionPanel2);
            g2.BackgroundColor = 'white';
            g2.ColumnWidth = {120, '1x'};
            g2.RowHeight = {'fit'};

            % 计算杂化泛函的方法
            exxMethodLabelTooltip = 'Method to calculate hybrid functional';
            exxMethodLabel = uilabel(g2);
            exxMethodLabel.HorizontalAlignment = 'right';
            exxMethodLabel.Text = "ExxMethod: ";
            exxMethodLabel.Tooltip = exxMethodLabelTooltip;
            this.exxMethodValueDropdown = uidropdown(g2);
            this.exxMethodValueDropdown.Items = {'ace', 'normal', 'default', 'qrcp', 'kmeans'};
            this.exxMethodValueDropdown.Tooltip = exxMethodLabelTooltip;

            % 将两个 accordionPanel 添加到 accordion
            if isempty(accordion.Children)
                accordionPanel1.Parent = accordion;
                accordionPanel2.Parent = accordion;
            elseif size(accordion.Children, 1) >= 3
                existingPanels = accordion.Children;

                for i = 1:numel(existingPanels)
                    existingPanels(i).Parent = [];
                end

                existingPanels(1).Parent = accordion;
                existingPanels(2).Parent = accordion;
                accordionPanel1.Parent = accordion;
                accordionPanel2.Parent = accordion;

                for i = 3:numel(existingPanels)
                    existingPanels(i).Parent = accordion;
                end
            end
        end

        function output = get.options(this)
            % 获取控件对应的值
            output = struct();
            output.eigmethod = this.eigMethodValueDropdown.Value;
            output.maxscfiter = this.maxSCFIterationValueSpinner.Value;
            output.force = this.forceComputeCheckbox.Value;
            output.exxmethod = this.exxMethodValueDropdown.Value;
        end
    end

    methods (Hidden, Static)
        function qeShow(debug)
            % 用于在单元测试中测试 BuildMoleculeTaskUI，可通过下面的命令使用：
            % kssolv.services.workflow.module.computation.BuildMoleculeTaskUI.qeShow();
            arguments
                debug logical = false
            end

            accordion = kssolv.services.workflow.module.AbstractTaskUI.qeShow(debug);
            kssolv.services.workflow.module.computation.SCFTaskUI(accordion);
        end
    end
end

