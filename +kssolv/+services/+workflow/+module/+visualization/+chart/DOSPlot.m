classdef DOSPlot < kssolv.services.workflow.module.visualization.chart.AbstractChartContainer
    %DOSPLOT 用于绘制态密度的自定义图表类

    %   开发者：杨柳
    %   版权 2025 合肥瀚海量子科技有限公司

    properties
        dos
        energyRange
    end

    properties (Dependent)
        % 设置 Y 轴范围
        YLimits (1, 2) double

        % 设置 Y 轴范围模式：'auto' 或 'manual'
        YLimitsMode {mustBeMember(YLimitsMode, {'auto', 'manual'})}
    end

    methods (Access = protected)
        function update(this)
            % 用于在数据或属性变化时更新图表的方法

            % 获取 axes 对象
            ax = getAxes(this);

            % 绘图并设置样式和标签
            plot(ax, this.dos, this.energyRange);
            grid(ax, 'on');
            xlabel(ax, 'Density of States (DOS)');
            ylabel(ax, 'Energy (eV)');
            title(ax, 'Density of States (DOS)');

            % 保存 Axes
            this.axes = ax;
        end
    end

    methods
        %% ylim 相关方法
        function varargout = ylim(this, varargin)
            %YLIM 设置绘图的 Y 轴范围
            ax = getAxes(this);
            [varargout{1:nargout}] = ylim(ax, varargin{:});
        end

        %% YLimits 和 YLimitsMode 的 set 和 get 方法
        function set.YLimits(this, ylm)
            % YLimits 的 Setter 方法
            ax = getAxes(this);
            ax.YLim = ylm;
        end

        function ylm = get.YLimits(this)
            % YLimits 的 Getter 方法
            ax = getAxes(this);
            ylm = ax.YLim;
        end

        function set.YLimitsMode(this, ylmmode)
            % YLimitsMode 的 Setter 方法
            ax = getAxes(this);
            ax.YLimMode = ylmmode;
        end

        function ylm = get.YLimitsMode(this)
            % YLimitsMode 的 Getter 方法
            ax = getAxes(this);
            ylm = ax.YLimMode;
        end
    end
end
