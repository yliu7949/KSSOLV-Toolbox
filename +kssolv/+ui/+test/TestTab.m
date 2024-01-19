classdef TestTab < handle
    %TESTTAB Toolstrip 菜单栏中的测试标签页
    %   参考代码：
    %       C:\Program Files\MATLAB\R2023b\toolbox\matlab\toolstrip\+matlab\+ui\+internal\+toolstrip\ListItem.m
    %       C:\Program Files\MATLAB\R2023b\toolbox\matlab\toolstrip\+matlab\+ui\+internal\+toolstrip\PopupList.m
    %
    %   开发者：高俊
    %   版权 2024 合肥瀚海量子科技有限公司
    
    properties
        % Test 标签页
        Tab
        % 标签
        Tag
        % 标题 
        Title
        % toolstrip controls
        Widgets 
    end
    
    methods
        function this = TestTab()
            %TESTTAB 构造函数，初始设置相关参数
            import kssolv.ui.util.Localizer.message
            this.Title = '测试主页';
            this.Tag = 'TestTab';
            buildTab(this);
        end
        
        function buildTab(this)
            %BUILDTAB 创建 TestTab 对象
            this.Tab = matlab.ui.internal.toolstrip.Tab(this.Title);
            this.Tab.Tag = this.Tag;
            % 分别创建各个 Section 并添加到 TestTab 中
            createTestSection(this);
        end

        function createTestSection(this) 
            %CREATETESTSECTION 创建"测试"小节，并添加到 TestTab 中
            import matlab.ui.internal.toolstrip.*
            import kssolv.ui.util.Localizer.message
            import kssolv.ui.util.CreatButton
            % 创建 Test Section
            section = Section(message("KSSOLV:toolbox:ProjectSectionTitle"));
            section.Tag = 'ProjectSection';
            % 创建 Column
            column1 = Column();
            column2 = Column();
            column3 = Column();
            % 测试不同种类的 Button
            ProjectOpenButton = CreatButton('push', 'ProjectOpen', section.Tag, Icon.OPEN_24);
            ProjectModelButton = CreatButton('dropdown', 'ProjectModel', section.Tag, Icon.IMPORT_24);
            ProjectSaveButton = CreatButton('split', 'ProjectSave', section.Tag, Icon.SAVE_24);
            % 创建 ListItem 实例化对象
            % 创建 item1
            label1 = 'test111111111111111';
            icon1 = Icon.CLOSE_24;
            desc1 = '111111111111111111111';
            tag1 = 'tag111111111';
            item1 = ListItem(label1, icon1);
            item1.Tag = tag1;
            item1.Description = desc1;
            % 创建 item2
            label2 = 'test2';
            icon2 = Icon.CLOSE_24;
            desc2 = '2222222222';
            tag2 = 'tag22222222222';
            item2 = ListItemWithPopup(label2, icon2);
            item2.Tag = tag2;
            item2.Description = desc2;
            % 创建 item3
            text = 'test3';
            desc = '333333333333';
            selected = false;
            item3 = ListItemWithCheckBox(text, desc, selected);
            % 创建 item4
            lbl = '4444444444444';
            value = '10';
            placeholder = 'Enter an integer here';
            item4 = matlab.ui.internal.toolstrip.ListItemWithEditField(lbl, value, placeholder);
            % 创建 item5
            group = matlab.ui.internal.toolstrip.ButtonGroup;
            item5 = matlab.ui.internal.toolstrip.ListItemWithRadioButton(group, 'blue');
            % 创建 item6
            text = 'test6';
            desc = '6666666666';
            selected = false;
            item6 = ListItemWithCheckBox(text, desc, selected);
            % 创建 ListItemWithPopup 下的 subpopup
            sub_popup = matlab.ui.internal.toolstrip.PopupList();
            sub_popup.add(item3);
            sub_popup.add(item4);
            % 创建 popup
            % Button -> PopupList -> ListItem/ListItemWithPopup
            popup = PopupList();
            popup.Tag = 'popup';
            popup.add(item1);
            header = PopupListHeader('分隔栏');
            popup.add(header);
            item2.Popup = sub_popup;
            panel = PopupListPanel('MaxHeight', 100);
            panel.add(item5);
            panel.add(item2);
            panel.add(item6);
            panel.addSeparator;
            popup.add(panel);
            ProjectSaveButton.Popup = popup;
            % 组装 Column 和 Button
            column1.add(ProjectOpenButton);
            column2.add(ProjectModelButton);
            column3.add(ProjectSaveButton);
            section.add(column1);
            section.add(column2);
            section.add(column3);
            this.Tab.add(section);
            % 保存到 Widgets
            this.Widgets.SessionSection =  struct('ProjectOpenButton',ProjectOpenButton,'ProjectModelButton',ProjectModelButton,'ProjectSaveButton',ProjectSaveButton);
        end
    end

    methods (Static, Hidden)
        function app = qeShow()
            % 用于在单元测试中测试 TestTab，可通过下面的命令使用：
            % kssolv.ui.test.TestTab.qeShow();

            % 创建 AppContainer          
            appOptions.Tag = sprintf('kssolv(%s)',char(matlab.lang.internal.uuid));
            appOptions.Title = kssolv.ui.util.Localizer.message('KSSOLV:toolbox:UnitTestTitle');
            appOptions.ToolstripEnabled = true;
            app = matlab.ui.container.internal.AppContainer(appOptions);

            % 添加 TestTab
            homeTab = kssolv.ui.test.TestTab();
            tabGroup = matlab.ui.internal.toolstrip.TabGroup();
            tabGroup.Tag = 'kssolvTabGroup';
            tabGroup.add(homeTab.Tab);
            app.add(tabGroup);

            % 展示界面
            app.Visible = true;
        end
    end

end

