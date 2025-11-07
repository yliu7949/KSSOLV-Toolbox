classdef DOSTask < kssolv.services.workflow.module.AbstractTask
    %DOSTASK 态密度计算任务

    %   开发者：杨柳
    %   版权 2025 合肥瀚海量子科技有限公司

    properties (Constant)
        TASK_NAME = 'DOS'
        IDENTIFIER = 'DOSTask'
        DESCRIPTION = 'Calculate and plot the Density of States (DOS)'
    end

    methods (Access = protected)
        function this = setup(this)
            this.module = kssolv.services.workflow.module.ModuleType.Visualization;
            this.requiredTasks = ['SCFTask', 'NSCFTask'];
            this.supportGPU = false;
            this.supportParallel = true;
        end
    end

    methods
        function setupOptionsUI(this)
            % 该 Task 使用 DOSTaskUI
            this.optionsUI = kssolv.services.workflow.module.visualization.DOSTaskUI();
        end

        function context = executeTask(this, context, ~)
            arguments
                this
                context containers.Map
                ~
            end

            if isempty(this.optionsUI)
                return
            end
            taskOptions = this.optionsUI.options;

            % 获取 UI 中设置的参数
            NSCFGrid = taskOptions.NSCFGrid;
            startEnergy = taskOptions.startEnergy;
            endEnergy = taskOptions.endEnergy;
            stepSize = taskOptions.stepSize;

            % 进行 NSCF 和态密度的计算
            crystal = copy(context("molecule"));
            NSCFOptions = context("NSCFOptions");
            NSCFOptions.rho0 = context("H").rho;
            NSCFOptions.enableParallelPool = true;
            energyBands = eband(crystal, NSCFOptions, NSCFGrid);

            energyRange = startEnergy:stepSize:endEnergy;
            dos = zeros(1, size(energyRange, 2));
            tetra = Tetrahedra(crystal.nkxyz);
            for i = 1:size(energyRange, 2)
                dos(i) = tetra.computeTDOS(crystal, energyBands, energyRange(i));
            end

            % 绘图
            DOSPlot = kssolv.services.workflow.module.visualization.chart.DOSPlot('dos', dos, 'energyRange', energyRange);
            dataPlot = kssolv.ui.components.figuredocument.DataPlot(DOSPlot);
            dataPlot.Display('Density of States (DOS)');

            % 输出 context
            context("NSCFOptions") = NSCFOptions;
            context("DOSPlot") = DOSPlot;
        end
    end
end