classdef RelaxationTask < kssolv.services.workflow.module.AbstractTask
    %RELAXATIONTASK 优化已有的结构信息，生成 Molecule/Crystal 类的新实例

    properties (Constant)
        TASK_NAME = 'Geometry Optimization';
        DESCRIPTION = 'Optimize the structure information of Molecule/Crystal object of KSSOLV';
    end

    methods (Access = protected)
        function this = setup(this)
            this.module = kssolv.services.workflow.module.ModuleType.Preprocessing;
            this.requiredTaskNames = [];
            this.supportGPU = false;
            this.supportParallel = false;
        end
    end

    methods
        function getOptionsUI(this)
            this.optionsUI = kssolv.services.workflow.module.preprocessing.RelaxationTaskUI();
        end

        function output = executeTask(this, ~, input)
            if isempty(this.optionsUI)
                return
            end
            taskOptions = this.optionsUI.options;

            relaxOptions = options.Relaxation();
            fields = fieldnames(taskOptions);
            for i = 1:length(fields)
                fieldName = fields{i};
                relaxOptions.(fieldName) = taskOptions.(fieldName);
            end

            [molecule, H, X, info] = geometryoptimization.relaxatoms(input.molecule, relaxOptions);

            output.molecule = molecule;
            output.H = H;
            output.X = X;
            output.relaxInfo = info;
            output.info = info.lastIonicStepInfo;
        end
    end
end

