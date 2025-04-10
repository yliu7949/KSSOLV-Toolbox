classdef BuildMoleculeTaskUI < kssolv.services.workflow.module.AbstractTaskUI
    %BUILDMOLECULETASKUI 与 buildMoleculeTask 的选项相关的 UI 控件

    properties (Dependent)
        options
    end

    properties
        widgets
    end

    properties (Access = private)
        g1
        g2
        buttonGroup
        structureListbox
        functDropdown
        ppTypeEditField
        ecutSpinner
        smearDropdown
        temperatureSpinner
        nspinDropdown
        autokptsLabel
        autokptsEditField
        extranbndSpinner
        lspinorbSwitch
        lsdaSwitch
        noncolinSwitch
        domagSwitch
        lspinorbLabel
        lsdaLabel
        noncolinLabel
        domagLabel
    end

    methods (Access = protected)
        function setup(this)
            % Options AccordionPanel
            this.widgets.accordionPanel1 = matlab.ui.container.internal.AccordionPanel();
            this.widgets.accordionPanel1.BackgroundColor = 'white';
            this.widgets.accordionPanel1.Title = 'Options';

            this.g1 = uigridlayout(this.widgets.accordionPanel1);
            this.g1.BackgroundColor = 'white';
            this.g1.ColumnWidth = {100, '1x'};
            this.g1.RowHeight = {20, 'fit', 'fit', 'fit', 'fit', 'fit', 'fit'};

            % Molecule/Crystal 选项按钮标题
            buttonGroupLayout = uigridlayout(this.g1);
            buttonGroupLayout.BackgroundColor = 'white';
            buttonGroupLayout.Padding = 0;
            buttonGroupLayout.Layout.Row = 1;
            buttonGroupLayout.Layout.Column = [1 2];
            buttonGroupLayout.ColumnWidth = {'fit', '1x'};
            buttonGroupLayout.RowHeight = {20};

            buttonGroupTooltip = 'Choose build type';
            structureTypeLabel = uilabel(buttonGroupLayout);
            structureTypeLabel.HorizontalAlignment = 'left';
            structureTypeLabel.Text = "Type: ";
            structureTypeLabel.Tooltip = buttonGroupTooltip;
            structureTypeLabel.Layout.Row = 1;
            structureTypeLabel.Layout.Column = 1;

            % Molecule/Crystal 选项按钮
            this.buttonGroup = uibuttongroup(buttonGroupLayout);
            this.buttonGroup.Layout.Row = 1;
            this.buttonGroup.Layout.Column = 2;
            this.buttonGroup.Tooltip = buttonGroupTooltip;
            this.buttonGroup.BackgroundColor = 'white';
            this.buttonGroup.BorderType = 'none';
            this.buttonGroup.SelectionChangedFcn = @(src, event) this.toggleAutokpts(event.NewValue.Text);

            radiobutton1 = uiradiobutton(this.buttonGroup, "Text", "Molecule", 'Position', [12 3 80 15]);
            radiobutton2 = uiradiobutton(this.buttonGroup, "Text", "Crystal", 'Position', [125 3 80 15]);
            this.buttonGroup.SelectedObject = radiobutton2;

            % 选择结构标题
            structureTooltip = 'Choose imported structures';
            structureSelectTitleLabel = uilabel(this.g1);
            structureSelectTitleLabel.Layout.Row = 2;
            structureSelectTitleLabel.Layout.Column = [1 2];
            structureSelectTitleLabel.HorizontalAlignment = 'left';
            structureSelectTitleLabel.Text = "Choose imported structures: ";
            structureSelectTitleLabel.Tooltip = structureTooltip;

            % 选择结构的列表框，添加左右 padding
            this.structureListbox = uilistbox(this.g1, "Multiselect", "on");
            this.structureListbox.Layout.Row = 3;
            this.structureListbox.Layout.Column = [1 2];
            importedStructures = kssolv.services.filemanager.Structure.getAllImportedStructures();
            this.structureListbox.Items = cellfun(@(cell) cell.name, importedStructures, 'UniformOutput', false);
            this.structureListbox.Tooltip = structureTooltip;

            % funct 下拉菜单
            functTooltip = 'Select the functional';
            functLabel = uilabel(this.g1);
            functLabel.Layout.Row = 4;
            functLabel.Layout.Column = 1;
            functLabel.HorizontalAlignment = 'right';
            functLabel.Text = "Functional:";
            functLabel.Tooltip = functTooltip;

            this.functDropdown = uidropdown(this.g1, 'Items', {'PBE', 'PZ', 'HSE06'}, 'Value', 'PBE');
            this.functDropdown.Layout.Row = 4;
            this.functDropdown.Layout.Column = 2;
            this.functDropdown.Tooltip = functTooltip;

            % pseudopotential.PpType 编辑框
            ppTypeTooltip = 'Enter pseudopotential type';
            ppTypeLabel = uilabel(this.g1);
            ppTypeLabel.Layout.Row = 5;
            ppTypeLabel.Layout.Column = 1;
            ppTypeLabel.HorizontalAlignment = 'right';
            ppTypeLabel.Text = "Pseudopotential:";
            ppTypeLabel.Tooltip = ppTypeTooltip;

            this.ppTypeEditField = uieditfield(this.g1, 'text');
            this.ppTypeEditField.Layout.Row = 5;
            this.ppTypeEditField.Layout.Column = 2;
            this.ppTypeEditField.Value = 'default';
            this.ppTypeEditField.Tooltip = ppTypeTooltip;

            % Ecut 数值输入框（默认值 20 Hartree）
            ecutTooltip = 'Set energy cutoff in Hartree';
            ecutLabel = uilabel(this.g1);
            ecutLabel.Layout.Row = 6;
            ecutLabel.Layout.Column = 1;
            ecutLabel.HorizontalAlignment = 'right';
            ecutLabel.Text = "Ecut (Hartree):";
            ecutLabel.Tooltip = ecutTooltip;

            this.ecutSpinner = uispinner(this.g1, 'Value', 20);
            this.ecutSpinner.Layout.Row = 6;
            this.ecutSpinner.Layout.Column = 2;
            this.ecutSpinner.Tooltip = ecutTooltip;

            % Smearing 方法下拉菜单
            smearTooltip = 'Select the smearing method';
            smearLabel = uilabel(this.g1);
            smearLabel.Layout.Row = 7;
            smearLabel.Layout.Column = 1;
            smearLabel.HorizontalAlignment = 'right';
            smearLabel.Text = "Smearing:";
            smearLabel.Tooltip = smearTooltip;

            this.smearDropdown = uidropdown(this.g1, 'Items', {'fermi-dirac', 'cold', 'gaussian', 'mp'}, 'Value', 'fermi-dirac');
            this.smearDropdown.Layout.Row = 7;
            this.smearDropdown.Layout.Column = 2;
            this.smearDropdown.Tooltip = smearTooltip;

            % Temperature 输入框（默认值 0 K）
            temperatureTooltip = 'Set the temperature in Kelvin';
            temperatureLabel = uilabel(this.g1);
            temperatureLabel.Layout.Row = 8;
            temperatureLabel.Layout.Column = 1;
            temperatureLabel.HorizontalAlignment = 'right';
            temperatureLabel.Text = "Temperature (K):";
            temperatureLabel.Tooltip = temperatureTooltip;

            this.temperatureSpinner = uispinner(this.g1, 'Value', 0);
            this.temperatureSpinner.Layout.Row = 8;
            this.temperatureSpinner.Layout.Column = 2;
            this.temperatureSpinner.Tooltip = temperatureTooltip;

            % nspin 下拉菜单
            nspinTooltip = 'Select the number of spin components';
            nspinLabel = uilabel(this.g1);
            nspinLabel.Layout.Row = 9;
            nspinLabel.Layout.Column = 1;
            nspinLabel.HorizontalAlignment = 'right';
            nspinLabel.Text = "Nspin:";
            nspinLabel.Tooltip = nspinTooltip;

            this.nspinDropdown = uidropdown(this.g1, 'Items', {'1', '2', '4'}, 'Value', '1');
            this.nspinDropdown.Layout.Row = 9;
            this.nspinDropdown.Layout.Column = 2;
            this.nspinDropdown.Tooltip = nspinTooltip;
            this.nspinDropdown.ValueChangedFcn = @(src, event) this.updateAdvancedOptions(src, event);

            % autokpts 编辑框
            autokptsTooltip = 'Set automatic k-point grid';
            this.autokptsLabel = uilabel(this.g1);
            this.autokptsLabel.Layout.Row = 10;
            this.autokptsLabel.Layout.Column = 1;
            this.autokptsLabel.HorizontalAlignment = 'right';
            this.autokptsLabel.Text = "Autokpts:";
            this.autokptsLabel.Tooltip = autokptsTooltip;

            this.autokptsEditField = uieditfield(this.g1, 'text', 'Value', '[1,1,1,0,0,0]');
            this.autokptsEditField.Layout.Row = 10;
            this.autokptsEditField.Layout.Column = 2;
            this.autokptsEditField.Tooltip = autokptsTooltip;

            % Advanced Options AccordionPanel
            this.widgets.accordionPanel2 = matlab.ui.container.internal.AccordionPanel();
            this.widgets.accordionPanel2.BackgroundColor = 'white';
            this.widgets.accordionPanel2.Title = 'Advanced Options';
            this.widgets.accordionPanel2.collapse();  % 默认折叠

            this.g2 = uigridlayout(this.widgets.accordionPanel2);
            this.g2.BackgroundColor = 'white';
            this.g2.ColumnWidth = {120, '1x'};
            this.g2.RowHeight = {'fit', 'fit', 'fit', 'fit', 'fit'};  % 5 行布局

            % extranbnd (数值输入框) - 设置额外的带数
            extranbndTooltip = 'Set the number of extra bands';
            extranbndLabel = uilabel(this.g2);
            extranbndLabel.Layout.Row = 1;
            extranbndLabel.Layout.Column = 1;
            extranbndLabel.HorizontalAlignment = 'right';
            extranbndLabel.Text = 'Extra bands:';
            extranbndLabel.Tooltip = extranbndTooltip;

            this.extranbndSpinner = uispinner(this.g2, 'Value', 0);  % 默认值设置为 0
            this.extranbndSpinner.Layout.Row = 1;
            this.extranbndSpinner.Layout.Column = 2;
            this.extranbndSpinner.Tooltip = extranbndTooltip;

            % lspinorb (逻辑开关) - 启用自旋轨道耦合
            lspinorbTooltip = 'Enable spin-orbit coupling';
            this.lspinorbLabel = uilabel(this.g2);
            this.lspinorbLabel.Layout.Row = 2;
            this.lspinorbLabel.Layout.Column = 1;
            this.lspinorbLabel.HorizontalAlignment = 'right';
            this.lspinorbLabel.Text = 'Spin-orbit:';
            this.lspinorbLabel.Tooltip = lspinorbTooltip;
            this.lspinorbLabel.Visible = false;

            this.lspinorbSwitch = uiswitch(this.g2, 'slider');  % 使用滑动开关
            this.lspinorbSwitch.Layout.Row = 2;
            this.lspinorbSwitch.Layout.Column = 2;
            this.lspinorbSwitch.Value = 'Off';  % 默认关闭
            this.lspinorbSwitch.Tooltip = lspinorbTooltip;
            this.lspinorbSwitch.Visible = false;
            this.g2.RowHeight{2} = 0;

            % lsda (逻辑开关) - 启用 LSDA 近似
            lsdaTooltip = 'Enable LSDA approximation';
            this.lsdaLabel = uilabel(this.g2);
            this.lsdaLabel.Layout.Row = 3;
            this.lsdaLabel.Layout.Column = 1;
            this.lsdaLabel.HorizontalAlignment = 'right';
            this.lsdaLabel.Text = 'LSDA:';
            this.lsdaLabel.Tooltip = lsdaTooltip;
            this.lsdaLabel.Visible = false;

            this.lsdaSwitch = uiswitch(this.g2, 'slider');
            this.lsdaSwitch.Layout.Row = 3;
            this.lsdaSwitch.Layout.Column = 2;
            this.lsdaSwitch.Value = 'Off';  % 默认关闭
            this.lsdaSwitch.Tooltip = lsdaTooltip;
            this.lsdaSwitch.Visible = false;
            this.g2.RowHeight{3} = 0;

            % noncolin (逻辑开关) - 启用非共线磁性
            noncolinTooltip = 'Enable non-collinear magnetism';
            this.noncolinLabel = uilabel(this.g2);
            this.noncolinLabel.Layout.Row = 4;
            this.noncolinLabel.Layout.Column = 1;
            this.noncolinLabel.HorizontalAlignment = 'right';
            this.noncolinLabel.Text = 'Non-collinear:';
            this.noncolinLabel.Tooltip = noncolinTooltip;
            this.noncolinLabel.Visible = false;

            this.noncolinSwitch = uiswitch(this.g2, 'slider');
            this.noncolinSwitch.Layout.Row = 4;
            this.noncolinSwitch.Layout.Column = 2;
            this.noncolinSwitch.Value = 'Off';  % 默认关闭
            this.noncolinSwitch.Tooltip = noncolinTooltip;
            this.noncolinSwitch.Visible = false;
            this.g2.RowHeight{4} = 0;

            % domag (逻辑开关) - 启用磁性计算
            domagTooltip = 'Enable magnetic calculation';
            this.domagLabel = uilabel(this.g2);
            this.domagLabel.Layout.Row = 5;
            this.domagLabel.Layout.Column = 1;
            this.domagLabel.HorizontalAlignment = 'right';
            this.domagLabel.Text = 'Magnetic:';
            this.domagLabel.Tooltip = domagTooltip;
            this.domagLabel.Visible = false;

            this.domagSwitch = uiswitch(this.g2, 'slider');
            this.domagSwitch.Layout.Row = 5;
            this.domagSwitch.Layout.Column = 2;
            this.domagSwitch.Value = 'Off';  % 默认关闭
            this.domagSwitch.Tooltip = domagTooltip;
            this.domagSwitch.Visible = false;
            this.g2.RowHeight{5} = 0;
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
            % 创建结构体并提取所有 UI 控件的值

            output.type = this.buttonGroup.SelectedObject.Text;
            
            output.structures = [];
            project = kssolv.ui.util.DataStorage.getData('Project');
            for i = 1:length(this.structureListbox.Value)
                structureItem = project.findChildrenItem(this.structureListbox.Value{i});
                output.structures = [output.structures, structureItem.data.KSSOLVSetupObject];
            end

            output.pseudopotentialPpType = this.ppTypeEditField.Value;

            % 选项
            output.funct = this.functDropdown.Value;
            output.ecut = this.ecutSpinner.Value;
            output.smear = this.smearDropdown.Value;
            output.temperature = this.temperatureSpinner.Value;
            output.nspin = str2double(this.nspinDropdown.Value);
            output.autokpts = str2num(this.autokptsEditField.Value); %#ok<ST2NM>

            % 高级选项
            output.extranbnd = this.extranbndSpinner.Value;
            output.lspinorb = matlab.lang.OnOffSwitchState(this.lspinorbSwitch.Value);
            output.lsda = matlab.lang.OnOffSwitchState(this.lsdaSwitch.Value);
            output.noncolin = matlab.lang.OnOffSwitchState(this.noncolinSwitch.Value);
            output.domag = matlab.lang.OnOffSwitchState(this.domagSwitch.Value);
        end
    end

    methods (Access = private)
        function updateAdvancedOptions(this, src, ~)
            nspinValue = str2double(src.Value);

            % 更新 lspinorb 和 domag 可见性
            if nspinValue ~= 1
                this.lspinorbLabel.Visible = true;
                this.lspinorbSwitch.Visible = true;
                this.g2.RowHeight{2} = 'fit';
                this.domagLabel.Visible = true;
                this.domagSwitch.Visible = true;
                this.g2.RowHeight{5} = 'fit';
            else
                this.lspinorbLabel.Visible = false;
                this.lspinorbSwitch.Visible = false;
                this.g2.RowHeight{2} = 0;
                this.domagLabel.Visible = false;
                this.domagSwitch.Visible = false;
                this.g2.RowHeight{5} = 0;
            end

            % 更新 lsda 可见性 (仅 nspin 为 2 时显示)
            if nspinValue == 2
                this.lsdaLabel.Visible = true;
                this.lsdaSwitch.Visible = true;
                this.g2.RowHeight{3} = 'fit';
            else
                this.lsdaLabel.Visible = false;
                this.lsdaSwitch.Visible = false;
                this.g2.RowHeight{3} = 0;
            end

            % 更新 noncolin 可见性 (仅 nspin 为 4 时显示)
            if nspinValue == 4
                this.noncolinLabel.Visible = true;
                this.noncolinSwitch.Visible = true;
                this.g2.RowHeight{4} = 'fit';
            else
                this.noncolinLabel.Visible = false;
                this.noncolinSwitch.Visible = false;
                this.g2.RowHeight{4} = 0;
            end
        end

        function toggleAutokpts(this, selectedOption)
            if strcmp(selectedOption, 'Molecule')
                this.autokptsLabel.Visible = 'off';
                this.autokptsEditField.Visible = 'off';
                this.g1.RowHeight{10} = 0;
            else
                this.autokptsLabel.Visible = 'on';
                this.autokptsEditField.Visible = 'on';
                this.g1.RowHeight{10} = 'fit';
            end
        end
    end

    methods (Hidden, Static)
        function this = qeShow(debug)
            % 用于在单元测试中测试 BuildMoleculeTaskUI，可通过下面的命令使用：
            % kssolv.services.workflow.module.computation.BuildMoleculeTaskUI.qeShow();
            arguments
                debug logical = false
            end

            accordion = kssolv.services.workflow.module.AbstractTaskUI.qeShow(debug);
            this = kssolv.services.workflow.module.computation.BuildMoleculeTaskUI();
            this.attachUIToAccordion(accordion);
        end
    end
end
