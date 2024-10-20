classdef EnergyConvergenceTask < kssolv.services.workflow.module.AbstractTask
    %ENERGYCONVERGENCETASK 能量收敛曲线和迭代误差曲线可视化任务

    properties (Constant)
        TASK_NAME = 'Energy Curve';
        DESCRIPTION = 'Plot showing SCF energy convergence over iterations';
    end

    methods
        function this = setup(this)
            this.module = kssolv.services.workflow.module.ModuleType.Computation;
            this.requiredTaskNames = 'SCF';
            this.supportGPU = false;
            this.supportParallel = false;
        end

        function getOptionsUI(~, accordion)
            % 该 Task 没有 options 选项，因此不提供 Options UI
            arguments
                ~
                accordion matlab.ui.container.internal.Accordion
            end

            if size(accordion.Children, 1) >= 4
                if accordion.Children(3).Title == "Options"
                    % 删除旧的 Options AccordionPanel
                    delete(accordion.Children(3));
                end

                if accordion.Children(3).Title == "Advanced Options"
                    % 删除旧的 Advanced Options AccordionPanel，注意在 Children 中的位置仍然是第三个
                    delete(accordion.Children(3));
                end
            end
        end
    end
end

