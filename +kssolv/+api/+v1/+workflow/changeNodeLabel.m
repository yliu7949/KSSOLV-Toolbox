function ok = changeNodeLabel(nodeID, newLabel)
%CHANGENODELABEL 改变指定节点的 label

%   开发者：杨柳
%   版权 2025 合肥瀚海量子科技有限公司

arguments (Output)
    ok (1, 1) logical
end

eventDataStruct = struct('nodeID', nodeID, 'newLabel', newLabel);
kssolv.ui.components.figuredocument.Workflow.sendEventToWorkflowUI('workflowRenameNodeLabel', eventDataStruct);
ok = true;
end

