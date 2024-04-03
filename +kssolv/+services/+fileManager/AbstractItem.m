classdef AbstractItem < handle
    %ABSTRACTITEM 项目文件树中节点的抽象定义
    %   开发者：杨柳
    %   版权 2024 合肥瀚海量子科技有限公司
    
    properties
        name      % 代码自动生成的唯一的节点名，不允许修改
        label     % 向用户展示的节点名，允许用户设置和修改
        type      % 节点类型
        data      % 节点数据
        createdAt % 创建时间
        updatedAt % 更新时间
        children  % 子节点
    end
    
    methods
        function this = AbstractItem(label, type)
            %ABSTRACTITEM 构造函数，构建空的节点
            arguments
                label string = "default"
                type  string = "plain"
            end

            this.name = sprintf('%s(%s)', label, char(matlab.lang.internal.uuid));
            this.label = label;
            this.type = type;
            this.createdAt = datetime;
            this.updatedAt = datetime;
            this.children = [];
        end
        
        function addChildrenItem(this, childrenItem)
            %ADDCHILDRENITEM 将 childrenItem 类追加到 data 数组中
            arguments
                this
                childrenItem AbstractItem
            end
            this.children(end+1) = childrenItem;
        end

        function childrenItemName = addChildrenItemByName(obj, parentName, newItem)
            % 在 data 中迭代查找名为 parentName 的父节点，并为其添加一个新的子节点
            % newItem 是一个结构体，需要包含 name、label、type、children 字段
            if ~isfield(newItem, 'name') || ~isfield(newItem, 'label') || ...
                ~isfield(newItem, 'type') || ~isfield(newItem, 'children') || ...
                ~isfield(newItem, 'createdAt') || ~isfield(newItem, 'updatedAt')
                error('KSSOLV:FileManager:Project:FieldNotFound', ...
                    'The new item added to the project is missing some fields.');
            end

            newItem.name = sprintf('%s(%s)', newItem.name, char(matlab.lang.internal.uuid));
            if parentName == obj.name
                % 如果父节点是根节点
                if isempty(obj.children)
                    % 如果 children 是空的，初始化为一个结构体数组
                    obj.children = newItem;
                else
                    % 否则，正常添加新的子节点
                    obj.children(end+1) = newItem;
                end
            else
                % 对于非根节点的逻辑
                parentIndex = obj.findItem(obj, parentName, []);
                if isempty(parentIndex)
                    error('KSSOLV:FileManager:Project:ItemNotFound', ...
                        ['Parent item named "', parentName, '" not found.']);
                end
                evalString = "obj";
                for idx = parentIndex
                    evalString = evalString + ".children(" + idx + ")";
                end
                evalString = evalString + ".children";
                if isempty(eval(evalString))
                    % 如果 children 是空的，初始化为一个结构体数组
                    eval(evalString + " = newItem;");
                else
                    % 否则，正常添加新的子节点
                    eval(evalString + "(end+1) = newItem;");
                end
            end
            childrenItemName = newItem.name;
        end
        
        function removeItemByName(obj, itemName)
            % 从项目结构体中删除名为 itemName 的节点
            if itemName == obj.name
                error('KSSOLV:FileManager:Project:DeleteNotAllowed', ...
                        "The root item of Project cannot be deleted.");
            end
            itemIndex = obj.findItem(obj, itemName, []);
            if isempty(itemIndex)
                error(['Item named "', itemName, '" not found.']);
            end
            evalString = "obj";
            for idx = itemIndex
                evalString = evalString + ".children(" + idx + ")";
            end
            evalString = evalString + " = [];";
            eval(evalString);
        end

        function item = getItemByName(obj, itemName)
            % 获取名为 itemName 的节点
            itemIndex = obj.findItem(obj, itemName, []);
            if isempty(itemIndex)
                error('KSSOLV:FileManager:Project:ItemNotFound', ...
                      ['Item named "', itemName, '" not found.']);
            end
            evalString = "obj";
            for idx = itemIndex
                evalString = evalString + ".children(" + idx + ")";
            end
            item = eval(evalString);
        end

        function item = updateItemByName(obj, itemName, updates)
            % 更新名为 itemName 的节点的字段，如 label、type 和 data
            % updates 应该是一个结构体，包含要更新的字段和值
            itemIndex = obj.findItem(obj, itemName, []);
            if isempty(itemIndex)
                error('KSSOLV:FileManager:Project:ItemNotFound', ...
                      ['Item named "', itemName, '" not found.']);
            end
            evalString = "obj";
            for idx = itemIndex
                evalString = evalString + ".children(" + idx + ")";
            end
            if isfield(updates, 'label')
                eval(evalString + ".label =  updates.label;");
            end
            if isfield(updates, 'type')
                eval(evalString + ".type =  updates.type;");
            end
            if isfield(updates, 'data')
                eval(evalString + ".data = updates.data;");
            end
            eval(evalString + ".updatedAt = datetime;");
            item = obj.getItemByName(itemName);
        end

    end

    methods (Static)
        function structure = newItem(name, type)
            % 创建带有字段的空白结构体
            arguments
                name string
                type string = "plain"
            end
            structure = struct('name', name, 'label', name, ...
                'type', type, 'createdAt', datetime, ...
                'updatedAt', datetime, 'children', []);
        end
    end

    methods (Access = private, Static)
        function itemIndex = findItem(data, itemName, currentIndex)
            % 递归函数寻找名为 itemName 的节点的索引
            % 若对应节点为 data.children(1).children(1).children(1)，则返回值为 [1, 1, 1] 
            import kssolv.services.fileManager.Project;
            itemIndex = [];
            if data.name == itemName
                itemIndex = currentIndex;
                return
            end
            for i = 1:length(data.children)
                foundItemIndex = Project.findItem(data.children(i), itemName, [currentIndex i]);
                if ~isempty(foundItemIndex)
                    itemIndex = foundItemIndex;
                    return
                end
            end
        end
    end
end

