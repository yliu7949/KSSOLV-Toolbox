classdef (Abstract) tools < handle
    %TOOLS 将 KSSOLV APIs 定义为可以被 LLM 使用的 function tools

    % 开发者：杨柳
    % 版权 2025 合肥瀚海量子科技有限公司

    properties
        toolsList (1, :) {mustBeA(toolsList, "openAIFunction")} = openAIFunction.empty
    end

    methods
        function this = tools()
            %TOOLS 构造函数，构建所有的工具函数并存放在 toolsList 中
            getCurrentGraphTool = openAIFunction("getCurrentGraph", ...
                "Retrieve the current workflow's information in JSON format");
            this.toolsList(end + 1) = getCurrentGraphTool;
        end
    end
end

