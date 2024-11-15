classdef WorkflowNodeData < handle
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
