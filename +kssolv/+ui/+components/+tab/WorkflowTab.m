classdef WorkflowTab < handle
    %WORKFLOWTAB Toolstrip 菜单栏中的 Workflow 标签页
    %   开发者：杨柳、高俊
    %   版权 2024 合肥瀚海量子科技有限公司
    
    properties
        % Workflow 标签页
        Tab
        % 标签
        Tag
        % 标题
        Title
    end
    
    methods
        function this = WorkflowTab()
            %WORKFLOWTAB 构造函数，初始设置相关参数
            import kssolv.ui.util.Localizer.message
            this.Title = message("KSSOLV:toolbox:WorkflowTabTitle");
            this.Tag = 'WorkflowTab';
            buildTab(this);
        end
        
        function buildTab(this)
            %BUILDTAB 创建 Home Tab 对象
            this.Tab = matlab.ui.internal.toolstrip.Tab(this.Title);
            this.Tab.Tag = this.Tag;
            % 分别创建各个 Section 并添加到 Home Tab 中
            createPlotSection(this);
        end

        function createPlotSection(this)
            %CREATEPLOTSECTION 创建"绘图"小节，并添加到 WorkflowTab 中
            import matlab.ui.internal.toolstrip.*
            import kssolv.ui.util.Localizer.message
            import kssolv.ui.util.CreatButton
            % 创建 Project Section
            section = Section(message("KSSOLV:toolbox:PlotSectionTitle"));
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
        end
    end

    methods (Static, Hidden)
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

