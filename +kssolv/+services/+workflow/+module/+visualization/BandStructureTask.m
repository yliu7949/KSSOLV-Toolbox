classdef BandStructureTask < kssolv.services.workflow.module.AbstractTask
    %BANDSTRUCTURETASK 能带结构可视化任务

    %   开发者：杨柳
    %   版权 2025 合肥瀚海量子科技有限公司

    properties (Constant)
        TASK_NAME = 'Band Structure'
        IDENTIFIER = 'BandStructureTask'
        DESCRIPTION = 'Plot electronic band structure'
    end

    methods (Access = protected)
        function this = setup(this)
            this.module = kssolv.services.workflow.module.ModuleType.Visualization;
            this.requiredTasks = 'BandProcessingTask';
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

            energyBandStructurePlot = kssolv.services.workflow.module.visualization.chart.BandStructurePlot('kPoints', context("bandProcessing").kPoints, ...
                'energyBands', context("bandProcessing").energyBands);
            dataPlot = kssolv.ui.components.figuredocument.DataPlot(energyBandStructurePlot);
            dataPlot.Display('EnergyBandStructure');

            % 输出 context
            context("EnergyBandStructurePlot") = energyBandStructurePlot;
        end
    end
end

