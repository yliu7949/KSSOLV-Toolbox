classdef Workflow < handle
    %WORKFLOW 工作流组件
    
    %   开发者：杨柳
    %   版权 2024 合肥瀚海量子科技有限公司
    
    properties
        DocumentGroupTag
        graphJSON string
        tag string
    end
    
    methods
        function this = Workflow(graphJSON, tag)
            %WORKFLOW 构造此类的实例
            arguments
                graphJSON string = ""
                tag string = ""
            end
            this.graphJSON = graphJSON;
            this.tag = tag;
            this.DocumentGroupTag = 'Workflow';

            appContainer = kssolv.ui.util.DataStorage.getData('AppContainer');
            group = appContainer.getDocumentGroup(this.DocumentGroupTag);
            if isempty(group)
                % 若 appContainer 没有 Tag 为 'Workflow' 的 DocumentGroup，
                % 则创建 DocumentGroup 并添加到 appContainer 中
                group = matlab.ui.internal.FigureDocumentGroup();
                group.Tag = this.DocumentGroupTag;
                group.Title = this.DocumentGroupTag;
                group.DefaultRegion = 'left';
                appContainer.add(group);
            end
        end
    end

    methods
        function Display(this)
            %DISPLAY 在 Document Group 中展示工作流画布
            appContainer = kssolv.ui.util.DataStorage.getData('AppContainer');
            document = appContainer.getDocument(this.DocumentGroupTag, this.tag);
            if ~isempty(document)
                % 如果具有相同 tag 的 document 存在，则选中它
                document.Selected = true;
                return
            end

            figOptions.Title = kssolv.ui.util.Localizer.message('KSSOLV:toolbox:DocumentWorkflowTitle'); 
            figOptions.DocumentGroupTag = this.DocumentGroupTag;
            if this.tag ~= ""
                figOptions.Tag = this.tag;
            end
            document = matlab.ui.internal.FigureDocument(figOptions);

            % 添加 html 组件
            fig = document.Figure;
            g = uigridlayout(fig);
            g.RowHeight = {'1x'};
            g.ColumnWidth = {'1x'};
            htmlFile = fullfile(fileparts(mfilename('fullpath')), 'workflow', 'index.html');
            h = uihtml(g, "HTMLSource", htmlFile);

            % 将画布数据保存在 html 组件中
            h.Data = this.graphJSON;

            % 接收从 HTML 组件触发的事件
            h.HTMLEventReceivedFcn = @this.eventReceiver;

            % 添加到 App Container
            appContainer.add(document);
        end
    end

    methods (Access = private)
        function eventReceiver(this, src, event)
            switch event.HTMLEventName
                case 'OpenSettingsWindow'
                    disp(event.HTMLEventName);
                case 'GraphExportToJSON'
                    this.callbackGraphExportToJSON(src, event);
            end
        end

        function callbackGraphExportToJSON(this, ~, event)
            this.graphJSON = event.HTMLEventData;

            project = kssolv.ui.util.DataStorage.getData('Project');
            item = project.findChildrenItem(this.tag);
            if ~isempty(item)
                item.graphJSON = this.graphJSON;
                item.updatedAt = datetime;
                project.isDirty = true;
                % 更新 Info Browser 的界面
                kssolv.ui.util.DataStorage.getData('ProjectBrowser').resetSelectedItem();
            end
        end
    end

    methods (Hidden)
        function app = qeShow(this)
            % 用于在单元测试中测试 Workflow，可通过下面的命令使用：
            % w = kssolv.ui.components.figuredocument.Workflow();
            % w.qeShow()

            % 创建 App Container          
            appOptions.Tag = sprintf('kssolv(%s)',char(matlab.lang.internal.uuid));
            appOptions.Title = kssolv.ui.util.Localizer.message('KSSOLV:toolbox:UnitTestTitle');
            appOptions.ToolstripEnabled = true;
            app = matlab.ui.container.internal.AppContainer(appOptions);

            % 保存 app 至 DataStorage
            import kssolv.ui.util.DataStorage.*
            setData('AppContainer', app);

            % 添加 Document Group
            group = matlab.ui.internal.FigureDocumentGroup();
            group.Tag = 'DocumentGroupTest';
            group.Title = 'DocumentGroupTest';
            group.DefaultRegion = 'left';
            app.add(group);
            
            % 展示界面
            app.Visible = true;

            % 展示 Workflow 画布
            this.DocumentGroupTag = 'DocumentGroupTest';
            this.Display();
        end
    end
end

