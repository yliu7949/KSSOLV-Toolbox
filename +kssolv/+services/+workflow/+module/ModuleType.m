classdef (Sealed = true) ModuleType < uint16
    %MODULETYPE 模块类型枚举类
    
    enumeration
        Preprocessing    (1)   % 前处理模块
        Computation      (2)   % 计算模块
        Postprocessing   (3)   % 后处理模块
        Visualization    (4)   % 可视化模块
    end
end

