classdef AbstractItem < handle
    %ABSTRACTITEM 项目文件树中节点的抽象定义
    
    %   开发者：杨柳
    %   版权 2024 合肥瀚海量子科技有限公司
    
    properties
        name        % 代码自动生成的唯一的节点名，不允许修改
        label       % 向用户展示的节点名，允许用户设置和修改
        description % 节点描述
        type        % 节点类型
        size        % 子节点数量
        children    % 子节点
    end

    properties (Hidden)
        % 当类的实例被编码为 JSON 时，设置为 Hidden 属性的成员可以避免被编码
        data        % 节点数据
        createdAt   % 创建时间
        updatedAt   % 更新时间
    end
    
    methods
        function this = AbstractItem(label, type)
            %ABSTRACTITEM 构造函数，构建空的节点
            arguments
                label string = "DefaultItem"
                type  string = "Data"
            end

            this.name = sprintf('%s(%s)', label, char(matlab.lang.internal.uuid));
            this.label = label;
            this.description = "";
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

        function childrenItemName = addChildrenItemByName(this, parentName, newItem)
            % 在 data 中迭代查找名为 parentName 的父节点，并为其添加一个新的子节点
            % newItem 是一个结构体，需要包含 name、label、type、children 字段
            if ~isfield(newItem, 'name') || ~isfield(newItem, 'label') || ...
                ~isfield(newItem, 'type') || ~isfield(newItem, 'children') || ...
                ~isfield(newItem, 'createdAt') || ~isfield(newItem, 'updatedAt')
                error('KSSOLV:FileManager:Item:FieldNotFound', ...
                    'The new item added to the project is missing some fields.');
            end

            newItem.name = sprintf('%s(%s)', newItem.name, char(matlab.lang.internal.uuid));
            if parentName == this.name
                % 如果父节点是根节点
                if isempty(this.children)
                    % 如果 children 是空的，初始化为一个结构体数组
                    this.children = newItem;
                else
                    % 否则，正常添加新的子节点
                    this.children(end+1) = newItem;
                end
            else
                % 对于非根节点的逻辑
                parentIndex = this.findItem(this, parentName, []);
                if isempty(parentIndex)
                    error('KSSOLV:FileManager:Item:ItemNotFound', ...
                        ['Parent item named "', parentName, '" not found.']);
                end
                evalString = "this";
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
        
        function removeItemByName(this, itemName)
            % 从项目结构体中删除名为 itemName 的节点
            if itemName == this.name
                error('KSSOLV:FileManager:Item:DeleteNotAllowed', ...
                        "The root item of Project cannot be deleted.");
            end
            itemIndex = this.findItem(this, itemName, []);
            if isempty(itemIndex)
                error(['Item named "', itemName, '" not found.']);
            end
            evalString = "this";
            for idx = itemIndex
                evalString = evalString + ".children(" + idx + ")";
            end
            evalString = evalString + " = [];";
            eval(evalString);
        end

        function item = getItemByName(this, itemName)
            % 获取名为 itemName 的节点
            itemIndex = this.findItem(this, itemName, []);
            if isempty(itemIndex)
                error('KSSOLV:FileManager:Item:ItemNotFound', ...
                      ['Item named "', itemName, '" not found.']);
            end
            evalString = "this";
            for idx = itemIndex
                evalString = evalString + ".children(" + idx + ")";
            end
            item = eval(evalString);
        end

        function item = updateItemByName(this, itemName, updates)
            % 更新名为 itemName 的节点的字段，如 label、type 和 data
            % updates 应该是一个结构体，包含要更新的字段和值
            itemIndex = this.findItem(this, itemName, []);
            if isempty(itemIndex)
                error('KSSOLV:FileManager:Item:ItemNotFound', ...
                      ['Item named "', itemName, '" not found.']);
            end
            evalString = "this";
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
            item = this.getItemByName(itemName);
        end

        function replaceItemByName(this, itemName, newItem)
            % 整体替换名为 itemName 的节点
            % newItem 应该是一个结构体，完全替换原有节点
            if ~isfield(newItem, 'name') || ~isfield(newItem, 'label') || ...
                ~isfield(newItem, 'type') || ~isfield(newItem, 'children') || ...
                ~isfield(newItem, 'createdAt') || ~isfield(newItem, 'updatedAt')
                error('KSSOLV:FileManager:Item:FieldNotFound', ...
                      'The new item replacing the project item is missing some fields.');
            end
        
            % 如果是根节点，不允许替换
            if itemName == this.name
                error('KSSOLV:FileManager:Item:ReplaceNotAllowed', ...
                      'The root item of the Project cannot be replaced.');
            end
        
            % 寻找要替换的节点索引
            itemIndex = this.findItem(this, itemName, []);
            if isempty(itemIndex)
                error('KSSOLV:FileManager:Item:ItemNotFound', ...
                      ['Item named "', itemName, '" not found.']);
            end
        
            % 构建到要替换节点父节点的 eval 字符串
            evalString = "this";
            for idx = itemIndex(1:end-1)
                evalString = evalString + ".children(" + idx + ")";
            end
        
            % 执行替换操作
            eval(evalString + ".children(" + itemIndex(end) + ") = newItem;");
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
            import kssolv.services.filemanager.Project;
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

