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
            import kssolv.ui.util.Localizer.message
            % App 标题
            title = message('KSSOLV:toolbox:AppTitle');
            % 创建 App Container
            appOptions.Title = title;
            appOptions.Tag = sprintf('kssolv(%s)', char(matlab.lang.internal.uuid));
            appOptions.ToolstripEnabled = true;
            appOptions.EnableTheming = true;
            this.AppContainer = matlab.ui.container.internal.AppContainer(appOptions);            
            this.Name = this.AppContainer.Tag;
            % 添加工作区文字
            msg = message('KSSOLV:toolbox:WelcomeMessage');
            this.AppContainer.DocumentPlaceHolderText = msg;
            % 监听 App Container 的状态改变，例如关闭 App 时会触发 StateChanged 事件
            addlistener(this.AppContainer, 'StateChanged', @(src,data) callbackAppStateChanged(this));
            % add two document groups
            group = matlab.ui.internal.FigureDocumentGroup();
            group.Tag = 'InputPlot';
            group.Title = 'Input Plots';
            group.DefaultRegion = 'left';
            this.AppContainer.add(group);
            group = matlab.ui.internal.FigureDocumentGroup();
            group.Tag = 'OutputPlot';
            group.Title = 'Output Plots';
            group.DefaultRegion = 'right';
            this.AppContainer.add(group);
            % 添加 Tabs 组件
            homeTab = kssolv.ui.components.tab.HomeTab();
            tabGroup = matlab.ui.internal.toolstrip.TabGroup();
            tabGroup.Tag = 'kssolvTabGroup';
            tabGroup.add(homeTab.Tab);
            this.AppContainer.add(tabGroup);
            % 展示布局好的界面
            show(this);
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
        function callbackAppStateChanged(this)
            % 当 AppContainer 被关闭时，删除类的实例
            import matlab.ui.container.internal.appcontainer.*;
            if this.AppContainer.State == AppState.TERMINATED
                delete(this);
            end
        end
    end
end

