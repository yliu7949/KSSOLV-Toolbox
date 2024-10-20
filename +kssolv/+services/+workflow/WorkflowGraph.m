classdef WorkflowGraph
    %WORKFLOWGRAPH 从工作流画布中获取的 graphJSON 中解析节点间关系，
    % 更新节点信息（如标签和状态）后可以重新导出为 graphJSON。
    %
    % 用法示例：
    %

    %   开发者：杨柳
    %   版权 2024 合肥瀚海量子科技有限公司

    properties
        Nodes       % 存储节点数据的 Map，键为节点 ID，值为 WorkflowNodeData 类的实例
        Adjacency   % 存储邻接列表的 Map，键为节点 ID，值是包含 'parents' 和 'children' 的结构体
    end

    methods
        % 构造函数，从 JSON 初始化图
        function this = WorkflowGraph(graphJSON)
            this.Nodes = containers.Map();      % 存储自定义节点数据
            this.Adjacency = containers.Map();  % 存储父子关系

            % 从 graphJSON 添加节点和边
            this = this.updateFromJSON(jsondecode(graphJSON));
        end

        % 添加节点并初始化其邻接数据的函数
        function this = addNode(this, node)
            nodeID = node.id;

            % 如果节点已经存在，保留其旧的 task 信息
            if isKey(this.Nodes, nodeID)
                oldTask = this.Nodes(nodeID).task;  % 迁移旧的 task
            else
                oldTask = kssolv.services.workflow.module.computation.SCFTask();  % 新节点没有旧任务
            end

            % 使用 WorkflowNodeData 类存储节点数据
            this.Nodes(nodeID) = kssolv.services.workflow.WorkflowNodeData(node.data.label, node.data.status, oldTask);

            % 初始化该节点的邻接列表（父节点和子节点）
            if ~isKey(this.Adjacency, nodeID)
                this.Adjacency(nodeID) = struct( ...
                    'parents', {{}}, ...
                    'children', {{}} ...
                    );
            end
        end

        % 移除节点并更新邻接列表的函数
        function this = removeNode(this, nodeID)
            if isKey(this.Nodes, nodeID)
                % 从 Nodes 中移除节点
                remove(this.Nodes, nodeID);

                % 更新邻接：删除该节点作为父节点或子节点的引用
                nodeAdj = this.Adjacency(nodeID);

                % 从其父节点的子节点列表中删除该节点
                for i = 1:length(nodeAdj.parents)
                    parentID = nodeAdj.parents{i};
                    this.Adjacency(parentID).children = setdiff(this.Adjacency(parentID).children, {nodeID}, 'stable');
                end

                % 从其子节点的父节点列表中删除该节点
                for i = 1:length(nodeAdj.children)
                    childID = nodeAdj.children{i};
                    this.Adjacency(childID).parents = setdiff(this.Adjacency(childID).parents, {nodeID}, 'stable');
                end

                % 从邻接列表中移除该节点
                remove(this.Adjacency, nodeID);
            end
        end

        % 添加边（定义父子关系）的函数
        function this = addEdge(this, edge)
            sourceID = edge.source.cell;
            targetID = edge.target.cell;

            % 将 source 添加为 target 的父节点
            if ~ismember(sourceID, this.Adjacency(targetID).parents)
                target = this.Adjacency(targetID);
                target.parents{end+1} = sourceID;
            end

            % 将 target 添加为 source 的子节点
            if ~ismember(targetID, this.Adjacency(sourceID).children)
                source = this.Adjacency(sourceID);
                source.children{end+1} = targetID;
            end
        end

        % 移除边（解除父子关系）的函数
        function this = removeEdge(this, sourceID, targetID)
            if isKey(this.Adjacency, sourceID) && isKey(this.Adjacency, targetID)
                % 从 source 的子节点列表中删除 target
                this.Adjacency(sourceID).children = setdiff(this.Adjacency(sourceID).children, {targetID}, 'stable');
                % 从 target 的父节点列表中删除 source
                this.Adjacency(targetID).parents = setdiff(this.Adjacency(targetID).parents, {sourceID}, 'stable');
            end
        end

        % 获取节点的父节点（上游节点）的函数
        function parents = getParents(this, nodeID)
            if isKey(this.Adjacency, nodeID)
                parents = this.Adjacency(nodeID).parents;
            else
                parents = {};
            end
        end

        % 获取节点的子节点（下游节点）的函数
        function children = getChildren(this, nodeID)
            if isKey(this.Adjacency, nodeID)
                children = this.Adjacency(nodeID).children;
            else
                children = {};
            end
        end

        % 更新节点数据（如标签、状态）的函数
        function this = updateNode(this, nodeID, newData)
            if isKey(this.Nodes, nodeID)
                % 仅更新节点的相关字段
                fields = fieldnames(newData);
                for i = 1:length(fields)
                    this.Nodes(nodeID).(fields{i}) = newData.(fields{i});
                end
            end
        end

        % 从 graphJSON 更新图结构的函数
        function this = updateFromJSON(this, graphJSON)
            % 记录当前存在的节点 ID
            existingNodeIDs = keys(this.Nodes);
            newNodeIDs = {};

            if isstruct(graphJSON)
                graphJSON = graphJSON.cells;
            end

            % 首先处理节点
            for i = 1:length(graphJSON)
                cell = graphJSON{i};
                if isfield(cell, 'shape') && strcmp(cell.shape, 'dag-node')
                    this = this.addNode(cell);
                    newNodeIDs{end+1} = cell.id; %#ok<AGROW> % 收集新节点 ID
                end
            end

            % 再处理边
            for i = 1:length(graphJSON)
                cell = graphJSON{i};
                if isfield(cell, 'shape') && strcmp(cell.shape, 'dag-edge')
                    this = this.addEdge(cell);
                end
            end

            % 移除不再存在的节点
            nodesToRemove = setdiff(existingNodeIDs, newNodeIDs);
            for i = 1:length(nodesToRemove)
                this = this.removeNode(nodesToRemove{i});
            end
        end
    end
end
