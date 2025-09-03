classdef TDDFTTask < kssolv.services.workflow.module.AbstractTask
    %TDDFTTASK TDDFT 计算任务

    %   开发者：杨柳
    %   版权 2025 合肥瀚海量子科技有限公司

    properties (Constant)
        TASK_NAME = 'TDDFT';
        DESCRIPTION = 'TDDFT computation';
    end

    methods (Access = protected)
        function this = setup(this)
            this.module = kssolv.services.workflow.module.ModuleType.Computation;
            this.requiredTaskNames = 'SCF';
            this.supportGPU = true;
            this.supportParallel = false;
        end
    end

    methods
        function setupOptionsUI(this)
            this.optionsUI = kssolv.services.workflow.module.computation.TDDFTTaskUI();
        end

        function output = executeTask(this, ~, input)
            if isempty(this.optionsUI)
                return
            end
            taskOptions = this.optionsUI.options;

            TDDFTOptions = tddft_setup(input.molecule, input.SCFOptions, ...
                input.H, input.X, namedargs2cell(taskOptions));
            [Et, Z] = tddft_casida_direct(TDDFTOptions, input.molecule);

            output.TDDFT.Et = Et;
            output.TDDFT.Z = Z;
        end
    end
end

