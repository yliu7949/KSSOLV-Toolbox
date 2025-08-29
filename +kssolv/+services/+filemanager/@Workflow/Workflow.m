classdef Workflow < kssolv.services.filemanager.AbstractItem
    %WORKFLOW 定义了以".wf"为扩展名的 KSSOLV Toolbox 工作流类和相关操作函数

    %   开发者：杨柳
    %   版权 2024-2025 合肥瀚海量子科技有限公司

    properties (Hidden)
        graph kssolv.services.workflow.WorkflowGraph
        graphJSON string
        editedNode = []
    end

    methods
        function this = Workflow(label, type)
            %WORKFLOW 构造函数
            arguments
                label string = "Workflow"
                type string = "Workflow"
            end
            this = this@kssolv.services.filemanager.AbstractItem(label, type);
        end

        function showWorkflowDisplay(this)
            % 使用 graphJSON 以打开对应工作流的 document
            kssolv.ui.components.figuredocument.Workflow(this.graphJSON, this.name).Display();
        end

        function createWorkflowItem(this, isBlank)
            % 创建并添加工作流节点
            arguments
                this 
                isBlank (1, 1) logical = false
            end

            workflow = kssolv.services.filemanager.Workflow();
            if isBlank
                workflow.graphJSON = '[]';
            else
                workflow.graphJSON = kssolv.ui.components.figuredocument.Workflow.getDagJSON();
            end
            
            this.addChildrenItem(workflow);
            displayObj = kssolv.ui.components.figuredocument.Workflow(workflow.graphJSON, workflow.name);
            displayObj.Display();
        end

        function set.graphJSON(this, newValue)
            this.graphJSON = newValue;
            thisGraph = this.get("graph");
            if isempty(thisGraph)
                this.set("graph", kssolv.services.workflow.WorkflowGraph(jsondecode(newValue)));
                return
            end

            if ~strcmp(newValue, '') && ~isempty(thisGraph) && ~kssolv.ui.util.DataStorage.getData('LoadingKsFile')
                thisGraph.updateFromJSON(jsondecode(newValue));
            end
        end
    end
end

