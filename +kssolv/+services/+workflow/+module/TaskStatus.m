classdef (Sealed = true) TaskStatus < int8
    %TASKSTATUS 任务进行状态
    
    enumeration
        NotStarted (1)   % 任务尚未开始
        InProgress (2)   % 任务正在进行
        Completed  (3)   % 任务已完成
        Failed     (4)   % 任务失败
    end
end

