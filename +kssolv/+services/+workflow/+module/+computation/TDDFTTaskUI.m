classdef TDDFTTaskUI < kssolv.services.workflow.module.AbstractTaskUI
    %TDDFTTASKUI 与 TDDFTTask 的选项相关的 UI 控件

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
            this.defaultOptions = struct('method', 'casida', 'diag', 'direct', ...
                'nvbands', 0, 'ncbands', 0, 'nroots', 10, 'istda', true, 'isipa', false, 'isrpa', false);
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

            % TDDFT 计算方法
            TDDFTMethodLabelTooltip = 'TDDFT calculation method';
            TDDFTMethodLabel = uilabel(g1);
            TDDFTMethodLabel.HorizontalAlignment = 'right';
            TDDFTMethodLabel.Text = "TDDFTMethod: ";
            TDDFTMethodLabel.Tooltip = TDDFTMethodLabelTooltip;
            this.widgets.TDDFTMethodValueDropdown = uidropdown(g1);
            this.widgets.TDDFTMethodValueDropdown.Items = {'casida'};
            this.widgets.TDDFTMethodValueDropdown.Value = options.method;
            this.widgets.TDDFTMethodValueDropdown.ValueChangedFcn = @(src, event) this.markDirty();
            this.widgets.TDDFTMethodValueDropdown.Tooltip = TDDFTMethodLabelTooltip;

            % 对角化方法
            diagMethodLabelTooltip = 'Diagonalization method';
            diagMethodLabel = uilabel(g1);
            diagMethodLabel.HorizontalAlignment = 'right';
            diagMethodLabel.Text = "DiagMethod: ";
            diagMethodLabel.Tooltip = diagMethodLabelTooltip;
            this.widgets.diagMethodValueDropdown = uidropdown(g1);
            this.widgets.diagMethodValueDropdown.Items = {'direct'};
            this.widgets.diagMethodValueDropdown.Value = options.diag;
            this.widgets.diagMethodValueDropdown.ValueChangedFcn = @(src, event) this.markDirty();
            this.widgets.diagMethodValueDropdown.Tooltip = diagMethodLabelTooltip;

            % Advanced Options AccordionPanel
            this.widgets.accordionPanel2 = matlab.ui.container.internal.AccordionPanel();
            this.widgets.accordionPanel2.BackgroundColor = 'white';
            this.widgets.accordionPanel2.Title = message('KSSOLV:toolbox:ConfigBrowserAdvancedOptionsPanelTitle');
            this.widgets.accordionPanel2.collapse();

            g2 = uigridlayout(this.widgets.accordionPanel2);
            g2.BackgroundColor = 'white';
            g2.ColumnWidth = {120, '1x'};
            g2.RowHeight = {'fit', 'fit', 'fit', 'fit', 'fit', 'fit'};

            % nvbands 数值输入框
            nvbandsTooltip = 'Number of selected valence bands (occupied orbitals)';
            nvbandsLabel = uilabel(g2);
            nvbandsLabel.Layout.Row = 1;
            nvbandsLabel.Layout.Column = 1;
            nvbandsLabel.HorizontalAlignment = 'right';
            nvbandsLabel.Text = 'nvbands: ';
            nvbandsLabel.Tooltip = nvbandsTooltip;

            this.widgets.nvbandsSpinner = uispinner(g2);
            this.widgets.nvbandsSpinner.Layout.Row = 1;
            this.widgets.nvbandsSpinner.Layout.Column = 2;
            this.widgets.nvbandsSpinner.Value = options.nvbands;
            this.widgets.nvbandsSpinner.ValueChangedFcn = @(src, event) this.markDirty();
            this.widgets.nvbandsSpinner.Tooltip = nvbandsTooltip;

            % ncbands 数值输入框
            ncbandsTooltip = 'Number of selected conduction bands (empty orbitals)';
            ncbandsLabel = uilabel(g2);
            ncbandsLabel.Layout.Row = 2;
            ncbandsLabel.Layout.Column = 1;
            ncbandsLabel.HorizontalAlignment = 'right';
            ncbandsLabel.Text = 'ncbands: ';
            ncbandsLabel.Tooltip = ncbandsTooltip;

            this.widgets.ncbandsSpinner = uispinner(g2);
            this.widgets.ncbandsSpinner.Layout.Row = 2;
            this.widgets.ncbandsSpinner.Layout.Column = 2;
            this.widgets.ncbandsSpinner.Value = options.ncbands;
            this.widgets.ncbandsSpinner.ValueChangedFcn = @(src, event) this.markDirty();
            this.widgets.ncbandsSpinner.Tooltip = ncbandsTooltip;

            % nroots 数值输入框
            nrootsTooltip = 'Number of excited states to be solved';
            nrootsLabel = uilabel(g2);
            nrootsLabel.Layout.Row = 3;
            nrootsLabel.Layout.Column = 1;
            nrootsLabel.HorizontalAlignment = 'right';
            nrootsLabel.Text = 'nroots: ';
            nrootsLabel.Tooltip = nrootsTooltip;

            this.widgets.nrootsSpinner = uispinner(g2);
            this.widgets.nrootsSpinner.Layout.Row = 3;
            this.widgets.nrootsSpinner.Layout.Column = 2;
            this.widgets.nrootsSpinner.Value = options.nroots;
            this.widgets.nrootsSpinner.ValueChangedFcn = @(src, event) this.markDirty();
            this.widgets.nrootsSpinner.Tooltip = nrootsTooltip;

            % 是否使用 Tamm–Dancoff approximation (TDA)
            this.widgets.TDACheckbox = uicheckbox(g2);
            this.widgets.TDACheckbox.Layout.Row = 4;
            this.widgets.TDACheckbox.Layout.Column = 2;
            this.widgets.TDACheckbox.Text = 'Use TDA';
            this.widgets.TDACheckbox.Tooltip = 'Whether to use Tamm–Dancoff approximation';
            this.widgets.TDACheckbox.Value = options.istda;
            this.widgets.TDACheckbox.ValueChangedFcn = @(src, event) this.markDirty();

            % 是否使用 independent-particle approximation (IPA)
            this.widgets.IPACheckbox = uicheckbox(g2);
            this.widgets.IPACheckbox.Layout.Row = 5;
            this.widgets.IPACheckbox.Layout.Column = 2;
            this.widgets.IPACheckbox.Text = 'Use IPA';
            this.widgets.IPACheckbox.Tooltip = 'Whether to use independent-particle approximation';
            this.widgets.IPACheckbox.Value = options.isipa;
            this.widgets.IPACheckbox.ValueChangedFcn = @(src, event) this.markDirty();

            % 是否使用 random-phase approximation (RPA)
            this.widgets.RPACheckbox = uicheckbox(g2);
            this.widgets.RPACheckbox.Layout.Row = 6;
            this.widgets.RPACheckbox.Layout.Column = 2;
            this.widgets.RPACheckbox.Text = 'Use RPA';
            this.widgets.RPACheckbox.Tooltip = 'Whether to use random-phase approximation';
            this.widgets.RPACheckbox.Value = options.isrpa;
            this.widgets.RPACheckbox.ValueChangedFcn = @(src, event) this.markDirty();
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
            this.privateOptions.method = this.widgets.TDDFTMethodValueDropdown.Value;
            this.privateOptions.diag = this.widgets.diagMethodValueDropdown.Value;
            this.privateOptions.nvbands = this.widgets.nvbandsSpinner.Value;
            this.privateOptions.ncbands = this.widgets.ncbandsSpinner.Value;
            this.privateOptions.nroots = this.widgets.nrootsSpinner.Value;
            this.privateOptions.istda = this.widgets.TDACheckbox.Value;
            this.privateOptions.isipa = this.widgets.IPACheckbox.Value;
            this.privateOptions.isrpa = this.widgets.RPACheckbox.Value;

            output = this.privateOptions;
        end
    end

    methods (Hidden, Static)
        function this = qeShow(debug)
            % 用于在单元测试中测试 TDDFTTaskUI，可通过下面的命令使用：
            % kssolv.services.workflow.module.computation.TDDFTTaskUI.qeShow();
            arguments
                debug logical = false
            end

            accordion = kssolv.services.workflow.module.AbstractTaskUI.qeShow(debug);
            this = kssolv.services.workflow.module.computation.TDDFTTaskUI();
            this.attachUIToAccordion(accordion);
        end
    end
end

