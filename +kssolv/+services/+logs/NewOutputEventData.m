classdef NewOutputEventData < event.EventData
    %NEWOUTPUTEVENTDATA 当日记有新的输出时所触发事件的数据

    %   开发者：杨柳
    %   版权 2025 合肥瀚海量子科技有限公司

    properties
        Content % 事件携带的字符串内容
    end

    methods
        function this = NewOutputEventData(content)
            this.Content = content;
        end
    end
end