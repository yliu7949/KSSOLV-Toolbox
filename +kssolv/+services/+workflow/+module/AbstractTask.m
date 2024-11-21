classdef (Abstract) AbstractTask < matlab.mixin.SetGet
    %ABSTRACTTASK Summary of this class goes here

    %   开发者：杨柳
    %   版权 2024 合肥瀚海量子科技有限公司

    properties (Abstract, Constant)
        TASK_NAME
        DESCRIPTION
    end

    properties (SetAccess = protected)
        module (1, 1) kssolv.services.workflow.module.ModuleType = 1
        requiredTaskNames = [] % 依赖的任务名

        supportGPU logical = false
        supportParallel logical = true
    end

    properties
        taskID (1, 1) string
        taskStatus kssolv.services.workflow.module.TaskStatus = "NotStarted"
        taskInput
        taskOutput

        usedParallelType {mustBeMember(usedParallelType, {'None', 'GPU', 'Processes', 'Threads'})} = 'None'
        executionTimeLimit {mustBeMember(executionTimeLimit, {'No Limit', '30 minutes', '1 hour', '2 hours'})} = 'No Limit'
        canAccessOtherTaskOutputs logical = true
        canShareOutputWithOtherTasks logical = true
        saveOutputToProjectResults logical = false

        options
        optionsUI
        isDebugMode logical = false
    end

    methods
        function this = AbstractTask()
            this.setup();
            this.getOptionsUI();
            if ~isempty(this.optionsUI)
                this.options = this.optionsUI.options;
            end
        end
    end

    methods (Abstract, Access = protected)
        setup(this)
    end

    methods (Abstract)
        getOptionsUI(this)

        %{
        code = generateCodeSnippet(this)
        [output, status] = run(this, input)
        progress = getProgress(this)
        saveResultsToProject()
        exportResultsToWorkspace()
        tf = supportsParallel(this)
        cleanup()
        %}
    end
end

