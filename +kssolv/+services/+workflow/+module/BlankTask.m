classdef BlankTask < kssolv.services.workflow.module.AbstractTask
    %BLANKTASK 空白的任务类

    properties (Constant)
        TASK_NAME = '';
        DESCRIPTION = '';
    end

    methods (Access = protected)
        function setup(~)
            % 保持函数体为空
        end
    end

    methods
        function setModuleType(this, moduleType)
            arguments
                this 
                moduleType kssolv.services.workflow.module.ModuleType
            end
            this.module = moduleType;
        end

        function getOptionsUI(this)
            % 该 Task 仅使用 BlankTaskUI
            this.optionsUI = kssolv.services.workflow.module.BlankTaskUI;
        end
    end
end

