function grpahJSON = getCurrentGraph()
%GETCURRENTGRAPH 获取当前工作流画布的 grpahJSON，包含了画布中的所有节点信息和连接关系

%   开发者：杨柳
%   版权 2025 合肥瀚海量子科技有限公司

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

