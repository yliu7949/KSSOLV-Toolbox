classdef HomeTab < handle
    %HOMETAB Toolstrip 菜单栏中的 Home 标签页
    %   开发者：杨柳
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
        end

        function createProjectSection(this)
            %CREATEPROJECTSECTION 创建"项目"小节，并添加到 HomeTab 中
            import matlab.ui.internal.toolstrip.*
            % 创建 Project Section
            section = Section('Project');
            section.Tag = 'ProjectSection';
            % 创建 Column
            column1 = Column();
            column2 = Column();
            % 创建 Button
            text = 'Open';
            icon = Icon.OPEN_24;
            button1 = Button(text, icon);
            button2 = Button('Test', Icon.NEW_24);
            button2.ButtonPushedFcn = @this.moleculerDisplay;
            % 组装 Column 和 Button
            column1.add(button1);
            column2.add(button2);
            section.add(column1);
            section.add(column2);
            this.Tab.add(section);
        end

        function moleculerDisplay(~, ~, ~)
            kssolv.ui.components.figuredocument.MoleculerDisplay().Display();
        end

    end
end

