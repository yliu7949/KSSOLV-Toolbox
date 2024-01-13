classdef MoleculerDisplay < handle
    %MOLECULERDISPLAY 三维渲染分子结构和晶体结构的组件
    %   开发者：杨柳
    %   版权 2024 合肥瀚海量子科技有限公司
    
    properties
        DocumentGroupTag
    end
    
    methods
        function this = MoleculerDisplay()
            %MOLECULERDISPLAY 构造此类的实例
            this.DocumentGroupTag = 'DocumentGroup';
        end
        
        function Display(this)
            %DISPLAY 在 Document Group 中展示渲染的分子/晶体结构
            figOptions.Title = '结构'; 
            figOptions.DocumentGroupTag = this.DocumentGroupTag; 
            document = matlab.ui.internal.FigureDocument(figOptions);
            appContainer = kssolv.ui.util.DataStorage.getData('AppContainer');
            appContainer.add(document);
        end
    end

    methods (Hidden)
        function app = qeShow(this)
            % 用于在单元测试中测试 MolecularDisplay，可通过下面的命令使用：
            % m = kssolv.ui.components.figuredocument.MoleculerDisplay();
            % m.qeShow()

            % 创建 AppContainer          
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
            % 展示 MolecularDisplay
            this.DocumentGroupTag = 'DocumentGroupTest';
            this.Display();
        end
    end
end

