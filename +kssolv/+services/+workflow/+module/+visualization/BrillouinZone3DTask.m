classdef BrillouinZone3DTask < kssolv.services.workflow.module.AbstractTask
    %BRILLOUINZONE2DTASK 布里渊区可视化任务

    %   开发者：杨柳
    %   版权 2025 合肥瀚海量子科技有限公司

    properties (Constant)
        TASK_NAME = 'Brillouin Zone 3D'
        IDENTIFIER = 'BrillouinZone2DTask'
        DESCRIPTION = 'Plot Brillouin zone with path'
    end

    methods (Access = protected)
        function this = setup(this)
            this.module = kssolv.services.workflow.module.ModuleType.Visualization;
            this.requiredTasks = 'SymmetryAnalysisTask';
            this.supportGPU = false;
            this.supportParallel = false;
        end
    end

    methods
        function setupOptionsUI(this)
            % 该 Task 仅使用 BlankTaskUI
            this.optionsUI = kssolv.services.workflow.module.BlankTaskUI();
        end

        function context = executeTask(~, context, ~)
            arguments
                ~
                context containers.Map
                ~
            end

            reciprocalLattice = context("symmetry").reciprocal_primitive_lattice;
            b1 = reciprocalLattice(1, :);
            b2 = reciprocalLattice(2, :);
            b3 = reciprocalLattice(3, :);

            BrillouinZone3DPlot = kssolv.services.workflow.module.visualization.chart.BrillouinZonePlot('result', context("symmetry"), ...
                'withPath', true, 'b1', b1, 'b2', b2, 'b3', b3);
            dataPlot = kssolv.ui.components.figuredocument.DataPlot(BrillouinZone3DPlot);
            dataPlot.Display('BrillouinZone3D');

            % 输出 context
            context("BrillouinZone3DPlot") = BrillouinZone3DPlot;
        end
    end
end
