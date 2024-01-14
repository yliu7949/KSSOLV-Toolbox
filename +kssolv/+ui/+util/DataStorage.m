classdef DataStorage
    %DATASTORAGE 非持久性的键值对类型数据存储，用于跨组件数据传递
    %   使用示例：
    %       import kssolv.ui.util.DataStorage.*
    %       setData('MyKey', myVariable);
    %       value = getData('MyKey');
    %
    %   开发者：杨柳
    %   版权 2024 合肥瀚海量子科技有限公司
    properties (Access = private)
        DataMap
    end

    methods (Access = private)
        function obj = DataStorage()
            % 私有构造函数，防止外部直接构造实例
            obj.DataMap = containers.Map('KeyType', 'char', 'ValueType', 'any');
        end
    end

    methods (Static)
        function obj = getInstance()
            % 静态方法，用于获取类的唯一实例
            persistent instance;
            if isempty(instance)
                instance = kssolv.ui.util.DataStorage();
            end
            obj = instance;
        end
    end

    methods (Static)
        function setData(key, value)
            % 设置数据
            obj = kssolv.ui.util.DataStorage.getInstance();
            obj.DataMap(key) = value;
        end

        function value = getData(key)
            % 获取数据
            obj = kssolv.ui.util.DataStorage.getInstance();
            if isKey(obj.DataMap, key)
                value = obj.DataMap(key);
            else
                value = [];
            end
        end

        function removeData(key)
            % 删除数据
            obj = kssolv.ui.util.DataStorage.getInstance();
            if isKey(obj.DataMap, key)
                remove(obj.DataMap, key);
            end
        end

        function keys = getAllKeys()
            % 获取所有键
            obj = kssolv.ui.util.DataStorage.getInstance();
            keys = obj.DataMap.keys;
        end
    end
end

