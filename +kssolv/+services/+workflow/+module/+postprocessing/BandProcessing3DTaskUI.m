classdef BandProcessing3DTaskUI < kssolv.services.workflow.module.AbstractTaskUI
    %BANDPROCESSING3DTASKUI 与 BandProcessing3DTask 的选项相关的 UI 控件

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
            this.defaultOptions = struct('centerKPoint', [0,0,0], ...
                'slicePlane', "XY", 'slicePlaneGrid', [5,5], 'sliceGridSpacing', 0.015);
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

            % centerKPoint - 切片平面的中心 KPoint 的坐标，定位切片平面的位置，默认为 Gamma 点
            centerKPointLabelTooltip = 'Coordinates of the center KPoint of the slice plane';
            centerKPointLabel = uilabel(g1);
            centerKPointLabel.Layout.Row = 1;
            centerKPointLabel.Layout.Column = 1;
            centerKPointLabel.HorizontalAlignment = 'right';
            centerKPointLabel.Text = "Center KPoint: ";
            centerKPointLabel.Tooltip = centerKPointLabelTooltip;

            this.widgets.centerKPointValueEditField = uieditfield(g1, 'text');
            this.widgets.centerKPointValueEditField.Layout.Row = 1;
            this.widgets.centerKPointValueEditField.Layout.Column = 2;
            this.widgets.centerKPointValueEditField.Value = mat2str(options.centerKPoint);
            this.widgets.centerKPointValueEditField.ValueChangedFcn = @(src, event) this.markDirty();
            this.widgets.centerKPointValueEditField.Tooltip = centerKPointLabelTooltip;

            % slicePlane - 指定切片平面
            slicePlaneLabelTooltip = 'Specify Slice Plane';
            slicePlaneLabel = uilabel(g1);
            slicePlaneLabel.Layout.Row = 2;
            slicePlaneLabel.Layout.Column = 1;
            slicePlaneLabel.HorizontalAlignment = 'right';
            slicePlaneLabel.Text = "Slice Plane: ";
            slicePlaneLabel.Tooltip = slicePlaneLabelTooltip;

            this.widgets.slicePlaneDropdown = uidropdown(g1, 'Items', {'XY', 'XZ', 'YZ'});
            this.widgets.slicePlaneDropdown.Layout.Row = 2;
            this.widgets.slicePlaneDropdown.Layout.Column = 2;
            this.widgets.slicePlaneDropdown.Value = options.slicePlane;
            this.widgets.slicePlaneDropdown.ValueChangedFcn = @(src, event) this.markDirty();
            this.widgets.slicePlaneDropdown.Tooltip = slicePlaneLabelTooltip;

            % slicePlaneGrid - 切片平面的网格尺寸
            slicePlaneGridLabelTooltip = 'Grid size of the slice plane';
            slicePlaneGridLabel = uilabel(g1);
            slicePlaneGridLabel.Layout.Row = 3;
            slicePlaneGridLabel.Layout.Column = 1;
            slicePlaneGridLabel.HorizontalAlignment = 'right';
            slicePlaneGridLabel.Text = "Slice Plane Grid: ";
            slicePlaneGridLabel.Tooltip = slicePlaneGridLabelTooltip;

            this.widgets.slicePlaneGridValueEditField = uieditfield(g1, 'text');
            this.widgets.slicePlaneGridValueEditField.Layout.Row = 3;
            this.widgets.slicePlaneGridValueEditField.Layout.Column = 2;
            this.widgets.slicePlaneGridValueEditField.Value = mat2str(options.slicePlaneGrid);
            this.widgets.slicePlaneGridValueEditField.ValueChangedFcn = @(src, event) this.markDirty();
            this.widgets.slicePlaneGridValueEditField.Tooltip = slicePlaneGridLabelTooltip;

            % sliceGridSpacing - 切片平面的网格尺寸间隔
            sliceGridSpacingTooltip = 'Grid spacing of the slice plane';
            sliceGridSpacingLabel = uilabel(g1);
            sliceGridSpacingLabel.Layout.Row = 4;
            sliceGridSpacingLabel.Layout.Column = 1;
            sliceGridSpacingLabel.HorizontalAlignment = 'right';
            sliceGridSpacingLabel.Text = "Plane Grid Spacing: ";
            sliceGridSpacingLabel.Tooltip = sliceGridSpacingTooltip;

            this.widgets.sliceGridSpacingSpinner = uispinner(g1, "Step", 0.005, "Limits", [0 Inf]);
            this.widgets.sliceGridSpacingSpinner.Layout.Row = 4;
            this.widgets.sliceGridSpacingSpinner.Layout.Column = 2;
            this.widgets.sliceGridSpacingSpinner.Value = options.sliceGridSpacing;
            this.widgets.sliceGridSpacingSpinner.ValueChangedFcn = @(src, event) this.markDirty();
            this.widgets.sliceGridSpacingSpinner.Tooltip = sliceGridSpacingTooltip;
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
            this.privateOptions.centerKPoint = str2num(this.widgets.centerKPointValueEditField.Value); %#ok<*ST2NM>
            this.privateOptions.slicePlane = this.widgets.slicePlaneDropdown.Value;
            this.privateOptions.slicePlaneGrid = str2num(this.widgets.slicePlaneGridValueEditField.Value);
            this.privateOptions.sliceGridSpacing = this.widgets.sliceGridSpacingSpinner.Value;
            this.isDirty = false;

            output = this.privateOptions;
        end
    end

    methods (Hidden, Static)
        function this = qeShow(debug)
            % 用于在单元测试中测试 BandProcessing3DTaskUI，可通过下面的命令使用：
            % kssolv.services.workflow.module.postprocessing.BandProcessing3DTaskUI.qeShow();
            arguments
                debug logical = false
            end

            accordion = kssolv.services.workflow.module.AbstractTaskUI.qeShow(debug);
            this = kssolv.services.workflow.module.postprocessing.BandProcessing3DTaskUI();
            this.attachUIToAccordion(accordion);
        end
    end
end

