classdef HomeTab < handle
    %HOMETAB Toolstrip 菜单栏中的 Home 标签页
    %   开发者：杨柳、高俊
    %   版权 2024 合肥瀚海量子科技有限公司
    
    properties
        % Home 标签页
        Tab
        % 标签
        Tag
        % 标题
        Title
    end
    
    methods
        function this = HomeTab()
            %HOMETAB 构造函数，初始设置相关参数
            import kssolv.ui.util.Localizer.message
            this.Title = message("KSSOLV:toolbox:HomeTabTitle");
            this.Tag = 'HomeTab';
            buildTab(this);
        end
        
        function buildTab(this)
            %BUILDTAB 创建 Home Tab 对象
            this.Tab = matlab.ui.internal.toolstrip.Tab(this.Title);
            this.Tab.Tag = this.Tag;
            % 分别创建各个 Section 并添加到 Home Tab 中
            createProjectSection(this);
            createOperationSection(this);
            createEnvironmentSection(this);
            createResourceSection(this);
        end

        function createProjectSection(this) 
            %CREATEPROJECTSECTION 创建"项目"小节，并添加到 HomeTab 中
            import matlab.ui.internal.toolstrip.*
            import kssolv.ui.util.Localizer.message
            import kssolv.ui.util.CreatButton
            % 创建 Project Section
            section = Section(message("KSSOLV:toolbox:ProjectSectionTitle"));
            section.Tag = 'ProjectSection';
            % 创建 Column
            column1 = Column();
            column2 = Column();
            column3 = Column();
            column4 = Column();
            % 创建 Button
            ProjectOpenButton = CreatButton('split', 'ProjectOpen', section.Tag, Icon.OPEN_24);
            ProjectModelButton = CreatButton('split', 'ProjectModel', section.Tag, Icon.IMPORT_24);
            ProjectSaveButton = CreatButton('split', 'ProjectSave', section.Tag, Icon.SAVE_24);
            ProjectCloseButton = CreatButton('push', 'ProjectClose', section.Tag, Icon.CLOSE_24);
            % 组装 Column 和 Button
            column1.add(ProjectOpenButton);
            column2.add(ProjectModelButton);
            column3.add(ProjectSaveButton);
            column4.add(ProjectCloseButton);
            section.add(column1);
            section.add(column2);
            section.add(column3);
            section.add(column4);
            this.Tab.add(section);
        end
        
        function createOperationSection(this) 
            %CREATEOPERATIONSECTION 创建"操作"小节，并添加到 HomeTab 中
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
        
        function createEnvironmentSection(this) 
            %CREATENVIRONMENTSECTION 创建"环境"小节，并添加到 HomeTab 中
            import matlab.ui.internal.toolstrip.*
            import kssolv.ui.util.Localizer.message
            import kssolv.ui.util.CreatButton
            % 创建 Project Section
            section = Section(message("KSSOLV:toolbox:EnvironmentSectionTitle"));
            section.Tag = 'EnvironmentSection';
            % 创建 Column
            column1 = Column();
            column2 = Column();
            column3 = Column();
            % 创建 Button
            EnvironmentLayoutButton = CreatButton('split', 'EnvironmentLayout', section.Tag, Icon.LAYOUT_24);
            EnvironmentPreferenceButton = CreatButton('push', 'EnvironmentPreference', section.Tag, Icon.SETTINGS_24);
            EnvironmentPreferenceButton.ButtonPushedFcn = @this.moleculerDisplay;
            EnvironmentToolsButton = CreatButton('split', 'EnvironmentTools', section.Tag, Icon.TOOLS_24);
            % 组装 Column 和 Button
            column1.add(EnvironmentLayoutButton);
            column2.add(EnvironmentPreferenceButton);
            column3.add(EnvironmentToolsButton);
            section.add(column1);
            section.add(column2);
            section.add(column3);
            this.Tab.add(section);
        end

        function createResourceSection(this) 
            %CREATERESOURCESECTION 创建"资源"小节，并添加到 HomeTab 中
            import matlab.ui.internal.toolstrip.*
            import kssolv.ui.util.Localizer.message
            import kssolv.ui.util.CreatButton
            % 创建 Project Section
            section = Section(message("KSSOLV:toolbox:ResourceSectionTitle"));
            section.Tag = 'ResourceSection';
            % 创建 Column
            column1 = Column();
            column2 = Column();
            column3 = Column();
            % 创建 Button
            ResourceLibraryButton = CreatButton('push', 'ResourceLibrary', section.Tag, Icon.COMPARE_24);
            ResourceCommunityButton = CreatButton('push', 'ResourceCommunity', section.Tag, Icon.PUBLISH_24);
            ResourceCommunityButton.ButtonPushedFcn = @this.workflowDisplay;
            ResourceHelpButton = CreatButton('split', 'ResourceHelp', section.Tag, Icon.HELP_24);
            % 组装 Column 和 Button
            column1.add(ResourceLibraryButton);
            column2.add(ResourceCommunityButton);
            column3.add(ResourceHelpButton);
            section.add(column1);
            section.add(column2);
            section.add(column3);
            this.Tab.add(section);
        end

        function moleculerDisplay(~, ~, ~)
            kssolv.ui.components.figuredocument.MoleculerDisplay().Display();
        end

        function workflowDisplay(~, ~, ~)
            kssolv.ui.components.figuredocument.Workflow().Display();
        end

    end

    methods (Static, Hidden)
        function app = qeShow()
            % 用于在单元测试中测试 HomeTab，可通过下面的命令使用：
            % kssolv.ui.components.tab.HomeTab.qeShow();

            % 创建 AppContainer          
            appOptions.Tag = sprintf('kssolv(%s)', char(matlab.lang.internal.uuid));
            appOptions.Title = kssolv.ui.util.Localizer.message('KSSOLV:toolbox:UnitTestTitle');
            appOptions.ToolstripEnabled = true;
            app = matlab.ui.container.internal.AppContainer(appOptions);

            % 添加 HomeTab
            homeTab = kssolv.ui.components.tab.HomeTab();
            tabGroup = matlab.ui.internal.toolstrip.TabGroup();
            tabGroup.Tag = 'kssolvTabGroup';
            tabGroup.add(homeTab.Tab);
            app.add(tabGroup);

            % 展示界面
            app.Visible = true;
        end
    end

end

