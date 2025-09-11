classdef BandProcessingTaskUI < kssolv.services.workflow.module.AbstractTaskUI
    %BANDPROCESSINGTASKUI 与 BandProcessingTask 的选项相关的 UI 控件

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
            this.defaultOptions = struct('numInterpolationPoints', 20);
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
            g1.RowHeight = {'fit'};

            % numInterpolationPoints - 每个高对称点路径分段上的总采样点数量（包括此路径分段的起点和终点两个高对称点）
            numInterpolationPointsLabelTooltip = 'Number of points for each path segment (including the endpoints)';
            numInterpolationPointsLabel = uilabel(g1);
            numInterpolationPointsLabel.HorizontalAlignment = 'right';
            numInterpolationPointsLabel.Text = "Segment Points: ";
            numInterpolationPointsLabel.Tooltip = numInterpolationPointsLabelTooltip;
            this.widgets.numInterpolationPointsValueSpinner = uispinner(g1);
            this.widgets.numInterpolationPointsValueSpinner.Limits = [0 100];
            this.widgets.numInterpolationPointsValueSpinner.Value = options.numInterpolationPoints;
            this.widgets.numInterpolationPointsValueSpinner.ValueChangedFcn = @(src, event) this.markDirty();
            this.widgets.numInterpolationPointsValueSpinner.Tooltip = numInterpolationPointsLabelTooltip;
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
            this.privateOptions.numInterpolationPoints = this.widgets.numInterpolationPointsValueSpinner.Value;
            this.isDirty = false;

            output = this.privateOptions;
        end
    end

    methods (Hidden, Static)
        function this = qeShow(debug)
            % 用于在单元测试中测试 BandProcessingTaskUI，可通过下面的命令使用：
            % kssolv.services.workflow.module.postprocessing.BandProcessingTaskUI.qeShow();
            arguments
                debug logical = false
            end

            accordion = kssolv.services.workflow.module.AbstractTaskUI.qeShow(debug);
            this = kssolv.services.workflow.module.postprocessing.BandProcessingTaskUI();
            this.attachUIToAccordion(accordion);
        end
    end
end

