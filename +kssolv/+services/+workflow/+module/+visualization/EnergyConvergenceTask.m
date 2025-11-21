classdef EnergyConvergenceTask < kssolv.services.workflow.module.AbstractTask
    %ENERGYCONVERGENCETASK 能量收敛曲线和迭代误差曲线可视化任务

    %   开发者：杨柳
    %   版权 2024-2025 合肥瀚海量子科技有限公司

    properties (Constant)
        TASK_NAME = 'Energy Curve'
        IDENTIFIER = 'EnergyConvergenceTask'
        DESCRIPTION = 'Plot showing SCF energy convergence over iterations'
    end

    methods (Access = protected)
        function this = setup(this)
            this.module = kssolv.services.workflow.module.ModuleType.Visualization;
            this.requiredTasks = 'SCFTask';
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

            % 绘图
            energyConvergencePlot = kssolv.services.workflow.module.visualization.chart.EnergyConvergencePlot('TotalEnergy', context("info").Etotvec, 'SCFError', context("info").SCFerrvec);

            % 将 plot 保存到 Project/Results
            resultsItem = kssolv.services.filemanager.Results.getResultsItem();
            plotTag = resultsItem.addPlot(copy(energyConvergencePlot), 'EnergyConvergence');

            projectBrowser = kssolv.ui.util.DataStorage.getData('ProjectBrowser');
            projectBrowser.refreshUIAfterItemCreation(resultsItem.plotsItem);

            % 展示绘图结果
            dataPlot = kssolv.ui.components.figuredocument.DataPlot(energyConvergencePlot, plotTag);
            dataPlot.Display('EnergyConvergence');
        end
    end
end

