classdef KSSOLVToolbox < handle
    %KSSOLVTOOLBOX 排列和布局相关 UI 组件，生成 KSSOLV Toolbox 的完整用户图形界面
    
    %   开发者：杨柳
    %   版权 2024 合肥瀚海量子科技有限公司
    
    properties (Access = public)
        % Name
        Name
        % App Container
        AppContainer
    end
    
    methods
        function this = KSSOLVToolbox()
            %KSSOLVTOOLBOX 构造此类的实例
            import kssolv.ui.util.Localizer.*
            setLocale('zh_CN');
            % App 标题
            title = message('KSSOLV:toolbox:AppTitle');
            % 创建 App Container
            appOptions.Title = title;
            appOptions.Tag = sprintf('kssolv(%s)', char(matlab.lang.internal.uuid));
            appOptions.ToolstripEnabled = true;
            appOptions.EnableTheming = true;
            this.AppContainer = matlab.ui.container.internal.AppContainer(appOptions);
            this.Name = this.AppContainer.Tag;
            % 保存 AppContainer 至 DataStorage
            kssolv.ui.util.DataStorage.setData('AppContainer', this.AppContainer);
            % 添加工作区文字
            msg = message('KSSOLV:toolbox:WelcomeMessage');
            this.AppContainer.DocumentPlaceHolderText = msg;
            % 监听 App Container 的状态改变，例如关闭 App 时会触发 StateChanged 事件
            addlistener(this.AppContainer, 'StateChanged', @(src,data) callbackAppStateChanged(this));
            % 添加 Document Group
            group = matlab.ui.internal.FigureDocumentGroup();
            group.Tag = 'DocumentGroup';
            group.Title = 'DocumentGroup';
            group.DefaultRegion = 'left';
            this.AppContainer.add(group);
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

            % 展示布局好的界面
            show(this);

            % 注册关闭时的提示对话框
            this.AppContainer.CanCloseFcn = @(varargin) canClose(this,varargin{:});
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
            this.AppContainer.Visible = true;
        end
        
        function close(this)
            % 关闭 App
            delete(this);
        end       
    end

    methods (Access = private)
        function setPanelLayout(this)
            % 调整 Data Browsers 的布局
            % 这里折叠了两个 Panel
            InfoBrowserPanel = this.AppContainer.getPanel('InfoBrowser');
            InfoBrowserPanel.Collapsed = true;
            RunBrowserPanel = this.AppContainer.getPanel('RunBrowser');
            RunBrowserPanel.Collapsed = true;
        end

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

        function status = canClose(this, ~)
            status = false;

            import kssolv.ui.util.Localizer.*
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
                    status = true;
                case NoLabel
                    status = true;
                otherwise
            end
        end
    end
end

