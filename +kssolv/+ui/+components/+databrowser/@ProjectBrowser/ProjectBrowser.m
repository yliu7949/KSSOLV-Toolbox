classdef ProjectBrowser < matlab.ui.internal.databrowser.AbstractDataBrowser
    %PROJECTBROWSER 自定义的 Data Browser 组件，存放 ks 项目文件的 TreeTable 视图
    
    %   开发者：杨柳
    %   版权 2024 合肥瀚海量子科技有限公司

    properties
        Widgets
    end

    properties (SetObservable, AbortSet)
        currentSelectedItem   % 当前选中的节点
    end
    
    methods
        function this = ProjectBrowser()
            %PROJECTBROWSER 构造此类的实例
            title = kssolv.ui.util.Localizer.message('KSSOLV:toolbox:ProjectBrowserTitle');
            % 调用超类构造函数
            this = this@matlab.ui.internal.databrowser.AbstractDataBrowser('ProjectBrowser', title);          
            % 自定义 widget 和 layout
            buildUI(this);
            % 设定 FigurePanel 的 Tag
            this.Panel.Tag = 'ProjectBrowser';
            % 保存至 DataStorage
            kssolv.ui.util.DataStorage.setData('ProjectBrowser', this);
        end
        
        function updateTreetable(this, action, itemName, itemJSON)
            arguments
                this 
                action {mustBeMember(action, {'ADD', 'PATCH', 'DELETE'})}
                itemName {mustBeNonempty}
                itemJSON string = ''
            end
            eventName = strcat(lower(action), 'Item');
            eventData = struct('itemName', itemName, 'itemJSON', itemJSON);
            this.Widgets.html.sendEventToHTMLSource(eventName, ...
                jsonencode(eventData, "PrettyPrint", true));
        end
    end

    methods (Access = protected)
        function buildUI(this)
            fig = this.Figure;
            g = uigridlayout(fig);
            g.BackgroundColor = "white";
            g.Padding = [0 0 0 0];
            g.RowHeight = {'1x'};
            g.ColumnWidth = {'1x'};
            
            htmlFile = fullfile(fileparts(mfilename('fullpath')), 'TreeTable', 'TreeTable.html');
            h = uihtml(g, "HTMLSource", htmlFile);
            this.Widgets.html = h;

            % 将当前加载的 project 文件编码为 JSON，发送给 HTML 组件
            project = kssolv.ui.util.DataStorage.getData('Project');
            h.Data = project.encodeToJSON();

            % 接收从 HTML 组件触发的事件
            h.HTMLEventReceivedFcn = @this.eventReceiver;
        end
    end

    methods (Access = private)
        function eventReceiver(this, src, event)
            switch event.HTMLEventName
                case 'RowClicked'
                    this.callbackRowClicked(src, event);
                case 'RowDoubleClicked'
                    this.callbackRowDoubleClicked(src, event);
                case 'RowRemoved'
                    this.callbackRowRemoved(src, event);
            end
        end

        function callbackRowClicked(this, ~, event)
            this.currentSelectedItem = event.HTMLEventData;
        end

        function callbackRowDoubleClicked(this, ~, event)
            this.currentSelectedItem = event.HTMLEventData;
            
            project = kssolv.ui.util.DataStorage.getData('Project');
            item = project.findChildrenItem(this.currentSelectedItem);
            switch class(item)
                case 'kssolv.services.filemanager.Structure'
                    if startsWith(item.parent.name, 'Project')
                        % 打开导入结构文件对话框，导入和解析结构文件，并显示渲染的结构
                        importedFileCount = item.importStructureFromFile();
                        if importedFileCount > 0
                            startIndex = numel(item.children) - importedFileCount + 1;
                            for index = startIndex : numel(item.children)
                                % 更新 TreeTable
                                this.updateTreetable('ADD', item.name, item.children{index}.encodeToJSON(1));
                            end
                            this.updateTreetable('PATCH', item.name, item.encodeToJSON(1));
                        end
                    else
                        % 直接显示渲染的结构
                        item.showMoleculerDisplay();
                    end
                case 'kssolv.services.filemanager.Workflow'
                    if startsWith(item.parent.name, 'Project')
                        % 新增 workflow 项，并打开相应的 document
                        item.createWorkflowItem();
                        % 更新 TreeTable
                        this.updateTreetable('ADD', item.name, item.children{end}.encodeToJSON(1));
                        this.updateTreetable('PATCH', item.name, item.encodeToJSON(1));
                    else
                        % 直接显示工作流画布
                        item.showWorkflowDisplay();
                    end
            end
        end
    
        function callbackRowRemoved(this, ~, event)
            removedItemName = event.HTMLEventData;
            project = kssolv.ui.util.DataStorage.getData('Project');
            parentItem = project.findChildrenItem(removedItemName).parent;
            parentItem.removeChildrenItem(removedItemName);
            this.updateTreetable('PATCH', parentItem.name, parentItem.encodeToJSON(1));
        end
    end

    methods (Hidden)
        function app = qeShow(this)
            % 用于在单元测试中测试 ProjectBrowser，可通过下面的命令使用：
            % b = kssolv.ui.components.databrowser.ProjectBrowser();
            % b.qeShow()

            % 创建 AppContainer          
            appOptions.Tag = sprintf('kssolv(%s)',char(matlab.lang.internal.uuid));
            appOptions.Title = kssolv.ui.util.Localizer.message('KSSOLV:toolbox:UnitTestTitle');
            appOptions.ToolstripEnabled = true;
            app = matlab.ui.container.internal.AppContainer(appOptions);

            % 将 Browser 添加到 App Container
            this.addToAppContainer(app);
            % 展示界面
            app.Visible = true;
        end
    end
end

