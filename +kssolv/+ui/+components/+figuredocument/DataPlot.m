classdef DataPlot < handle
    %DATAPLOT 展示数据绘图结果
    
    %   开发者：杨柳
    %   版权 2024 合肥瀚海量子科技有限公司
    
    properties
        DocumentGroupTag
        figFilePath
    end
    
    methods
        function this = DataPlot(figFilePath)
            %DATAPLOT 构造函数
            arguments
                figFilePath string = '/Users/liu/Documents/kssolv-gui/Temp/gtk.png'
            end
            this.figFilePath = figFilePath;
            this.DocumentGroupTag = 'DocumentGroup';
        end
        
        function Display(this)
            %DISPLAY 在 Document Group 中展示 fig 图像
            figOptions.Title = '数据绘图'; 
            figOptions.DocumentGroupTag = this.DocumentGroupTag; 
            document = matlab.ui.internal.FigureDocument(figOptions);

            % 添加 html 组件
            fig = document.Figure;
            
            g = uigridlayout(fig);
            g.RowHeight = {'1x'};
            g.ColumnWidth = {'1x'};
            %{
            uiax = uiaxes(g);
            fig = openfig(this.figFilePath, 'invisible');
            ax = findobj(fig, 'Type', 'Axes');
            copyobj(ax.Children, uiax);
            delete(fig);
            %}
            image = uiimage(g);
            image.ImageSource = this.figFilePath;

            % 添加到 App Container
            appContainer = kssolv.ui.util.DataStorage.getData('AppContainer');
            appContainer.add(document);
        end
    end

    methods (Hidden)
        function app = qeShow(this)
            % 用于在单元测试中测试 DataPlot，可通过下面的命令使用：
            % d = kssolv.ui.components.figuredocument.DataPlot();
            % d.qeShow()

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

            % 展示 MolecularDisplay
            this.DocumentGroupTag = 'DocumentGroupTest';
            %this.figFilePath = '/Users/liu/Documents/kssolv-gui/Temp/gtk.png';
            this.Display();
        end
    end
end

