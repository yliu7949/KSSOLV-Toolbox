classdef (Abstract) AbstractChartContainer < matlab.graphics.chartcontainer.ChartContainer
    %ABSTRACTCHARTCONTAINER 抽象的自定义 ChartContainer 类

    %   开发者：杨柳
    %   版权 2025 合肥瀚海量子科技有限公司

    properties (Access = protected)
        axes
    end

    methods
        function axes = getAxesObject(this)
            axes = this.axes;
        end
    end

    methods (Access = protected)
        function setup(this)
            % 用于初始化设置
            if isempty(this.Parent)
                return;
            end
            this.Parent.Visible = 'off';
        end
    end

    methods
        function replot(this)
            % 清除 Axes 对象，重新绘图
            ax = getAxes(this);
            cla(ax);
            update(this);
        end
    end
end