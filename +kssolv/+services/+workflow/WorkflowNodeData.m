classdef WorkflowNodeData < handle
    %WORKFLOWNODEDATA 与 kssolv.services.workflow.WorkflowGraph 节点的关联数据

    %   开发者：杨柳
    %   版权 2024-2025 合肥瀚海量子科技有限公司

    properties
        label (1, :) char
        status (1, :) char
        task = [] % kssolv.services.workflow.module.AbstractTask
    end

    methods
        function this = WorkflowNodeData(label, status, task)
            % 构造函数
            arguments
                label (1, :) char
                status (1, :) char
                task kssolv.services.workflow.module.AbstractTask
            end

            this.label = label;
            this.status = status;
            this.task = task;
        end
    end
end
