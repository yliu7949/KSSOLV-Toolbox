classdef WorkflowTab < handle
    %WORKFLOWTAB Toolstrip 菜单栏中的 Workflow 标签页
    %   开发者：杨柳、高俊、林海饶
    %   版权 2024 合肥瀚海量子科技有限公司
    
    properties
        % Workflow 标签页
        Tab
        % 标签
        Tag
        % 标题
        Title
    end
    
    methods
        function this = WorkflowTab()
            %WORKFLOWTAB 构造函数，初始设置相关参数
            import kssolv.ui.util.Localizer.message
            this.Title = message("KSSOLV:toolbox:WorkflowTabTitle");
            this.Tag = 'WorkflowTab';
            buildTab(this);
        end
        
        function buildTab(this)
            %BUILDTAB 创建 WorkflowTab 对象
            this.Tab = matlab.ui.internal.toolstrip.Tab(this.Title);
            this.Tab.Tag = this.Tag;
            % 分别创建各个 Section 并添加到 WorkflowTab 中
            createSaveSection(this);
            createOperationSection(this);
            createNodeSection(this);
            createZoomSection(this);
            createSettingsSection(this);
        end



        function createZoomSection(this) 
            %CREATERUNNINGSECTION 创建"缩放"小节，并添加到 WorkflowTab 中
            import matlab.ui.internal.toolstrip.*
            import kssolv.ui.util.Localizer.message
            import kssolv.ui.util.CreatButton
            % 创建 Zoom Section
            section = Section(message("KSSOLV:toolbox:ZoomSectionTitle"));
            section.Tag = 'ZoomSection';
            % 创建 Column
            column1 = Column();
            column2 = Column();
            column3 = Column();
            % 创建 Button
            ZoomInButton = CreatButton('push', 'ZoomIn', section.Tag, Icon.ZOOM_IN_24);
            ZoomOutButton = CreatButton('push', 'ZoomOut', section.Tag, Icon.ZOOM_OUT_24);
            ZoomResetButton = CreatButton('push', 'ZoomReset', section.Tag, Icon.REFRESH_24);

            % 组装 Column 和 Button
            column1.add(ZoomInButton);
            column2.add(ZoomOutButton);
            column3.add(ZoomResetButton);
            section.add(column1);
            section.add(column2);
            section.add(column3);
            this.Tab.add(section);
        end



        function createNodeSection(this) 
            %CREATERUNNINGSECTION 创建"节点"小节，并添加到 WorkflowTab 中
            import matlab.ui.internal.toolstrip.*
            import kssolv.ui.util.Localizer.message
            import kssolv.ui.util.CreatButton
            import kssolv.ui.util.CreateListItem
            % 创建 Node Section
            section = Section(message("KSSOLV:toolbox:NodeSectionTitle"));
            section.Tag = 'NodeSection';
            % 创建 Column
            column1 = Column();
            column2 = Column();

            % 创建 Button
            AddNoteButton = CreatButton('split', 'AddNote', section.Tag, Icon.ZOOM_IN_24);
            EditNoteButton = CreatButton('split', 'EditNote', section.Tag, Icon.ZOOM_OUT_24);

            % 创建并组装 PopupList(下拉菜单)
            AddNotePopup = PopupList();
            EditNotePopup = PopupList();
            % Zeroslot = CreateListItem('OpenDocument', section.Tag, 'none');
            % OneSlot = CreateListItem('OfficialSite', section.Tag, 'none');
            % TwoSlot = CreateListItem('CheckUpdate', section.Tag, 'none');
            % node00 = CreateListItem('CheckLicense', section.Tag, 'none');
            % node01 = CreateListItem('TermsOfUse', section.Tag, 'none');
            % node10 = CreateListItem('AboutUs', section.Tag, 'none');
            % node11 = CreateListItem('CheckLicense', section.Tag, 'none');
            % node12 = CreateListItem('TermsOfUse', section.Tag, 'none');
            % node21 = CreateListItem('AboutUs', section.Tag, 'none');
            % nodexy = CreateListItem('AboutUs', section.Tag, 'none');
            % AddTopSlot = CreateListItem('AboutUs', section.Tag, 'none');
            % DelTopSlot = CreateListItem('AboutUs', section.Tag, 'none');
            % AddBottomSlot = CreateListItem('AboutUs', section.Tag, 'none');
            % DelBottomSlot = CreateListItem('AboutUs', section.Tag, 'none');
            node00 = CreateListItem('node00', section.Tag, 'none');
            node01 = CreateListItem('node01', section.Tag, 'none');
            node10 = CreateListItem('node10', section.Tag, 'none');
            node11 = CreateListItem('node11', section.Tag, 'none');
            node12 = CreateListItem('node12', section.Tag, 'none');
            node21 = CreateListItem('node21', section.Tag, 'none');
            nodexy = CreateListItem('nodexy', section.Tag, 'none');
            AddTopSlot = CreateListItem('AddTopSlot', section.Tag, 'none');
            DelTopSlot = CreateListItem('DelTopSlot', section.Tag, 'none');
            AddBottomSlot = CreateListItem('AddBottomSlot', section.Tag, 'none');
            DelBottomSlot = CreateListItem('DelBottomSlot', section.Tag, 'none');
            AddNotePopup.add(node00);
            AddNotePopup.addSeparator;
            AddNotePopup.add(node01);
            AddNotePopup.add(node10);
            AddNotePopup.addSeparator;
            AddNotePopup.add(node11);
            AddNotePopup.add(node12);
            AddNotePopup.add(node21);
            AddNotePopup.addSeparator;
            AddNotePopup.add(nodexy);
            EditNotePopup.add(AddTopSlot);
            EditNotePopup.add(DelTopSlot);
            EditNotePopup.add(AddBottomSlot);
            EditNotePopup.add(DelBottomSlot);

            AddNoteButton.Popup = AddNotePopup;
            EditNoteButton.Popup = EditNotePopup;         
            % 组装 Column 和 Button
            column1.add(AddNoteButton);
            column2.add(EditNoteButton);

            section.add(column1);
            section.add(column2);

            this.Tab.add(section);
        end

        function createSaveSection(this) 
            %CREATESAVESECTION 创建"保存"小节，并添加到 WorkflowTab 中
            import matlab.ui.internal.toolstrip.*
            import kssolv.ui.util.Localizer.message
            import kssolv.ui.util.CreatButton
            % 创建 Save Section
            section = Section(message("KSSOLV:toolbox:SaveSectionTitle"));

            section.Tag = 'SaveSection';
            % 创建 Column
            column1 = Column();
            % 创建 Button
            SaveWorkflowAsTemplateButton = CreatButton('push', 'SaveWorkflowAsTemplate', section.Tag, Icon.SAVE_24);
            % 组装 Column 和 Button
            column1.add(SaveWorkflowAsTemplateButton);
            section.add(column1);
            this.Tab.add(section);
        end



        function createOperationSection(this) 
            %CREATEOPERATIONSECTION 创建"操作"小节，并添加到 WorkflowTab 中
            import matlab.ui.internal.toolstrip.*
            import kssolv.ui.util.Localizer.message
            import kssolv.ui.util.CreatButton
            % 创建 Operation Section
            section = Section(message("KSSOLV:toolbox:OperationSectionTitle"));
            section.Tag = 'OperationSection';
            % 创建 Column
            column1 = Column();
            % 创建 Button
            OperationUndoButton = CreatButton('push', 'OperationUndo', section.Tag, Icon.UNDO_16);
            OperationRedoButton = CreatButton('push', 'OperationRedo', section.Tag, Icon.REDO_16);
            % 组装 Column 和 Button
            column1.add(OperationUndoButton);
            column1.add(OperationRedoButton);
            section.add(column1);
            this.Tab.add(section);
        end



        function createSettingsSection(this) 
            %CREATESAVESECTION 创建"设置"小节，并添加到 WorkflowTab 中
            import matlab.ui.internal.toolstrip.*
            import kssolv.ui.util.Localizer.message
            import kssolv.ui.util.CreatButton
            % 创建 Settings Section
            section = Section(message("KSSOLV:toolbox:SettingsSectionTitle"));

            section.Tag = 'SettingsSection';
            % 创建 Column
            column1 = Column();
            % 创建 Button
            SetNodeButton = CreatButton('push', 'SetNode', section.Tag, Icon.SAVE_24);
            % 组装 Column 和 Button
            column1.add(SetNodeButton);
            section.add(column1);
            this.Tab.add(section);
        end


        function createTestGallerySection(this)
            %CREATEPLOTSECTION 创建"绘图"小节，并添加到 WorkflowTab 中
            import matlab.ui.internal.toolstrip.*
            import kssolv.ui.util.Localizer.message
            import kssolv.ui.util.CreatButton
            % 创建 Project Section
            section = Section(message("KSSOLV:toolbox:PlotSectionTitle"));
            section.Tag = 'PlotSection';
            % 创建 Column
            column1 = Column();
            % 创建 GalleryCategory
            category1 = GalleryCategory('My Category 1');
            category2 = GalleryCategory('My Category 2');
            % 创建 GalleryItem
            item1 = GalleryItem('Import', Icon.IMPORT_24);
            item2 = GalleryItem('Export', Icon.EXPORT_24);
            item3 = GalleryItem('Print', Icon.PRINT_24);
            item4 = GalleryItem('Help', Icon.HELP_24);
            % 组装 GalleryCategory 和 GalleryItem 构建  Gallery 
            category1.add(item1);
            category1.add(item2);
            category2.add(item3);
            category2.add(item4);
            popup = GalleryPopup();
            popup.add(category1);
            popup.add(category2);
            gallery = Gallery(popup);
            % 组装 Column 和 Gallery
            column1.add(gallery);
            section.add(column1);
            this.Tab.add(section);
        end
    end

    methods (Static, Hidden)
        function app = qeShow()
            % 用于在单元测试中测试 WorkflowTab，可通过下面的命令使用：
            % kssolv.ui.components.tab.WorkflowTab.qeShow();

            % 创建 AppContainer          
            appOptions.Tag = sprintf('kssolv(%s)',char(matlab.lang.internal.uuid));
            appOptions.Title = kssolv.ui.util.Localizer.message('KSSOLV:toolbox:UnitTestTitle');
            appOptions.ToolstripEnabled = true;
            app = matlab.ui.container.internal.AppContainer(appOptions);

            % 添加 WorkflowTab
            workflowTab = kssolv.ui.components.tab.WorkflowTab();
            tabGroup = matlab.ui.internal.toolstrip.TabGroup();
            tabGroup.Tag = 'kssolvTabGroup';
            tabGroup.add(workflowTab.Tab);
            app.add(tabGroup);

            % 展示界面
            app.Visible = true;
        end
    end

end

