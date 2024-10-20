classdef BuildMoleculeTaskUI < kssolv.services.workflow.module.AbstractTaskUI
    %BUILDMOLECULETASKUI 与 buildMoleculeTask 的选项相关的 UI 控件

    properties (Access = private)
        g1
        g2
        nspinDropdown
        autokptsLabel
        autokptsEditField
        lspinorbLabel
        lspinorbSwitch
        lsdaLabel
        noncolinLabel
        lsdaSwitch
        noncolinSwitch
        domagLabel
        domagSwitch
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

            this.g1 = uigridlayout(accordionPanel1);
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
            buttonGroup = uibuttongroup(buttonGroupLayout);
            buttonGroup.Layout.Row = 1;
            buttonGroup.Layout.Column = 2;
            buttonGroup.Tooltip = buttonGroupTooltip;
            buttonGroup.BackgroundColor = 'white';
            buttonGroup.BorderType = 'none';
            buttonGroup.SelectionChangedFcn = @(src, event) this.toggleAutokpts(event.NewValue.Text);

            radiobutton1 = uiradiobutton(buttonGroup, "Text", "Molecule", 'Position', [12 3 80 15]);
            radiobutton2 = uiradiobutton(buttonGroup, "Text", "Crystal", 'Position', [125 3 80 15]);
            buttonGroup.SelectedObject = radiobutton2;

            % 选择结构标题
            structureTooltip = 'Choose imported structures';
            structureSelectTitleLabel = uilabel(this.g1);
            structureSelectTitleLabel.Layout.Row = 2;
            structureSelectTitleLabel.Layout.Column = [1 2];
            structureSelectTitleLabel.HorizontalAlignment = 'left';
            structureSelectTitleLabel.Text = "Choose imported structures: ";
            structureSelectTitleLabel.Tooltip = structureTooltip;

            % 选择结构的列表框，添加左右 padding
            structureListbox = uilistbox(this.g1, "Multiselect", "on");
            structureListbox.Layout.Row = 3;
            structureListbox.Layout.Column = [1 2];
            structureListbox.Tooltip = structureTooltip;

            % funct 下拉菜单
            functTooltip = 'Select the functional';
            functLabel = uilabel(this.g1);
            functLabel.Layout.Row = 4;
            functLabel.Layout.Column = 1;
            functLabel.HorizontalAlignment = 'right';
            functLabel.Text = "Function:";
            functLabel.Tooltip = functTooltip;

            functDropdown = uidropdown(this.g1, 'Items', {'LDA', 'GGA', 'Hybrid'}, 'Value', 'LDA');
            functDropdown.Layout.Row = 4;
            functDropdown.Layout.Column = 2;
            functDropdown.Tooltip = functTooltip;

            % pseudopotential.PpType 编辑框
            ppTypeTooltip = 'Enter pseudopotential type';
            ppTypeLabel = uilabel(this.g1);
            ppTypeLabel.Layout.Row = 5;
            ppTypeLabel.Layout.Column = 1;
            ppTypeLabel.HorizontalAlignment = 'right';
            ppTypeLabel.Text = "Pseudopotential:";
            ppTypeLabel.Tooltip = ppTypeTooltip;

            ppTypeEditField = uieditfield(this.g1, 'text');
            ppTypeEditField.Layout.Row = 5;
            ppTypeEditField.Layout.Column = 2;
            ppTypeEditField.Value = 'default';
            ppTypeEditField.Tooltip = ppTypeTooltip;

            % Ecut 数值输入框（默认值 20 Hartree）
            ecutTooltip = 'Set energy cutoff in Hartree';
            ecutLabel = uilabel(this.g1);
            ecutLabel.Layout.Row = 6;
            ecutLabel.Layout.Column = 1;
            ecutLabel.HorizontalAlignment = 'right';
            ecutLabel.Text = "Ecut (Hartree):";
            ecutLabel.Tooltip = ecutTooltip;

            ecutSpinner = uispinner(this.g1, 'Value', 20);
            ecutSpinner.Layout.Row = 6;
            ecutSpinner.Layout.Column = 2;
            ecutSpinner.Tooltip = ecutTooltip;

            % Smearing 方法下拉菜单
            smearTooltip = 'Select the smearing method';
            smearLabel = uilabel(this.g1);
            smearLabel.Layout.Row = 7;
            smearLabel.Layout.Column = 1;
            smearLabel.HorizontalAlignment = 'right';
            smearLabel.Text = "Smearing:";
            smearLabel.Tooltip = smearTooltip;

            smearDropdown = uidropdown(this.g1, 'Items', {'fermi-dirac', 'cold', 'gaussian', 'mp'}, 'Value', 'fermi-dirac');
            smearDropdown.Layout.Row = 7;
            smearDropdown.Layout.Column = 2;
            smearDropdown.Tooltip = smearTooltip;

            % Temperature 输入框（默认值 0 K）
            temperatureTooltip = 'Set the temperature in Kelvin';
            temperatureLabel = uilabel(this.g1);
            temperatureLabel.Layout.Row = 8;
            temperatureLabel.Layout.Column = 1;
            temperatureLabel.HorizontalAlignment = 'right';
            temperatureLabel.Text = "Temperature (K):";
            temperatureLabel.Tooltip = temperatureTooltip;

            temperatureSpinner = uispinner(this.g1, 'Value', 0);
            temperatureSpinner.Layout.Row = 8;
            temperatureSpinner.Layout.Column = 2;
            temperatureSpinner.Tooltip = temperatureTooltip;

            % nspin 下拉菜单
            nspinTooltip = 'Select the number of spin components';
            nspinLabel = uilabel(this.g1);
            nspinLabel.Layout.Row = 9;
            nspinLabel.Layout.Column = 1;
            nspinLabel.HorizontalAlignment = 'right';
            nspinLabel.Text = "nspin:";
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
            accordionPanel2 = matlab.ui.container.internal.AccordionPanel();
            accordionPanel2.BackgroundColor = 'white';
            accordionPanel2.Title = 'Advanced Options';
            accordionPanel2.collapse();  % 默认折叠

            this.g2 = uigridlayout(accordionPanel2);
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

            extranbndSpinner = uispinner(this.g2, 'Value', 0);  % 默认值设置为 0
            extranbndSpinner.Layout.Row = 1;
            extranbndSpinner.Layout.Column = 2;
            extranbndSpinner.Tooltip = extranbndTooltip;

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

            % lsda (逻辑开关) - 启用LSDA近似
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
        function qeShow(debug)
            % 用于在单元测试中测试 BuildMoleculeTaskUI，可通过下面的命令使用：
            % kssolv.services.workflow.module.computation.BuildMoleculeTaskUI.qeShow();
            arguments
                debug logical = false
            end

            accordion = kssolv.services.workflow.module.AbstractTaskUI.qeShow(debug);
            kssolv.services.workflow.module.computation.BuildMoleculeTaskUI(accordion);
        end
    end
end