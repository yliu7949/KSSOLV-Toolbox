function grpahJSON = getCurrentGraph()
%GETCURRENTGRAPH 获取当前工作流画布的 grpahJSON，包含了画布中的所有节点信息和连接关系

project = kssolv.ui.util.DataStorage.getData('Project');
workflowParentItem = project.findChildrenItem("Workflow");

if workflowParentItem.childrenCount >= 1
    grpahJSON = workflowParentItem.children{end, 1}.graphJSON;
end
end

