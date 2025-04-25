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

        function connectTab(this)
            %CONNECTTAB 为按钮等组件添加监听器和回调函数
            % Save Section
            addlistener(this.Widgets.SaveSection.SaveWorkflowAsTemplateButton, ...
                'ButtonPushed', @(src, data) callbackSaveWorkflowAsTemplateButton(this));
            % Operation Section
            addlistener(this.Widgets.OperationSection.OperationUndoButton, ...
                'ButtonPushed', @(src, data) callbackOperationUndoButton(this));
            addlistener(this.Widgets.OperationSection.OperationRedoButton, ...
                'ButtonPushed', @(src, data) callbackOperationRedoButton(this));
            % Node Section
            addlistener(this.Widgets.NodeSection.AddNodeButton, ...
                'ButtonPushed', @(src, data) callbackAddNodeButton(this));
            addlistener(this.Widgets.NodeSection.EditNodeButton.Popup.getChildByIndex(1), ...
                'ItemPushed', @(src, data) callbackAddTopPortListItem(this));
            addlistener(this.Widgets.NodeSection.EditNodeButton.Popup.getChildByIndex(2), ...
                'ItemPushed', @(src, data) callbackRemoveTopPortListItem(this));
            addlistener(this.Widgets.NodeSection.EditNodeButton.Popup.getChildByIndex(3), ...
                'ItemPushed', @(src, data) callbackAddBottomPortListItem(this));
            addlistener(this.Widgets.NodeSection.EditNodeButton.Popup.getChildByIndex(4), ...
                'ItemPushed', @(src, data) callbackRemoveBottomPortListItem(this));
            % Zoom Section
            addlistener(this.Widgets.ZoomSection.ZoomInButton, ...
                'ButtonPushed', @(src, data) callbackZoomInButton(this));
            addlistener(this.Widgets.ZoomSection.ZoomOutButton, ...
                'ButtonPushed', @(src, data) callbackZoomOutButton(this));
            addlistener(this.Widgets.ZoomSection.ZoomResetButton, ...
                'ButtonPushed', @(src, data) callbackZoomResetButton(this));
        end

        function setTabActivated(~)
            %SETTABACTIVATED 初始化时设置一些按钮是否被启用
        end
    end

    methods (Access = private)
        %% 创建 Sections
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
            AddNodeButton = CreateButton('split', 'AddNode', section.Tag, 'addPointUI');
            EditNodeButton = CreateButton('split', 'EditNode', section.Tag, 'edit_merge');

            % 创建并组装 PopupList(下拉菜单)
            AddNodePopup = PopupList();
            EditNodePopup = PopupList();
            node00ListItem = CreateListItem('default', 'node00', section.Tag, 0);
            node01ListItem = CreateListItem('default', 'node01', section.Tag, 0);
            node10ListItem = CreateListItem('default', 'node10', section.Tag, 0);
            node11ListItem = CreateListItem('default', 'node11', section.Tag, 0);
            node12ListItem = CreateListItem('default', 'node12', section.Tag, 0);
            node21ListItem = CreateListItem('default', 'node21', section.Tag, 0);
            nodexyListItem = CreateListItem('default', 'nodexy', section.Tag, 0);
            AddTopPortListItem = CreateListItem('default', 'AddTopPort', section.Tag, 0);
            RemoveTopPortListItem = CreateListItem('default', 'RemoveTopPort', section.Tag, 0);
            AddBottomPortListItem = CreateListItem('default', 'AddBottomPort', section.Tag, 0);
            RemoveBottomPortListItem = CreateListItem('default', 'RemoveBottomPort', section.Tag, 0);
            AddNodePopup.add(node00ListItem);
            AddNodePopup.addSeparator;
            AddNodePopup.add(node01ListItem);
            AddNodePopup.add(node10ListItem);
            AddNodePopup.addSeparator;
            AddNodePopup.add(node11ListItem);
            AddNodePopup.add(node12ListItem);
            AddNodePopup.add(node21ListItem);
            AddNodePopup.addSeparator;
            AddNodePopup.add(nodexyListItem);
            EditNodePopup.add(AddTopPortListItem);
            EditNodePopup.add(RemoveTopPortListItem);
            EditNodePopup.add(AddBottomPortListItem);
            EditNodePopup.add(RemoveBottomPortListItem);
            AddNodeButton.Popup = AddNodePopup;
            EditNodeButton.Popup = EditNodePopup;

            % 组装 Column 和 Button
            column1.add(AddNodeButton);
            column2.add(EditNodeButton);
            section.add(column1);
            section.add(column2);
            this.Tab.add(section);

            % 添加到 Widgets
            this.Widgets.NodeSection = struct('AddNodeButton', AddNodeButton, ...
                'EditNodeButton', EditNodeButton);
        end

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

        %% 回调函数
        function callbackSaveWorkflowAsTemplateButton(~)
            kssolv.ui.components.figuredocument.Workflow.sendEventToWorkflowUI('workflowExportToJSON');
        end

        function callbackOperationUndoButton(~)
            kssolv.ui.components.figuredocument.Workflow.sendEventToWorkflowUI('workflowUndo');
        end

        function callbackOperationRedoButton(~)
            kssolv.ui.components.figuredocument.Workflow.sendEventToWorkflowUI('workflowRedo');
        end

        function callbackAddNodeButton(~)
            kssolv.ui.components.figuredocument.Workflow.sendEventToWorkflowUI('workflowAddNode');
        end

        function callbackAddTopPortListItem(~)
            kssolv.ui.components.figuredocument.Workflow.sendEventToWorkflowUI('workflowAddTopPort');
        end

        function callbackRemoveTopPortListItem(~)
            kssolv.ui.components.figuredocument.Workflow.sendEventToWorkflowUI('workflowRemoveTopPort');
        end

        function callbackAddBottomPortListItem(~)
            kssolv.ui.components.figuredocument.Workflow.sendEventToWorkflowUI('workflowAddBottomPort');
        end

        function callbackRemoveBottomPortListItem(~)
            kssolv.ui.components.figuredocument.Workflow.sendEventToWorkflowUI('workflowRemoveBottomPort');
        end

        function callbackZoomInButton(~)
            kssolv.ui.components.figuredocument.Workflow.sendEventToWorkflowUI('workflowZoomIn');
        end

        function callbackZoomOutButton(~)
            kssolv.ui.components.figuredocument.Workflow.sendEventToWorkflowUI('workflowZoomOut');
        end

        function callbackZoomResetButton(~)
            kssolv.ui.components.figuredocument.Workflow.sendEventToWorkflowUI('workflowZoomToFit');
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

