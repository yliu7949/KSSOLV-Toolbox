classdef WorkflowNodeData < handle
    properties
        label
        status
        task
    end
    
    methods
        function this = WorkflowNodeData(label, status, task)
            % 构造函数
            if nargin > 0
                this.label = label;
                this.status = status;
                this.task = task;
            end
        end
    end
end
