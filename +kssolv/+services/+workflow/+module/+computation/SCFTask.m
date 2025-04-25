classdef SCFTask < kssolv.services.workflow.module.AbstractTask
    %SCFTASK SCF 计算任务

    %   开发者：杨柳
    %   版权 2024-2025 合肥瀚海量子科技有限公司

    properties (Constant)
        TASK_NAME = 'SCF';
        DESCRIPTION = 'SCF computation';
    end

    methods (Access = protected)
        function this = setup(this)
            this.module = kssolv.services.workflow.module.ModuleType.Computation;
            this.requiredTaskNames = 'BuildMolecule';
            this.supportGPU = true;
            this.supportParallel = true;
        end
    end

    methods
        function setupOptionsUI(this)
            this.optionsUI = kssolv.services.workflow.module.computation.SCFTaskUI();
        end

        function output = executeTask(this, ~, input)
            if isempty(this.optionsUI)
                return
            end
            taskOptions = this.optionsUI.options;

            SCFOptions = options.SCF();
            fields = fieldnames(taskOptions);
            for i = 1:length(fields)
                fieldName = fields{i};
                SCFOptions.(fieldName) = taskOptions.(fieldName);
            end

            [molecule, H, X, info] = scf(input.molecule, SCFOptions);
            output.molecule = molecule;
            output.H = H;
            output.X = X;
            output.info = info;
        end
    end
end

