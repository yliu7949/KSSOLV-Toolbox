classdef HomeTab < handle
    %HOMETAB Toolstrip 菜单栏中的 Home 标签页

    %   开发者：杨柳、高俊、林海饶
    %   版权 2024 合肥瀚海量子科技有限公司
    
    properties
        Tab       % Home 标签页
        Tag       % 标签
        Title     % 标题
        Widgets   % 小组件
    end
    
    methods
        function this = HomeTab()
            %HOMETAB 构造函数，初始设置相关参数
            import kssolv.ui.util.Localizer.message
            this.Title = message("KSSOLV:toolbox:HomeTabTitle");
            this.Tag = 'HomeTab';

            buildTab(this);
            connectTab(this);
            setTabActivated(this);
        end
    end

    methods (Access = protected) 
        function buildTab(this)
            %BUILDTAB 创建 Home Tab 对象
            this.Tab = matlab.ui.internal.toolstrip.Tab(this.Title);
            this.Tab.Tag = this.Tag;

            % 分别创建各个 Section 并添加到 Home Tab 中
            createFileSection(this);
            createProjectSection(this);
            createRunningSection(this)
            createEnvironmentSection(this);
            createResourceSection(this);
        end

        function connectTab(this)
            %CONNECTTAB 为按钮等组件添加监听器和回调函数
            % File Section
            % Project Section
            addlistener(this.Widgets.ProjectSection.ProjectStructureButton, ...
                'ButtonPushed', @(src, data) callbackProjectStructureButton(this));
            addlistener(this.Widgets.ProjectSection.ProjectStructureButton.Popup.getChildByIndex(1), ...
                'ItemPushed', @(src, data) callbackImportStructureFromFile(this));
            addlistener(this.Widgets.ProjectSection.ProjectWorkflowButton, ...
                'ButtonPushed', @(src, data) callbackProjectWorkflowButton(this));
            addlistener(this.Widgets.ProjectSection.ProjectWorkflowButton.Popup.getChildByIndex(2), ...
                'ItemPushed', @(src, data) callbackImportTemplateWorkflow(this));
            % Running Section
            addlistener(this.Widgets.RunningSection.RunningRunButton, ...
                'ButtonPushed', @(src, data) callbackRunningRunButton(this));
            addlistener(this.Widgets.RunningSection.RunningStopButton, ...
                'ButtonPushed', @(src, data) callbackRunningStopButton(this))
            % Environment Section
            % Resource Section
        end

        function setTabActivated(this)
            %SETTABACTIVATED 初始化时设置一些按钮是否被启用
            this.Widgets.RunningSection.RunningStepButton.Enabled = false;
            this.Widgets.RunningSection.RunningStopButton.Enabled = false;
        end
    end

    methods (Access = private)
        %% 创建 Sections
        function createFileSection(this) 
            %CREATEFILESECTION 创建"文件"小节，并添加到 HomeTab 中
            import matlab.ui.internal.toolstrip.*
            import kssolv.ui.util.Localizer.message
            import kssolv.ui.util.CreateButton
            import kssolv.ui.util.CreateListItem

            % 创建 File Section
            section = Section(message("KSSOLV:toolbox:FileSectionTitle"));
            section.Tag = 'FileSection';
            % 创建 Column
            column1 = Column();
            column2 = Column();
            column3 = Column();

            % 创建 Button
            FileProjectButton = CreateButton('split', 'FileProject', section.Tag, 'openFolder');
            FileSaveButton = CreateButton('split', 'FileSave', section.Tag, 'unsaved');
            FileCloseButton = CreateButton('push', 'FileClose', section.Tag, 'close');

            % 创建并组装 PopupList(下拉菜单)
            FileProjectButtonPopup = PopupList();
            OpenFileListItem = CreateListItem('default', 'OpenFile', section.Tag, 0, 'new');
            FileProjectButtonPopup.add(OpenFileListItem);
            FileProjectButton.Popup = FileProjectButtonPopup;

            FileSaveButtonPopup = PopupList();
            SaveProjectListItem = CreateListItem('default', 'SaveProject', section.Tag, 0, 'saved');
            SaveProjectAsListItem = CreateListItem('default', 'SaveProjectAs', section.Tag, 0, 'saveAs');
            SaveStructureAsListItem = CreateListItem('default', 'SaveStructureAs', section.Tag, 0, 'save_renderedVolume');
            FileSaveButtonPopup.add(SaveProjectListItem);
            FileSaveButtonPopup.add(SaveProjectAsListItem);
            FileSaveButtonPopup.add(SaveStructureAsListItem);
            FileSaveButton.Popup = FileSaveButtonPopup;

            % 组装 Column 和 Button
            column1.add(FileProjectButton);
            column2.add(FileSaveButton);
            column3.add(FileCloseButton);
            section.add(column1);
            section.add(column2);
            section.add(column3);
            this.Tab.add(section);

            % 添加到 Widgets
            this.Widgets.FileSection = struct('FileProjectButton', FileProjectButton, ...
                'FileSaveButton', FileSaveButton, 'FileCloseButton', FileCloseButton);
        end

        function createProjectSection(this) 
            %CREATEPROJECTSECTION 创建"项目"小节，并添加到 HomeTab 中
            import matlab.ui.internal.toolstrip.*
            import kssolv.ui.util.Localizer.message
            import kssolv.ui.util.CreateButton
            import kssolv.ui.util.CreateListItem

            % 创建 Project Section
            section = Section(message("KSSOLV:toolbox:ProjectSectionTitle"));
            section.Tag = 'ProjectSection';
            % 创建 Column
            column1 = Column();
            column2 = Column();
            column3 = Column();

            % 创建 Button
            ProjectStructureButton = CreateButton('split', 'ProjectStructure', section.Tag, 'import_data');
            ProjectWorkflowButton = CreateButton('split', 'ProjectWorkflow', section.Tag, 'artifactGraph');
            ProjectVariableButton = CreateButton('split', 'ProjectVariable', section.Tag, 'legend');
            
            % 创建并组装 PopupList(下拉菜单)
            ProjectStructureButtonPopup = PopupList();
            ImportStructureFromFileListItem = CreateListItem('default', 'ImportStructureFromFile', section.Tag, 0, 'importDiagram');
            ImportStructureFromLinkListItem = CreateListItem('default', 'ImportStructureFromLink', section.Tag, 0, 'link_project');
            ImportStructureFromLibraryListItem = CreateListItem('default', 'ImportStructureFromLibrary', section.Tag, 0, 'database_projectYellow');
            ImportStructureFromMatlabListItem = CreateListItem('default', 'ImportStructureFromMatlab', section.Tag, 0, 'matlabWorkspaceFile');

            ProjectWorkflowButtonPopup = PopupList();
            NewWorkflowListItem = CreateListItem('default', 'NewWorkflow', section.Tag, 0, 'add_class');
            ImportTemplateWorkflowListItem = CreateListItem('default', 'ImportTemplateWorkflow', section.Tag, 0, 'add_artifactGraph');
            ExportTemplateWorkflowListItem = CreateListItem('default', 'ExportTemplateWorkflow', section.Tag, 0, 'save_sourceControlChanges');

            ProjectVariableButtonPopup = PopupList();
            NewVariableListItem = CreateListItem('default', 'NewVariable', section.Tag, 0, 'new_sectionHighlighted');
            ImportVariableFromFileListItem = CreateListItem('default', 'ImportVariableFromFile', section.Tag, 0, 'importDiagram');
            ImportVariableFromMATLABListItem = CreateListItem('default', 'ImportVariableFromMATLAB', section.Tag, 0, 'matlabWorkspaceFile');
           
            ProjectStructureButtonPopup.add(ImportStructureFromFileListItem)
            ProjectStructureButtonPopup.add(ImportStructureFromLinkListItem);
            ProjectStructureButtonPopup.add(ImportStructureFromLibraryListItem);
            ProjectStructureButtonPopup.add(ImportStructureFromMatlabListItem);
            ProjectWorkflowButtonPopup.add(NewWorkflowListItem);
            ProjectWorkflowButtonPopup.add(ImportTemplateWorkflowListItem);
            ProjectWorkflowButtonPopup.add(ExportTemplateWorkflowListItem);
            ProjectVariableButtonPopup.add(NewVariableListItem);
            ProjectVariableButtonPopup.add(ImportVariableFromFileListItem);
            ProjectVariableButtonPopup.add(ImportVariableFromMATLABListItem);
            ProjectStructureButton.Popup = ProjectStructureButtonPopup;
            ProjectWorkflowButton.Popup = ProjectWorkflowButtonPopup;
            ProjectVariableButton.Popup = ProjectVariableButtonPopup;
            
            % 组装 Column 和 Button
            column1.add(ProjectStructureButton);
            column2.add(ProjectWorkflowButton);
            column3.add(ProjectVariableButton);
            section.add(column1);
            section.add(column2);
            section.add(column3);
            this.Tab.add(section);

            % 添加到 Widgets
            this.Widgets.ProjectSection = struct('ProjectStructureButton', ProjectStructureButton, ...
                'ProjectWorkflowButton', ProjectWorkflowButton, 'ProjectVariableButton', ProjectVariableButton);
        end
        
        function createRunningSection(this) 
            %CREATERUNNINGSECTION 创建"运行"小节，并添加到 HomeTab 中
            import matlab.ui.internal.toolstrip.*
            import kssolv.ui.util.Localizer.message
            import kssolv.ui.util.CreateButton
            import kssolv.ui.util.CreateListItem

            % 创建 File Section
            section = Section(message("KSSOLV:toolbox:RunningSectionTitle"));
            section.Tag = 'RunningSection';
            % 创建 Column
            column1 = Column();
            column2 = Column();
            column3 = Column();

            % 创建 Button
            RunningRunButton = CreateButton('split', 'RunningRun', section.Tag, 'playControl');
            RunningStepButton = CreateButton('push', 'RunningStep', section.Tag, 'stepForward');
            RunningStopButton = CreateButton('push', 'RunningStop', section.Tag, 'stop');

            % 创建并组装 PopupList(下拉菜单)
            RunPopup = PopupList();
            RunAndTimeListItem = CreateListItem('default', 'RunAndTime', section.Tag, 1, 'runAndTime');
            RunPopup.add(RunAndTimeListItem);
            RunningRunButton.Popup = RunPopup;

            % 组装 Column 和 Button
            column1.add(RunningRunButton);
            column2.add(RunningStepButton);
            column3.add(RunningStopButton);
            section.add(column1);
            section.add(column2);
            section.add(column3);
            this.Tab.add(section);

            % 添加到 Widgets
            this.Widgets.RunningSection = struct('RunningRunButton', RunningRunButton, ...
                'RunningStepButton', RunningStepButton, 'RunningStopButton', RunningStopButton);
        end
            
        function createEnvironmentSection(this) 
            %CREATENVIRONMENTSECTION 创建"环境"小节，并添加到 HomeTab 中
            import matlab.ui.internal.toolstrip.*
            import kssolv.ui.util.Localizer.message
            import kssolv.ui.util.CreateButton
            import kssolv.ui.util.CreateListItem
            import kssolv.ui.util.GetIcon

            % 创建 Environment Section
            section = Section(message("KSSOLV:toolbox:EnvironmentSectionTitle"));
            section.Tag = 'EnvironmentSection';
            % 创建 Column
            column1 = Column();
            column2 = Column();
            column3 = Column();
            column4 = Column();

            % 创建 Button
            EnvironmentSettingsButton = CreateButton('push', 'EnvironmentSettings', section.Tag, 'settings');
            EnvironmentRemoteButton = CreateButton('split', 'EnvironmentRemote', section.Tag, 'matlabCloud');
            EnvironmentParallelButton = CreateButton('push', 'EnvironmentParallel', section.Tag, 'parallel');
            EnvironmentExtraButton = CreateButton('split', 'EnvironmentExtra', section.Tag, 'addOns');
            
            % 创建并组装 PopupList(下拉菜单)
            RemotePopup = PopupList();
            ExtraPopup = PopupList();
            ConnectToClusterListItem = CreateListItem('default', 'ConnectToCluster', section.Tag, 0, 'new_cloud');
            GetExtraFeatureListItem = CreateListItem('default', 'GetExtraFeature', section.Tag, 0, 'addOnsSB');
            RemotePopup.add(ConnectToClusterListItem);
            ExtraPopup.add(GetExtraFeatureListItem);
            EnvironmentRemoteButton.Popup = RemotePopup;
            EnvironmentExtraButton.Popup = ExtraPopup;
        
            % 组装 Column 和 Button
            column1.add(EnvironmentSettingsButton);
            column2.add(EnvironmentRemoteButton);
            column3.add(EnvironmentParallelButton);
            column4.add(EnvironmentExtraButton);
            section.add(column1);
            section.add(column2);
            section.add(column3);
            section.add(column4);
            this.Tab.add(section);

            % 添加到 Widgets
            this.Widgets.EnvironmentSection = struct('EnvironmentSettingsButton', EnvironmentSettingsButton, ...
                'EnvironmentRemoteButton', EnvironmentRemoteButton, 'EnvironmentParallelButton', EnvironmentParallelButton, ...
                'EnvironmentExtraButton', EnvironmentExtraButton);
        end

        function createResourceSection(this) 
            %CREATERESOURCESECTION 创建"资源"小节，并添加到 HomeTab 中
            import matlab.ui.internal.toolstrip.*
            import kssolv.ui.util.Localizer.message
            import kssolv.ui.util.CreateButton
            import kssolv.ui.util.CreateListItem

            % 创建 Resource Section
            section = Section(message("KSSOLV:toolbox:ResourceSectionTitle"));
            section.Tag = 'ResourceSection';
            % 创建 Column
            column1 = Column();
            column2 = Column();
            column3 = Column();
            column4 = Column();

            % 创建 Button
            ResourceLibraryButton = CreateButton('push', 'ResourceLibrary', section.Tag, 'documentation');
            ResourceCommunityButton = CreateButton('push', 'ResourceCommunity', section.Tag, 'community');
            ResourceHelpButton = CreateButton('split', 'ResourceHelp', section.Tag, 'help');
            ResourceSupportButton = CreateButton('push', 'ResourceSupport', section.Tag, 'helpRecolorUI');
            
            % 创建并组装 PopupList(下拉菜单)
            HelpPopup = PopupList();
            OpenDocumentListItem = CreateListItem('default', 'OpenDocument', section.Tag, 0, 'documentList');
            OfficialSiteListItem = CreateListItem('default', 'OfficialSite', section.Tag, 0, 'link');
            CheckUpdateListItem = CreateListItem('default', 'CheckUpdate', section.Tag);
            CheckLicenseListItem = CreateListItem('default', 'CheckLicense', section.Tag);
            TermsOfUseListItem = CreateListItem('default', 'TermsOfUse', section.Tag);
            AboutUsListItem = CreateListItem('default', 'AboutUs', section.Tag);
            HelpPopup.add(OpenDocumentListItem);
            HelpPopup.add(OfficialSiteListItem);
            HelpPopup.add(PopupListHeader(''));
            HelpPopup.add(CheckUpdateListItem);
            HelpPopup.add(CheckLicenseListItem);
            HelpPopup.add(TermsOfUseListItem);
            HelpPopup.add(AboutUsListItem);
            ResourceHelpButton.Popup = HelpPopup;

            % 组装 Column 和 Button
            column1.add(ResourceLibraryButton);
            column2.add(ResourceCommunityButton);
            column3.add(ResourceHelpButton);
            column4.add(ResourceSupportButton);
            section.add(column1);
            section.add(column2);
            section.add(column3);
            section.add(column4);
            this.Tab.add(section);

            % 添加到 Widgets
            this.Widgets.ResourceSection = struct('ResourceLibraryButton', ResourceLibraryButton, ...
                'ResourceCommunityButton', ResourceCommunityButton, 'ResourceHelpButton', ResourceHelpButton, ...
                'ResourceSupportButton', ResourceSupportButton);
        end

        %% 回调函数
        function callbackProjectStructureButton(~, ~, ~)
            kssolv.ui.components.figuredocument.MoleculerDisplay().Display();
        end

        function callbackImportStructureFromFile(~, ~, ~)
            project = kssolv.ui.util.DataStorage.getData('Project');
            for i = 1:length(project.children)
                if startsWith(project.children{i, 1}.name, 'Structure')
                    item = project.children{i, 1};
                end
            end
            if ~isempty(item)
                importedFileCount = item.importStructureFromFile();
                if importedFileCount > 0
                    projectBrowser = kssolv.ui.util.DataStorage.getData('ProjectBrowser');
                    startIndex = numel(item.children) - importedFileCount + 1;
                    for index = startIndex : numel(item.children)
                        projectBrowser.updateTreetable('ADD', item.name, item.children{index}.encodeToJSON(1));
                    end
                    projectBrowser.updateTreetable('PATCH', item.name, item.encodeToJSON(1));
                end
            end
        end

        function callbackProjectWorkflowButton(~, ~, ~)
            kssolv.ui.components.figuredocument.Workflow().Display();
        end

        function callbackImportTemplateWorkflow(~, ~, ~)
            import kssolv.ui.components.dialog.BuildWorkflowFromTemplate
            import kssolv.ui.util.DataStorage
            BuildWorkflowFromTemplate().show(DataStorage.getData('AppContainer'));
        end

        function callbackRunningRunButton(this, ~, ~)
            this.Widgets.RunningSection.RunningRunButton.Enabled = false;
            this.Widgets.RunningSection.RunningStopButton.Enabled = true;

            app = kssolv.ui.util.DataStorage.getData('AppContainer');
            app.Busy = true;
            pause(3)
            app.Busy = false;

            figFileDir = fullfile(fileparts(fileparts(fileparts(mfilename('fullpath')))), ...
                '+components/+figuredocument/@DataPlot/test/');
            kssolv.ui.components.figuredocument.DataPlot(fullfile(figFileDir, 'gtk.fig')).Display();
            pause(2)
            kssolv.ui.components.figuredocument.DataPlot(fullfile(figFileDir, 'h2o.fig')).Display();
            pause(2)
            kssolv.ui.components.figuredocument.DataPlot(fullfile(figFileDir, 'si.fig')).Display();
            pause(1)
            
            this.Widgets.RunningSection.RunningRunButton.Enabled = true;
            this.Widgets.RunningSection.RunningStopButton.Enabled = false;
        end

        function callbackRunningStopButton(this, ~, ~)
            this.Widgets.RunningSection.RunningRunButton.Enabled = true;
            this.Widgets.RunningSection.RunningStopButton.Enabled = false;
        end
    end

    methods (Static, Hidden)
        %% 单元测试
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

