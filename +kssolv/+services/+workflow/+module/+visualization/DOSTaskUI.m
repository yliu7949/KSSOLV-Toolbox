classdef DOSTaskUI < kssolv.services.workflow.module.AbstractTaskUI
    %DOSTASKUI 与 DOSTask 的选项相关的 UI 控件

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
            this.defaultOptions = struct('NSCFGrid', [8 8 8], ...
                'startEnergy', -5, 'endEnergy', 9.5, 'stepSize', 0.01);
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
            g1.RowHeight = {'fit', 'fit', 'fit', 'fit'};

            % NSCFGrid - NSCF KPoints Grid
            NSCFGridTooltip = 'Set NSCF kPoints Grid';
            NSCFGridLabel = uilabel(g1);
            NSCFGridLabel.Layout.Row = 1;
            NSCFGridLabel.Layout.Column = 1;
            NSCFGridLabel.HorizontalAlignment = 'right';
            NSCFGridLabel.Text = "NSCF Grid:";
            NSCFGridLabel.Tooltip = NSCFGridTooltip;

            this.widgets.NSCFGridEditField = uieditfield(g1, 'text');
            this.widgets.NSCFGridEditField.Layout.Row = 1;
            this.widgets.NSCFGridEditField.Layout.Column = 2;
            this.widgets.NSCFGridEditField.Value = mat2str(options.NSCFGrid);
            this.widgets.NSCFGridEditField.ValueChangedFcn = @(src, event) this.markDirty();
            this.widgets.NSCFGridEditField.Tooltip = NSCFGridTooltip;

            % startEnergy - 能量范围的开始值
            startEnergyTooltip = 'Start energy in eV. Must be smaller than end energy.';
            startEnergyLabel = uilabel(g1);
            startEnergyLabel.Layout.Row = 2;
            startEnergyLabel.Layout.Column = 1;
            startEnergyLabel.HorizontalAlignment = 'right';
            startEnergyLabel.Text = "Start Energy (ev):";
            startEnergyLabel.Tooltip = startEnergyTooltip;

            this.widgets.startEnergySpinner = uispinner(g1, "Step", 0.1);
            this.widgets.startEnergySpinner.Layout.Row = 2;
            this.widgets.startEnergySpinner.Layout.Column = 2;
            this.widgets.startEnergySpinner.Value = options.startEnergy;
            this.widgets.startEnergySpinner.ValueChangedFcn = @(src, event) this.markDirty();
            this.widgets.startEnergySpinner.Tooltip = startEnergyTooltip;

            % endEnergy - 能量范围的结束值
            endEnergyTooltip = 'End energy in eV. Must be greater than start energy.';
            endEnergyLabel = uilabel(g1);
            endEnergyLabel.Layout.Row = 3;
            endEnergyLabel.Layout.Column = 1;
            endEnergyLabel.HorizontalAlignment = 'right';
            endEnergyLabel.Text = "End Energy (ev):";
            endEnergyLabel.Tooltip = endEnergyTooltip;

            this.widgets.endEnergySpinner = uispinner(g1, "Step", 0.1);
            this.widgets.endEnergySpinner.Layout.Row = 3;
            this.widgets.endEnergySpinner.Layout.Column = 2;
            this.widgets.endEnergySpinner.Value = options.endEnergy;
            this.widgets.endEnergySpinner.ValueChangedFcn = @(src, event) this.markDirty();
            this.widgets.endEnergySpinner.Tooltip = endEnergyTooltip;

            % stepSize - 能量步长的数值输入框（默认值 0.01）
            energyStepSizeTooltip = 'Energy step size in eV. Smaller steps = higher resolution. Default: 0.01';
            energyStepSizeLabel = uilabel(g1);
            energyStepSizeLabel.Layout.Row = 4;
            energyStepSizeLabel.Layout.Column = 1;
            energyStepSizeLabel.HorizontalAlignment = 'right';
            energyStepSizeLabel.Text = "Energy Step Size:";
            energyStepSizeLabel.Tooltip = energyStepSizeTooltip;

            this.widgets.energyStepSizeSpinner = uispinner(g1, "Step", 0.01);
            this.widgets.energyStepSizeSpinner.Layout.Row = 4;
            this.widgets.energyStepSizeSpinner.Layout.Column = 2;
            this.widgets.energyStepSizeSpinner.Value = options.stepSize;
            this.widgets.energyStepSizeSpinner.ValueChangedFcn = @(src, event) this.markDirty();
            this.widgets.energyStepSizeSpinner.Tooltip = energyStepSizeTooltip;
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
            this.privateOptions.NSCFGrid = str2num(this.widgets.NSCFGridEditField.Value); %#ok<*ST2NM>
            this.privateOptions.startEnergy = this.widgets.startEnergySpinner.Value;
            this.privateOptions.endEnergy = this.widgets.endEnergySpinner.Value;
            this.privateOptions.stepSize = this.widgets.energyStepSizeSpinner.Value;
            this.isDirty = false;

            output = this.privateOptions;
        end
    end

    methods (Hidden, Static)
        function this = qeShow(debug)
            % 用于在单元测试中测试 DOSTaskUI，可通过下面的命令使用：
            % kssolv.services.workflow.module.visualization.DOSTaskUI.qeShow();
            arguments
                debug logical = false
            end

            accordion = kssolv.services.workflow.module.AbstractTaskUI.qeShow(debug);
            this = kssolv.services.workflow.module.visualization.DOSTaskUI();
            this.attachUIToAccordion(accordion);
        end
    end
end



