classdef (Sealed = true) TaskStatus < int8
    %TASKSTATUS 任务进行状态

    %   开发者：杨柳
    %   版权 2024-2025 合肥瀚海量子科技有限公司

    enumeration
        NotStarted (1)   % 任务尚未开始
        InProgress (2)   % 任务正在进行
        Completed  (3)   % 任务已完成
        Failed     (4)   % 任务失败
    end
end

