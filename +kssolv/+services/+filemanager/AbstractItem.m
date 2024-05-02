classdef AbstractItem < handle
    %ABSTRACTITEM 项目文件树中节点的抽象定义
    
    %   开发者：杨柳
    %   版权 2024 合肥瀚海量子科技有限公司
    
    properties
        name        % 代码自动生成的唯一的节点名，不允许修改
        label       % 向用户展示的节点名，允许用户设置和修改
        description % 节点描述
        type        % 节点类型  
        children    % 子节点
    end

    properties (Dependent, Hidden)
        childrenItemSize        % 子节点数量
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
            this.children = {};
        end
        
        function addChildrenItem(this, childrenItem)
            %ADDCHILDRENITEM 将 childrenItem 类追加到 data 数组中
            arguments
                this
                childrenItem kssolv.services.filemanager.AbstractItem
            end
            this.children{end+1} = childrenItem;
        end

        function output = get.childrenItemSize(this)
            output = sprintf('%dx%d', size(this.children, 1), size(this.children, 2));
        end
    end
end

