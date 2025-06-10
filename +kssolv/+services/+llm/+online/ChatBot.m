classdef ChatBot < kssolv.services.llm.internal.tools
    %CHATBOT 基于在线的大语言模型实现对话功能

    % 此类依赖 MathWorks 发布的 Large Language Models with MATLAB 工具
    %  - https://github.com/matlab-deep-learning/llms-with-matlab

    % 开发者：杨柳
    % 版权 2025 合肥瀚海量子科技有限公司

    properties
        bot (1, 1) % 对话机器人对象
        modelName (1, 1) string % 所使用的大语言模型的名称
        modelCapabilities (:, 1) cell % 所使用的大语言模型的能力，例如支持函数调用等
        systemPrompt (1, 1) string % 系统提示词
        streamFunction (1, 1) % 流式传输函数
        messageHistory (1, 1) % 对话消息历史记录
    end

    methods
        function this = ChatBot()
            %CHATBOT 构造函数，构造对话机器人对象
        end
    end
end