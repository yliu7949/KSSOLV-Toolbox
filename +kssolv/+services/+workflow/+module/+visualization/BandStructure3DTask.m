classdef BandStructure3DTask < kssolv.services.workflow.module.AbstractTask
    %BANDSTRUCTURE3DTASK 能带结构可视化任务

    %   开发者：杨柳
    %   版权 2025 合肥瀚海量子科技有限公司

    properties (Constant)
        TASK_NAME = 'Band Structure 3D'
        IDENTIFIER = 'BandStructure3DTask'
        DESCRIPTION = 'Plot 3D electronic band structure'
    end

    methods (Access = protected)
        function this = setup(this)
            this.module = kssolv.services.workflow.module.ModuleType.Visualization;
            this.requiredTasks = 'BandProcessing3DTask';
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

            crystal = context("molecule");
            kPoints = context("bandProcessing3D").kPoints;
            energyBands = context("bandProcessing3D").energyBands;
            slicePlane = context("bandProcessing3D").slicePlane;

            LUMOIndex = crystal.nel / 2 + 1;
            HOMOIndex = crystal.nel / 2;

            energyBandStructure3DPlot = kssolv.services.workflow.module.visualization.chart.BandStructure3DPlot('kPoints', kPoints, ...
                'energyBands', energyBands, 'slicePlane', slicePlane, 'bandIndex', [LUMOIndex, HOMOIndex]);
            dataPlot = kssolv.ui.components.figuredocument.DataPlot(energyBandStructure3DPlot);
            dataPlot.Display('EnergyBandStructure3D');

            % 输出 context
            context("EnergyBandStructure3DPlot") = energyBandStructure3DPlot;
        end
    end
end

