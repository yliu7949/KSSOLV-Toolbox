classdef DataStorage < handle
    %DATASTORAGE 非持久性的键值对类型数据存储，用于跨组件数据传递
    %   使用示例：
    %       import kssolv.ui.util.DataStorage.*
    %       setData('MyKey', myVariable);
    %       value = getData('MyKey');

    %   开发者：杨柳
    %   版权 2024 合肥瀚海量子科技有限公司
    
    properties (Access = private)
        DataMap
    end

    methods (Access = private)
        function this = DataStorage()
            % 私有构造函数，防止外部直接构造实例
            this.DataMap = containers.Map('KeyType', 'char', 'ValueType', 'any');
        end
    end

    methods (Static)
        function this = getInstance()
            % 静态方法，用于获取类的唯一实例
            persistent instance;
            if isempty(instance)
                instance = kssolv.ui.util.DataStorage();
            end

            this = instance;
        end
    end

    methods (Static)
        function setData(key, value)
            % 设置数据
            this = kssolv.ui.util.DataStorage.getInstance();
            this.DataMap(key) = value;
        end

        function value = getData(key)
            % 获取数据
            this = kssolv.ui.util.DataStorage.getInstance();
            if isKey(this.DataMap, key)
                value = this.DataMap(key);
            else
                value = [];
            end
        end

        function removeData(key)
            % 删除数据
            this = kssolv.ui.util.DataStorage.getInstance();
            if isKey(this.DataMap, key)
                remove(this.DataMap, key);
            end
        end

        function keys = getAllKeys()
            % 获取所有键
            this = kssolv.ui.util.DataStorage.getInstance();
            keys = this.DataMap.keys;
        end
    end
end

