classdef BuildMoleculeTask < kssolv.services.workflow.module.AbstractTask
    %BUILDMOLECULETASK 由结构信息生成 KSSOLV 的 Molecule/Crystal 类的实例

    properties (Constant)
        TASK_NAME = 'Build Molecule';
        DESCRIPTION = 'Build Molecule/Crystal object of KSSOLV';
    end
    
    methods
        function this = setup(this)
            this.module = kssolv.services.workflow.module.ModuleType.Computation;
            this.requiredTaskNames = [];
            this.supportGPU = false;
            this.supportParallel = false;
        end
        
        function getOptionsUI(this, accordion)
            arguments
                this 
                accordion matlab.ui.container.internal.Accordion
            end
            this.optionsUI = kssolv.services.workflow.module.computation.BuildMoleculeTaskUI(accordion);
        end
    end
end

