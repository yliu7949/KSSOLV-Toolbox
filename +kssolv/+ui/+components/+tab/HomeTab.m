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
            import kssolv.ui.util.CreatButton
            import kssolv.ui.util.CreateListItem

            % 创建 File Section
            section = Section(message("KSSOLV:toolbox:FileSectionTitle"));
            section.Tag = 'FileSection';
            % 创建 Column
            column1 = Column();
            column2 = Column();
            column3 = Column();

            % 创建 Button
            FileProjectButton = CreatButton('split', 'FileProject', section.Tag, Icon.OPEN_24);
            FileSaveButton = CreatButton('split', 'FileSave', section.Tag, Icon.SAVE_24);
            FileCloseButton = CreatButton('push', 'FileClose', section.Tag, Icon.CLOSE_24);

            % 创建并组装 PopupList(下拉菜单)
            FileProjectButtonPopup = PopupList();
            OpenFile = CreateListItem('OpenFile', section.Tag, Icon.ADD_16);
            FileProjectButtonPopup.add(OpenFile);
            FileProjectButton.Popup = FileProjectButtonPopup;
            FileSaveButtonPopup = PopupList();
            SaveProject = CreateListItem('SaveProject', section.Tag, 'none');
            SaveProjectAs = CreateListItem('SaveProjectAs', section.Tag, 'none');
            SaveStructureAs = CreateListItem('SaveStructureAs', section.Tag, 'none');
            FileSaveButtonPopup.add(SaveProject);
            FileSaveButtonPopup.add(SaveProjectAs);
            FileSaveButtonPopup.add(SaveStructureAs);
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
            import kssolv.ui.util.CreatButton
            import kssolv.ui.util.CreateListItem

            % 创建 Project Section
            section = Section(message("KSSOLV:toolbox:ProjectSectionTitle"));
            section.Tag = 'ProjectSection';
            % 创建 Column
            column1 = Column();
            column2 = Column();
            column3 = Column();

            % 创建 Button
            ProjectStructureButton = CreatButton('split', 'ProjectStructure', section.Tag, Icon.FIND_FILES_24);
            ProjectWorkflowButton = CreatButton('split', 'ProjectWorkflow', section.Tag, Icon.PLAY_24);
            ProjectVariableButton = CreatButton('split', 'ProjectVariable', section.Tag, Icon.LEGEND_24);
            
            % 创建并组装 PopupList(下拉菜单)
            ProjectStructureButtonPopup = PopupList();
            ImportStructureFromFile = CreateListItem('ImportStructureFromFile', section.Tag, 'none');
            ImportStructureFromLink = CreateListItem('ImportStructureFromLink', section.Tag, 'none');
            ImportStructureFromLibrary = CreateListItem('ImportStructureFromLibrary', section.Tag, 'none');
            ImportStructureFromMatlab = CreateListItem('ImportStructureFromMatlab', section.Tag, 'none');

            ProjectWorkflowButtonPopup = PopupList();
            NewWorkflow = CreateListItem('NewWorkflow', section.Tag, 'none');
            ImportTemplateWorkflow = CreateListItem('ImportTemplateWorkflow', section.Tag, 'none');
            ExportTemplateWorkflow = CreateListItem('ExportTemplateWorkflow', section.Tag, 'none');

            ProjectVariableButtonPopup = PopupList();
            NewVariable = CreateListItem('NewVariable', section.Tag, 'none');
            ImportVariableFromFile = CreateListItem('ImportVariableFromFile', section.Tag, 'none');
            ImportVariableFromMATLAB = CreateListItem('ImportVariableFromMATLAB', section.Tag, 'none');
           
            ProjectStructureButtonPopup.add(ImportStructureFromFile)
            ProjectStructureButtonPopup.add(ImportStructureFromLink);
            ProjectStructureButtonPopup.add(ImportStructureFromLibrary);
            ProjectStructureButtonPopup.add(ImportStructureFromMatlab);
            ProjectWorkflowButtonPopup.add(NewWorkflow);
            ProjectWorkflowButtonPopup.add(ImportTemplateWorkflow);
            ProjectWorkflowButtonPopup.add(ExportTemplateWorkflow);
            ProjectVariableButtonPopup.add(NewVariable);
            ProjectVariableButtonPopup.add(ImportVariableFromFile);
            ProjectVariableButtonPopup.add(ImportVariableFromMATLAB);
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
            import kssolv.ui.util.CreatButton
            import kssolv.ui.util.CreateListItem

            % 创建 File Section
            section = Section(message("KSSOLV:toolbox:RunningSectionTitle"));
            section.Tag = 'RunningSection';
            % 创建 Column
            column1 = Column();
            column2 = Column();
            column3 = Column();

            % 创建 Button
            RunningRunButton = CreatButton('split', 'RunningRun', section.Tag, Icon.RUN_24);
            RunningStepButton = CreatButton('push', 'RunningStep', section.Tag, Icon.FORWARD_24);
            RunningStopButton = CreatButton('push', 'RunningStop', section.Tag, Icon.END_24);

            % 创建并组装 PopupList(下拉菜单)
            RunPopup = PopupList();
            RunAndTime = CreateListItem('RunAndTime', section.Tag, 'none');
            RunPopup.add(RunAndTime);
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
            import kssolv.ui.util.CreatButton
            import kssolv.ui.util.CreateListItem

            % 创建 Environment Section
            section = Section(message("KSSOLV:toolbox:EnvironmentSectionTitle"));
            section.Tag = 'EnvironmentSection';
            % 创建 Column
            column1 = Column();
            column2 = Column();
            column3 = Column();
            column4 = Column();

            % 创建 Button
            EnvironmentSettingsButton = CreatButton('push', 'EnvironmentSettings', section.Tag, Icon.SETTINGS_24);
            EnvironmentRemoteButton = CreatButton('split', 'EnvironmentRemote', section.Tag, Icon.PROPERTIES_24);
            EnvironmentParallelButton = CreatButton('push', 'EnvironmentParallel', section.Tag, Icon.PARALLEL_24);
            EnvironmentExtraButton = CreatButton('split', 'EnvironmentExtra', section.Tag, Icon.TOOLS_24);
            
            % 创建并组装 PopupList(下拉菜单)
            RemotePopup = PopupList();
            ExtraPopup = PopupList();
            ConnectToCluster = CreateListItem('ConnectToCluster', section.Tag, 'none');
            GetExtraFeature = CreateListItem('GetExtraFeature', section.Tag, 'none');
            RemotePopup.add(ConnectToCluster);
            ExtraPopup.add(GetExtraFeature);
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
            import kssolv.ui.util.CreatButton
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
            ResourceLibraryButton = CreatButton('push', 'ResourceLibrary', section.Tag, Icon.COMPARE_24);
            ResourceCommunityButton = CreatButton('push', 'ResourceCommunity', section.Tag, Icon.PUBLISH_24);
            ResourceHelpButton = CreatButton('split', 'ResourceHelp', section.Tag, Icon.HELP_24);
            ResourceSupportButton = CreatButton('push', 'ResourceSupport', section.Tag, Icon.HELP_24);
            
            % 创建并组装 PopupList(下拉菜单)
            HelpPopup = PopupList();
            OpenDocument = CreateListItem('OpenDocument', section.Tag, 'none');
            OfficialSite = CreateListItem('OfficialSite', section.Tag, 'none');
            CheckUpdate = CreateListItem('CheckUpdate', section.Tag, 'none');
            CheckLicense = CreateListItem('CheckLicense', section.Tag, 'none');
            TermsOfUse = CreateListItem('TermsOfUse', section.Tag, 'none');
            AboutUs = CreateListItem('AboutUs', section.Tag, 'none');
            HelpPopup.add(OpenDocument);
            HelpPopup.add(OfficialSite);
            HelpPopup.add(CheckUpdate);
            HelpPopup.add(CheckLicense);
            HelpPopup.add(TermsOfUse);
            HelpPopup.add(AboutUs);
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
            import kssolv.ui.util.Localizer.message
            [files, path] = uigetfile({'*.cif';'*.vasp';'*.*'}, ...
                message("KSSOLV:dialog:ImportStructureFromFile"), 'MultiSelect', 'on');
            if ~isequal(files, 0)
                % 如果用户没有点击取消按钮，并且选择了文件
                for i = 1:length(files)
                    % 拼接完整的文件路径
                    fullPath = fullfile(path, files{i});

                    % 渲染结构文件中的结构
                    displayObj = kssolv.ui.components.figuredocument.MoleculerDisplay(fullPath);
                    displayObj.Display();
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

            figFileDir = '+kssolv/+ui/+components/+figuredocument/@DataPlot/test/';
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
            appOptions.Tag = sprintf('kssolv(%s)',char(matlab.lang.internal.uuid));
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

