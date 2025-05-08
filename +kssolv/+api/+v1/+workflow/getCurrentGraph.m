function grpahJSON = getCurrentGraph()
%GETCURRENTGRAPH 获取当前工作流画布的 grpahJSON，包含了画布中的所有节点信息和连接关系

document = kssolv.ui.components.figuredocument.Workflow.getCurrentWorkflowDocument();
if isempty(document)
    grpahJSON = '';
    return
end

project = kssolv.ui.util.DataStorage.getData('Project');
workflowParentItem = project.findChildrenItem("Workflow");
currentWorkflow = workflowParentItem.findChildrenItem(document.Tag);

if ~isempty(currentWorkflow)
    grpahJSON = currentWorkflow.graphJSON;
else
    grpahJSON = '';
end
end

