classdef SCFTask < kssolv.services.workflow.module.AbstractTask
    %SCFTASK SCF 计算任务

    properties (Constant)
        TASK_NAME = 'SCF';
        DESCRIPTION = 'SCF computation';
    end
    
    methods
        function this = setup(this)
            this.module = kssolv.services.workflow.module.ModuleType.Computation;
            this.requiredTaskNames = 'BuildMolecule';
            this.supportGPU = true;
            this.supportParallel = true;
        end

        function getOptionsUI(this, accordion)
            arguments
                this 
                accordion matlab.ui.container.internal.Accordion
            end
            this.optionsUI = kssolv.services.workflow.module.computation.SCFTaskUI(accordion);
        end
    end
end

