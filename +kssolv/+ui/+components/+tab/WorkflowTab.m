classdef WorkflowTab < handle
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
        function this = WorkflowTab()
            %HOMETAB 构造函数，初始设置相关参数
            import kssolv.ui.util.Localizer.message
            this.Title = message("KSSOLV:toolbox:WorkflowTabTitle");
            this.Tag = 'WorkflowTab';
            buildTab(this);
        end
        
        function buildTab(this)
            %CONSTRUCTTAB 创建 Home Tab 对象
            this.Tab = matlab.ui.internal.toolstrip.Tab(this.Title);
            this.Tab.Tag = this.Tag;
            % 分别创建各个 Section 并添加到 Home Tab 中
            test(this);
        end

        function test(this) 
            import matlab.ui.internal.toolstrip.*
            import kssolv.ui.util.Localizer.message
            import kssolv.ui.util.CreatButton
            % 创建 Project Section
            section = Section('绘图');
            section.Tag = '111';
   
            % 组装 Column 和 Button
            
            item1 = GalleryItem('Import',Icon.IMPORT_24);
            item2 = GalleryItem('Export',Icon.EXPORT_24);
            item3 = GalleryItem('Print',Icon.PRINT_24);
            item4 = GalleryItem('Help',Icon.HELP_24);
            
            category1 = GalleryCategory('My Category 1');
            category1.add(item1);
            category1.add(item2);
            
            category2 = GalleryCategory('My Category 2');
            category2.add(item3);
            category2.add(item4);
            
            popup = GalleryPopup();
            popup.add(category1);
            popup.add(category2);
            
            gallery = Gallery(popup);


            column1 = Column();
            column1.add(gallery);
            section.add(column1);
            this.Tab.add(section);

        end

    end
end

