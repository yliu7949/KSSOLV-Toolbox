classdef CodeGenerator < handle
    %CODEGENERATOR 用于执行工作流中节点任务的代码生成器类

    methods (Static)
        function executeTasks(workflow)
            arguments
                workflow kssolv.services.workflow.WorkflowGraph
            end

            % 获取所有节点 ID
            allNodeIDs = keys(workflow.Nodes);

            % 遍历所有节点，找到连通的子图
            visited = containers.Map();  % 用于记录访问过的节点
            connectedComponents = {};    % 用于存储连通的节点子图

            % 查找连通的子图，忽略孤立节点
            for i = 1:length(allNodeIDs)
                nodeID = allNodeIDs{i};
                if ~isKey(visited, nodeID)
                    subgraph = kssolv.services.workflow.codegeneration.CodeGenerator.findConnectedNodes(workflow, nodeID, visited);
                    if ~isempty(subgraph)
                        connectedComponents{end+1} = subgraph;
                    end
                end
            end

            % 初始化上下文和输入
            input = struct();
            context = struct();

            % 遍历连通子图中的每个节点，执行任务
            for i = 1:length(connectedComponents)
                % 当前连通子图的节点列表
                nodeList = connectedComponents{i};
                initialInput = input;

                for j = 1:length(nodeList)
                    nodeID = nodeList{j};
                    node = workflow.Nodes(nodeID);  % 获取当前节点

                    % 执行任务，得到输出
                    output = node.task.executeTask(context, initialInput);

                    % 传递 output 作为下一个节点的 input
                    input = output;
                end
            end
        end

        function connectedNodes = findConnectedNodes(workflow, startNodeID, visited)
            % 递归查找从 startNodeID 连通的所有节点
            connectedNodes = {};
            if isKey(visited, startNodeID)
                return;
            end

            % 标记节点为已访问
            visited(startNodeID) = true;
            connectedNodes{end+1} = startNodeID;

            % 获取当前节点的子节点
            children = workflow.getChildren(startNodeID);
            for i = 1:length(children)
                childNodeID = children{i};
                if ~isKey(visited, childNodeID)
                    subNodes = kssolv.services.workflow.codegeneration.CodeGenerator.findConnectedNodes(workflow, childNodeID, visited);
                    connectedNodes = [connectedNodes, subNodes];
                end
            end

            % 获取当前节点的父节点（如果图中存在向上的依赖）
            parents = workflow.getParents(startNodeID);
            for i = 1:length(parents)
                parentNodeID = parents{i};
                if ~isKey(visited, parentNodeID)
                    subNodes = kssolv.services.workflow.codegeneration.CodeGenerator.findConnectedNodes(workflow, parentNodeID, visited);
                    connectedNodes = [connectedNodes, subNodes];
                end
            end
        end
    end
end
