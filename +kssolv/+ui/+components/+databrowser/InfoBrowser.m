classdef InfoBrowser < matlab.ui.internal.databrowser.AbstractDataBrowser
    %INFOBROWSER 自定义的 Data Browser 组件，显示 Project Browser 里对应项的具体信息
    %   开发者：杨柳 张致远
    %   版权 2024 合肥瀚海量子科技有限公司
    
    properties
        Property1
    end
    
    methods
        function this = InfoBrowser()
            %INFOBROWSER 构造此类的实例
            title = kssolv.ui.util.Localizer.message('KSSOLV:toolbox:InfoBrowserTitle');
            % 调用超类构造函数
            this = this@matlab.ui.internal.databrowser.AbstractDataBrowser('InfoBrowser', title);          
            % 自定义 widget 和 layout
            buildUI(this);
            % 设定 FigurePanel 的 Tag
            this.Panel.Tag = 'InfoBrowser';
        end
    end

    methods (Access = protected)
        function buildUI(this)
            fig = this.Figure;
            g = uigridlayout(fig);
            g.RowHeight = {'1x'};
            g.ColumnWidth = {'1x'};
            table = uitable(g, "Data", randi(100, 10, 3));

            % 警告符号
            warningRows = find(table.Data(:, 2) > 30);
            warningColunms = repmat(2, size(warningRows));
            cells = [warningRows warningColunms];
            Icon = uistyle("Icon", "warning", "IconAlignment", "right");
            addStyle(table, Icon, "cell" ,cells);

            % 表格点击行为
            table.CellSelectionCallback = @cellSelectCallback;
            function cellSelectCallback(src, event)
                % 获得表格大小
                [numRows, numCols] = size(src.Data);
                
                % 颜色设置
                % 默认
                style0 = uistyle("BackgroundColor", [1, 1, 1]);
                % 选中
                style1 = uistyle("BackgroundColor", [0.1, 0.1, 0.1]);
                % 同行
                style2 = uistyle("BackgroundColor", [0.8, 0.8, 0.8]);

                % 判断选中
                if ~isempty(event.Indices)
                    % 得到选中单元格
                    rows = event.Indices(:, 1);
                    cols = event.Indices(:, 2);

                    % 获取单元格数量
                    num = size(rows, 1);

                    % 颜色赋值
                    for i = 1:numRows
                        for j = 1:numCols
                            addStyle(src, style0, "cell", [i j]);
                        end
                    end
                    
                    for i = 1:num
                        if i > 1
                            if rows(i) == rows(i-1)
                                addStyle(src, style1, "cell", [rows(i) cols(i)]);
                            else
                                for j = 1:numCols
                                    addStyle(src, style2, "cell", [rows(i) j]);
                                end
                                addStyle(src, style1, "cell", [rows(i) cols(i)]);
                            end
                        else
                            for j = 1:numCols
                                addStyle(src, style2, "cell", [rows(i) j]);
                            end
                            addStyle(src, style1, "cell", [rows(i) cols(i)]);
                        end
                    end
                end
            end

            % 折叠按钮
            tablePosition = table.Position;
            buttonX = tablePosition(1);
            buttonY = tablePosition(2) + tablePosition(4); 
            buttonWidth = 100;
            buttonHeight = 20;
            uibutton(fig, 'Text', 'Toggle Table', 'Position', [buttonX, buttonY-50, buttonWidth, buttonHeight], 'ButtonPushedFcn', @(btn,event) toggleTableVisibility(table));
            function toggleTableVisibility(table)
                % 切换表格的可见性
                if strcmp(table.Visible, 'on')
                    table.Visible = 'off';
                else
                    table.Visible = 'on';
                end
            end
        end
    end

    methods (Hidden)
        function app = qeShow(this)
            % 用于在单元测试中测试 InfoBrowser，可通过下面的命令使用：
            % b = kssolv.ui.components.databrowser.InfoBrowser();
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

