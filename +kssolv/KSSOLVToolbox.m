classdef KSSOLVToolbox < handle
    %KSSOLVTOOLBOX 排列和布局相关 UI 组件，生成 KSSOLV Toolbox 的完整用户图形界面
    
    %   开发者：杨柳
    %   版权 2024 合肥瀚海量子科技有限公司
    
    properties (Access = public)
        Name string
        AppContainer matlab.ui.container.internal.AppContainer
        HostInBrowser (1, 1) logical = false
    end
    
    methods
        function this = KSSOLVToolbox()
            %KSSOLVTOOLBOX 构造此类的实例

            import kssolv.ui.util.Localizer.*
            % setLocale('zh_CN');

            % 创建 App Container
            appOptions.Title = 'KSSOLV Toolbox';
            appOptions.Tag = sprintf('kssolv(%s)', char(matlab.lang.internal.uuid));
            appOptions.ToolstripEnabled = true;
            appOptions.EnableTheming = true;
            this.AppContainer = matlab.ui.container.internal.AppContainer(appOptions);
            this.Name = this.AppContainer.Tag;
            % 保存 AppContainer 至 DataStorage
            kssolv.ui.util.DataStorage.setData('AppContainer', this.AppContainer);
            % 设定 App Container 的标题
            kssolv.KSSOLVToolbox.setAppContainerTitle();
            % 添加工作区文字
            msg = message('KSSOLV:toolbox:WelcomeMessage');
            this.AppContainer.DocumentPlaceHolderText = msg;
            % 监听 App Container 的状态改变，例如关闭 App 时会触发 StateChanged 事件
            addlistener(this.AppContainer, 'StateChanged', @(src,data) callbackAppStateChanged(this));
            % 添加多个 Data Browser 组件
            projectBrowser = kssolv.ui.components.databrowser.ProjectBrowser();
            projectBrowser.addToAppContainer(this.AppContainer);
            infoBrowser = kssolv.ui.components.databrowser.InfoBrowser();
            infoBrowser.addToAppContainer(this.AppContainer);
            configBrowser = kssolv.ui.components.databrowser.ConfigBrowser();
            configBrowser.addToAppContainer(this.AppContainer);
            runBrowser = kssolv.ui.components.databrowser.RunBrowser();
            runBrowser.addToAppContainer(this.AppContainer);
            this.setPanelLayout();
            % 添加多个 Tab 组件
            homeTab = kssolv.ui.components.tab.HomeTab();
            workflowTab = kssolv.ui.components.tab.WorkflowTab();
            tabGroup = matlab.ui.internal.toolstrip.TabGroup();
            tabGroup.Tag = 'kssolvTabGroup';
            tabGroup.add(homeTab.Tab);
            tabGroup.add(workflowTab.Tab);
            this.AppContainer.add(tabGroup);
            % 添加位于底部的 FooterBar 组件
            footerBar = kssolv.ui.components.others.FooterBar();
            footerBar.addToAppContainer(this.AppContainer);
            % 添加位于右上角的 QuickAccessBar 组件
            quickAccessBar = kssolv.ui.components.others.QuickAccessBar();
            quickAccessBar.addToAppContainer(this.AppContainer)

            % 注册关闭时的提示对话框
            this.AppContainer.CanCloseFcn = @(varargin) canClose(this, varargin{:});

            % 添加 Project 句柄对象的监听器
            kssolv.KSSOLVToolbox.createListener();
        end
        
        function delete(this)
            %DELETE 析构函数
            % 删除 App Container
            if ~isempty(this.AppContainer) && isvalid(this.AppContainer)
                delete(this.AppContainer);                        
            end
        end

        %% App 操作相关
        function appcontainer = getAppContainer(this)
            % 获取 App Container 实例
            appcontainer = this.AppContainer;
        end
        
        function show(this)
            % 绘制并展示 App 界面
            this.AppContainer.WindowBounds = [100 100 1200 800];
            this.AppContainer.HostInBrowser = this.HostInBrowser;
            this.AppContainer.Visible = true;
        end
        
        function close(this)
            % 关闭 App
            delete(this);
        end       
    end

    methods (Static)
        function createListener()
            % 添加 Project 句柄对象的监听器
            project = kssolv.ui.util.DataStorage.getData('Project');
            addlistener(project, 'isDirty', 'PostSet', @kssolv.KSSOLVToolbox.callbackProjectDirtyChanged);
        end

        function title = setAppContainerTitle(isDirty)
            % 按照特定格式设定 App Container 标题
            arguments
                isDirty logical = false
            end
            import kssolv.ui.util.Localizer.message
            import kssolv.ui.util.DataStorage.getData

            projectFilename = getData('ProjectFilename');
            if projectFilename == ""
                title = message('KSSOLV:toolbox:AppTitle');
            else
                title = strcat(message('KSSOLV:toolbox:AppTitle'), " - ", projectFilename);
            end
            if isDirty
                title = strcat(title, '*');
            end
            appContainer = getData('AppContainer');
            appContainer.Title = title;
        end
    end

    methods (Access = private, Static)
        function callbackProjectDirtyChanged(~, event)
            isDirty = event.AffectedObject.isDirty;
            kssolv.KSSOLVToolbox.setAppContainerTitle(isDirty);
        end
    end

    methods (Access = private)
        function setPanelLayout(this)
            % 调整 Data Browsers 的布局
            % 折叠了两个 Panel
            InfoBrowserPanel = this.AppContainer.getPanel('InfoBrowser');
            InfoBrowserPanel.Collapsed = true;
            RunBrowserPanel = this.AppContainer.getPanel('RunBrowser');
            RunBrowserPanel.Collapsed = true;
            % 折叠了右侧的面板
            this.AppContainer.RightCollapsed = true;
        end

        function status = canClose(this, ~)
            arguments (Output)
                status logical
            end
            import kssolv.ui.util.Localizer.*

            status = false;
            project = kssolv.ui.util.DataStorage.getData('Project');
            projectFilename = kssolv.ui.util.DataStorage.getData('ProjectFilename');

            if ~project.isDirty
                % 如果 project 没有进行任何修改，则直接关闭已有的 project
                % 此处不需要进行额外的处理
            else
                % 如果 project 有进行修改，则弹出对话框，包含"保存"、"不保存"和"取消"按钮
                YesLabel = message('KSSOLV:dialogs:AppCanCloseSave');
                NoLabel = message('KSSOLV:dialogs:AppCanCloseDoNotSave');
                CancelLabel = message('KSSOLV:dialogs:AppCanCloseCancel');
                selection = uiconfirm(this.AppContainer, ...
                    message('KSSOLV:dialogs:AppCanCloseMessage'), ...
                    message('KSSOLV:dialogs:AppCanCloseTitle'), ...
                    'Options', {YesLabel, NoLabel, CancelLabel}, ...
                    'DefaultOption', 1, ...
                    'CancelOption', 3);
                switch selection
                    case YesLabel
                        if projectFilename == ""
                            % 如果尚未指定要保存的文件，则选择保存为 .ks 文件的路径
                            [file,location] = uiputfile({'*.ks', 'KSSOLV Files (*.ks)'}, ...
                                message('KSSOLV:dialogs:SaveKSFileTitle'), 'untitled.ks');
                            if isequal(file, 0) || isequal(location, 0)
                                % 用户点击了"取消"按钮
                                return
                            else
                                % 用户选择了具体的文件路径，保存 project
                                project.saveToKsFile(fullfile(location, file));
                            end
                        else
                            % 如果已打开 .ks 文件，则保存后关闭当前 project
                            project.saveToKsFile(projectFilename);
                        end
                    case NoLabel
                        % 此处无需进行处理
                    case CancelLabel
                        return
                end
            end
            status = true;
        end

        %% 回调函数
        function callbackAppStateChanged(this)
            % 当 AppContainer 状态改变时，执行相关的操作
            import matlab.ui.container.internal.appcontainer.*
            switch this.AppContainer.State
                case AppState.RUNNING
                    % 在 App 打开后进行一些操作，如折叠右侧面板
                    this.AppContainer.RightCollapsed = true;
                case AppState.TERMINATED
                    % 清除本地化管理器的类的实例
                    kssolv.ui.util.Localizer.clearInstance();
                    % 清除 App Container 相关的实例
                    delete(this);
            end
        end
    end
end

