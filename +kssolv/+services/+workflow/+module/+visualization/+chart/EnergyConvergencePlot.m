classdef EnergyConvergencePlot < matlab.graphics.chartcontainer.ChartContainer
    %ENERGYCONVERGENCEPLOT 用于绘制能量收敛曲线图和误差曲线的自定义图表类

    properties
        Energy % Etot 能量数据 (eV)
        Error % 误差数据
    end

    methods (Access = protected)
        function setup(~)
            % 保持为空，用于初始化设置
        end

        function update(this)
            ax = getAxes(this);
            hold(ax, 'on');
            cla(ax);

            % 生成迭代步数，假设与 Energy 数组长度相同
            iterations = 1:length(this.Energy);

            % 设置X轴
            xlabel(ax, 'Iterations');
            title(ax, 'Energy Convergence and Error');
            grid(ax, 'on');

            % 左Y轴：能量
            yyaxis(ax, 'left');
            ylabel(ax, 'Energy (eV)');
            plot(ax, iterations, this.Energy, '-o', 'LineWidth', 2, 'Color', 'b');  % 蓝色，线宽2，圆形标记

            % 右Y轴：误差
            yyaxis(ax, 'right');
            ylabel(ax, 'Error');
            plot(ax, iterations, this.Error, '--s', 'LineWidth', 2, 'Color', 'r');  % 红色，线宽2，方形标记

            % 添加图例
            legend(ax, {'Etot', 'Error'}, 'Location', 'best');
        end
    end
end
