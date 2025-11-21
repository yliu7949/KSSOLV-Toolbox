classdef BandStructure3DPlot < kssolv.services.workflow.module.visualization.chart.AbstractChartContainer
    %BANDSTRUCTURE3DPLOT 用于绘制能量收敛曲线图和误差曲线的自定义图表类

    %   开发者：杨柳
    %   版权 2025 合肥瀚海量子科技有限公司

    properties
        kPoints
        energyBands
        slicePlane
        bandIndex
    end

    properties (Access = private, Transient, NonCopyable)
        segmentedKPoints
    end

    methods (Access = protected)
        function update(this)
            % 当数据或属性发生变化时，用于更新图表的更新方法

            % 获取用于绘图的坐标轴
            ax = getAxes(this);
            hold(ax, 'on');

            switch this.slicePlane
                case 'XY'
                    X = this.kPoints(:, 1);
                    Y = this.kPoints(:, 2);
                    this.plotEnergybands(X, Y);
                case 'XZ'
                    X = this.kPoints(:, 1);
                    Z = this.kPoints(:, 3);
                    this.plotEnergybands(X, Z);
                case 'YZ'
                    Y = this.kPoints(:, 2);
                    Z = this.kPoints(:, 3);
                    this.plotEnergybands(Y, Z);
            end

            view(ax, 75, 5);
            set(ax, 'XTick', [], 'YTick', [], 'ZTick', [], 'Box', 'on', ...
                'BoxStyle', 'full', 'Colormap', turbo, 'Color', 'none', 'LineWidth', 1.3);

            % 避免覆盖图表
            hold(ax, 'off');

            % 保存 Axes
            this.axes = ax;
        end
    end

    methods (Access = private)
        function plotEnergybands(this, X, Y)
            ax = this.getAxes();
            [XGrid, YGrid] = meshgrid(linspace(min(X(:)), max(X(:)), 100), ...
                linspace(min(Y(:)), max(Y(:)), 100));

            for i = 1:length(this.bandIndex)
                energy = this.energyBands(this.bandIndex(i), :, :)';
                Z = griddata(X(:), Y(:), energy, XGrid, YGrid, 'cubic');
                surf(ax, XGrid, YGrid, Z, 'FaceAlpha', 0.75, 'EdgeColor', 'none');
            end
        end
    end
end
