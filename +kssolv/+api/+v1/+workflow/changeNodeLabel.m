function ok = changeNodeLabel(nodeID, newLabel)
%CHANGENODELABEL 改变指定节点的 label
arguments (Output)
    ok (1, 1) logical
end

eventDataStruct = struct('nodeID', nodeID, 'newLabel', newLabel);
kssolv.ui.components.figuredocument.Workflow.sendEventToWorkflowUI('workflowRenameNodeLabel', eventDataStruct);
ok = true;
end

