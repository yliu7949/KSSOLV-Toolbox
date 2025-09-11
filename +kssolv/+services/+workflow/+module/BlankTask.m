classdef BlankTask < kssolv.services.workflow.module.AbstractTask
    %BLANKTASK 空白的任务类

    %   开发者：杨柳
    %   版权 2024-2025 合肥瀚海量子科技有限公司

    properties (Constant)
        TASK_NAME = ''
        IDENTIFIER = 'BlankTask'
        DESCRIPTION = ''
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

        function setupOptionsUI(this)
            % 该 Task 仅使用 BlankTaskUI
            this.optionsUI = kssolv.services.workflow.module.BlankTaskUI();
        end
    end
end

