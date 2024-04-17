classdef DataPlot < handle
    %DATAPLOT 展示数据绘图结果
    
    %   开发者：杨柳
    %   版权 2024 合肥瀚海量子科技有限公司
    
    properties
        DocumentGroupTag
        figureFilePath string
    end
    
    methods
        function this = DataPlot(figureFilePath)
            %DATAPLOT 构造函数
            arguments
                figureFilePath string
            end
            this.figureFilePath = figureFilePath;
            this.DocumentGroupTag = 'DocumentGroup';
        end
        
        function Display(this)
            %DISPLAY 在 Document Group 中展示图像
            if this.figureFilePath == ""
                return
            end
            figOptions.Title = '数据绘图'; 
            figOptions.DocumentGroupTag = this.DocumentGroupTag; 
            document = matlab.ui.internal.FigureDocument(figOptions);

            % 创建 uigrid
            fig = document.Figure; 
            g = uigridlayout(fig);
            g.RowHeight = {'1x'};
            g.ColumnWidth = {'1x'};

            % 获取图片文件扩展名，并分别进行渲染
            [~, ~, ext] = fileparts(this.figureFilePath);
            switch ext
                case '.fig'
                    fig = openfig(this.figureFilePath, 'invisible');
                    ax = findobj(fig, 'Type', 'Axes');
                    ax.Parent = g;
                    delete(fig);
                otherwise
                    image = uiimage(g);
                    image.ImageSource = this.figureFilePath;
            end

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
            this.figureFilePath = fullfile(fileparts(mfilename('fullpath')), ...
                'test', 'gtk.fig');
            this.Display();
        end
    end
end

