classdef WorkflowTab < handle
    %WORKFLOWTAB Toolstrip 菜单栏中的 Workflow 标签页

    %   开发者：杨柳、高俊、林海饶
    %   版权 2024 合肥瀚海量子科技有限公司
    
    properties
        Tab       % Workflow 标签页
        Tag       % 标签
        Title     % 标题
        Widgets   % 小组件
    end
    
    methods
        function this = WorkflowTab()
            %WORKFLOWTAB 构造函数，初始设置相关参数
            import kssolv.ui.util.Localizer.message
            this.Title = message("KSSOLV:toolbox:WorkflowTabTitle");
            this.Tag = 'WorkflowTab';

            buildTab(this);
            connectTab(this);
            setTabActivated(this);
        end
    end

    methods (Access = protected)
        function buildTab(this)
            %BUILDTAB 创建 Workflow Tab 对象
            this.Tab = matlab.ui.internal.toolstrip.Tab(this.Title);
            this.Tab.Tag = this.Tag;

            % 分别创建各个 Section 并添加到 Workflow Tab 中
            createSaveSection(this);
            createOperationSection(this);
            createNodeSection(this);
            createZoomSection(this);
            createSettingsSection(this);
            % createTestGallerySection(this);
        end

        function connectTab(~)
            %CONNECTTAB 为按钮等组件添加监听器和回调函数
        end

        function setTabActivated(~)
            %SETTABACTIVATED 初始化时设置一些按钮是否被启用
        end
    end

    methods (Access = private)
        %% 创建 Sections
        function createZoomSection(this) 
            %CREATERUNNINGSECTION 创建"缩放"小节，并添加到 WorkflowTab 中
            import matlab.ui.internal.toolstrip.*
            import kssolv.ui.util.Localizer.message
            import kssolv.ui.util.CreateButton

            % 创建 Zoom Section
            section = Section(message("KSSOLV:toolbox:ZoomSectionTitle"));
            section.Tag = 'ZoomSection';
            % 创建 Column
            column1 = Column();
            column2 = Column();
            column3 = Column();

            % 创建 Button
            ZoomInButton = CreateButton('push', 'ZoomIn', section.Tag, 'zoomIn');
            ZoomOutButton = CreateButton('push', 'ZoomOut', section.Tag, 'zoomOut');
            ZoomResetButton = CreateButton('push', 'ZoomReset', section.Tag, 'refresh');

            % 组装 Column 和 Button
            column1.add(ZoomInButton);
            column2.add(ZoomOutButton);
            column3.add(ZoomResetButton);
            section.add(column1);
            section.add(column2);
            section.add(column3);
            this.Tab.add(section);

            % 添加到 Widgets
            this.Widgets.ZoomSection = struct('ZoomInButton', ZoomInButton, ...
                'ZoomOutButton', ZoomOutButton, 'ZoomResetButton', ZoomResetButton);
        end

        function createNodeSection(this) 
            %CREATERUNNINGSECTION 创建"节点"小节，并添加到 WorkflowTab 中
            import matlab.ui.internal.toolstrip.*
            import kssolv.ui.util.Localizer.message
            import kssolv.ui.util.CreateButton
            import kssolv.ui.util.CreateListItem

            % 创建 Node Section
            section = Section(message("KSSOLV:toolbox:NodeSectionTitle"));
            section.Tag = 'NodeSection';
            % 创建 Column
            column1 = Column();
            column2 = Column();

            % 创建 Button
            AddNoteButton = CreateButton('split', 'AddNote', section.Tag, 'addPointUI');
            EditNoteButton = CreateButton('split', 'EditNote', section.Tag, 'edit_merge');

            % 创建并组装 PopupList(下拉菜单)
            AddNotePopup = PopupList();
            EditNotePopup = PopupList();
            node00ListItem = CreateListItem('default', 'node00', section.Tag, 0);
            node01ListItem = CreateListItem('default', 'node01', section.Tag, 0);
            node10ListItem = CreateListItem('default', 'node10', section.Tag, 0);
            node11ListItem = CreateListItem('default', 'node11', section.Tag, 0);
            node12ListItem = CreateListItem('default', 'node12', section.Tag, 0);
            node21ListItem = CreateListItem('default', 'node21', section.Tag, 0);
            nodexyListItem = CreateListItem('default', 'nodexy', section.Tag, 0);
            AddTopSlotListItem = CreateListItem('default', 'AddTopSlot', section.Tag, 0);
            DelTopSlotListItem = CreateListItem('default', 'DelTopSlot', section.Tag, 0);
            AddBottomSlotListItem = CreateListItem('default', 'AddBottomSlot', section.Tag, 0);
            DelBottomSlotListItem = CreateListItem('default', 'DelBottomSlot', section.Tag, 0);
            AddNotePopup.add(node00ListItem);
            AddNotePopup.addSeparator;
            AddNotePopup.add(node01ListItem);
            AddNotePopup.add(node10ListItem);
            AddNotePopup.addSeparator;
            AddNotePopup.add(node11ListItem);
            AddNotePopup.add(node12ListItem);
            AddNotePopup.add(node21ListItem);
            AddNotePopup.addSeparator;
            AddNotePopup.add(nodexyListItem);
            EditNotePopup.add(AddTopSlotListItem);
            EditNotePopup.add(DelTopSlotListItem);
            EditNotePopup.add(AddBottomSlotListItem);
            EditNotePopup.add(DelBottomSlotListItem);
            AddNoteButton.Popup = AddNotePopup;
            EditNoteButton.Popup = EditNotePopup;

            % 组装 Column 和 Button
            column1.add(AddNoteButton);
            column2.add(EditNoteButton);
            section.add(column1);
            section.add(column2);
            this.Tab.add(section);

            % 添加到 Widgets
            this.Widgets.NodeSection = struct('AddNoteButton', AddNoteButton, ...
                'EditNoteButton', EditNoteButton);
        end

        function createSaveSection(this) 
            %CREATESAVESECTION 创建"保存"小节，并添加到 WorkflowTab 中
            import matlab.ui.internal.toolstrip.*
            import kssolv.ui.util.Localizer.message
            import kssolv.ui.util.CreateButton

            % 创建 Save Section
            section = Section(message("KSSOLV:toolbox:SaveSectionTitle"));
            section.Tag = 'SaveSection';
            % 创建 Column
            column1 = Column();

            % 创建 Button
            SaveWorkflowAsTemplateButton = CreateButton('push', 'SaveWorkflowAsTemplate', section.Tag, 'save_sourceControlChanges');

            % 组装 Column 和 Button
            column1.add(SaveWorkflowAsTemplateButton);
            section.add(column1);
            this.Tab.add(section);

            % 添加到 Widgets
            this.Widgets.SaveSection = struct('SaveWorkflowAsTemplateButton', SaveWorkflowAsTemplateButton);
        end

        function createOperationSection(this) 
            %CREATEOPERATIONSECTION 创建"操作"小节，并添加到 WorkflowTab 中
            import matlab.ui.internal.toolstrip.*
            import kssolv.ui.util.Localizer.message
            import kssolv.ui.util.CreateButton

            % 创建 Operation Section
            section = Section(message("KSSOLV:toolbox:OperationSectionTitle"));
            section.Tag = 'OperationSection';
            % 创建 Column
            column1 = Column();

            % 创建 Button
            OperationUndoButton = CreateButton('push', 'OperationUndo', section.Tag, 'undo');
            OperationRedoButton = CreateButton('push', 'OperationRedo', section.Tag, 'redo');

            % 组装 Column 和 Button
            column1.add(OperationUndoButton);
            column1.add(OperationRedoButton);
            section.add(column1);
            this.Tab.add(section);

            % 添加到 Widgets
            this.Widgets.OperationSection = struct('OperationUndoButton', OperationUndoButton, ...
                'OperationRedoButton', OperationRedoButton);
        end

        function createSettingsSection(this) 
            %CREATESETTINGSSECTION 创建"设置"小节，并添加到 WorkflowTab 中
            import matlab.ui.internal.toolstrip.*
            import kssolv.ui.util.Localizer.message
            import kssolv.ui.util.CreateButton

            % 创建 Settings Section
            section = Section(message("KSSOLV:toolbox:SettingsSectionTitle"));
            section.Tag = 'SettingsSection';
            % 创建 Column
            column1 = Column();

            % 创建 Button
            SetNodeButton = CreateButton('push', 'SetNode', section.Tag, 'settings_decisionTreeMultiple');

            % 组装 Column 和 Button
            column1.add(SetNodeButton);
            section.add(column1);
            this.Tab.add(section);

             % 添加到 Widgets
            this.Widgets.SettingsSection = struct('SetNodeButton', SetNodeButton);
        end

        function createTestGallerySection(this)
            %CREATEPLOTSECTION 创建"绘图"小节，并添加到 WorkflowTab 中
            import matlab.ui.internal.toolstrip.*
            import kssolv.ui.util.Localizer.message
            import kssolv.ui.util.CreateButton

            % 创建 Project Section
            % section = Section(message("KSSOLV:toolbox:PlotSectionTitle"));
            section = Section('PLOTS');
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

            % 添加到 Widgets
            this.Widgets.TestGallerySection = struct('Gallery', gallery);
        end
    end

    methods (Static, Hidden)
        %% 单元测试
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

