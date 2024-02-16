classdef AbstractElement < handle
    %ABSTRACTELEMENT 工作流中的元素的抽象类，具体实现元素时可以继承该类
    %   开发者：杨柳
    %   版权 2024 合肥瀚海量子科技有限公司
    
    properties
        Property1
    end
    
    methods
        function obj = AbstractElement(inputArg1,inputArg2)
            %ABSTRACT 构造此类的实例
            %   此处显示详细说明
            obj.Property1 = inputArg1 + inputArg2;
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 此处显示有关此方法的摘要
            %   此处显示详细说明
            outputArg = obj.Property1 + inputArg;
        end
    end
end

