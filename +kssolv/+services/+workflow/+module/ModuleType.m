classdef (Sealed = true) ModuleType < uint16
    %MODULETYPE 模块类型枚举类

    %   开发者：杨柳
    %   版权 2024-2025 合肥瀚海量子科技有限公司

    enumeration
        Preprocessing    (1)   % 前处理模块
        Computation      (2)   % 计算模块
        Postprocessing   (3)   % 后处理模块
        Visualization    (4)   % 可视化模块
    end
end

