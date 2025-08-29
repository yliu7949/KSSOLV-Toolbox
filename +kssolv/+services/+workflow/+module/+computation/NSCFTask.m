classdef NSCFTask < kssolv.services.workflow.module.AbstractTask
    %NSCFTASK NSCF 计算任务

    %   开发者：杨柳
    %   版权 2025 合肥瀚海量子科技有限公司

    properties (Constant)
        TASK_NAME = 'NSCF';
        DESCRIPTION = 'NSCF computation';
    end

    methods (Access = protected)
        function this = setup(this)
            this.module = kssolv.services.workflow.module.ModuleType.Computation;
            this.requiredTaskNames = [];
            this.supportGPU = true;
            this.supportParallel = false;
        end
    end

    methods
        function setupOptionsUI(this)
            this.optionsUI = kssolv.services.workflow.module.computation.NSCFTaskUI();
        end

        function output = executeTask(this, ~, ~)
            if isempty(this.optionsUI)
                return
            end
            taskOptions = this.optionsUI.options;

            NSCFOptions = options.NSCF();
            fields = fieldnames(taskOptions);
            for i = 1:length(fields)
                fieldName = fields{i};
                NSCFOptions.(fieldName) = taskOptions.(fieldName);
            end

            output.NSCFOptions = NSCFOptions;
        end
    end
end

