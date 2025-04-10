classdef ChatBot < handle % & kssolv.services.llm.internal.tools
    %CHATBOT 基于部署在本地 Ollama™ 中的大语言模型实现对话功能

    % 此类依赖 MathWorks 发布的 Large Language Models with MATLAB 工具
    %  - https://github.com/matlab-deep-learning/llms-with-matlab

    % 开发者：杨柳
    % 版权 2025 合肥瀚海量子科技有限公司

    properties
        bot (1, 1) % 对话机器人对象
        modelName (1, 1) string % 所使用的 Ollama™ 中 LLM 模型的名称
        systemPrompt (1, 1) string % 系统提示词
        streamFunction (1, 1) % 流式传输函数
        messageHistory (1, 1) % 对话消息历史记录
    end

    methods
        function this = ChatBot(modelName, systemPrompt, streamFunction)
            %CHATBOT 构造函数，构造对话机器人对象
            arguments
                modelName (1, 1) string = "deepseek-r1:7b"
                systemPrompt (1, 1) string = ""
                streamFunction (1, 1) function_handle = @(token) fprintf("%s\n", token)
            end

            this.modelName = modelName;
            this.systemPrompt = systemPrompt;

            if ~kssolv.services.llm.isLLMWithMATLABAddonAvailable
                return
            end

            this.messageHistory = messageHistory();
            this.bot = ollamaChat(modelName, systemPrompt, Temperature=0.6, ...
                StreamFun=streamFunction);
        end

        function chat(this, prompt, useHistoryMessages)
            %CHAT 进行一次对话，可选择是否使用对话历史记录作为上下文
            arguments
                this
                prompt (1, 1) string = "你是谁？"
                useHistoryMessages (1, 1) logical = true
            end

            if ~kssolv.services.llm.isLLMWithMATLABAddonAvailable
                return
            end

            if useHistoryMessages
                % 将本次用户的 prompt 保存到历史消息中
                this.messageHistory = addUserMessage(this.messageHistory, prompt);
                prompt = this.messageHistory;
            end

            try
                % 携带所有历史消息获取 LLM 的响应消息
                [~, message, ~] = generate(this.bot, prompt, MaxNumTokens=Inf);
            catch
                this.bot = ollamaChat(this.modelName, this.systemPrompt, Temperature=0.6, ...
                    StreamFun=this.streamFunction);
                [~, message, ~] = generate(this.bot, prompt, MaxNumTokens=Inf);
            end

            if useHistoryMessages
                % 将 LLM 的响应消息保存到历史消息中
                this.messageHistory = addResponseMessage(this.messageHistory, message);
            end
        end

        function showMessageHistory(this, filterThinkContent)
            %SHOWMESSAGEHISTORY 展示全部对话历史记录
            % filterThinkContent: 是否不输出思考部分内容，默认为 true
            arguments
                this
                filterThinkContent (1, 1) logical = true
            end

            if isempty(this.messageHistory.Messages)
                return
            end

            for i = 1:length(this.messageHistory.Messages)
                message = this.messageHistory.Messages{1, i};
                content = message.content;

                if filterThinkContent
                    % 使用正则表达式移除 <think> 标签中的内容，并移除多余的空行
                    content = regexprep(message.content, '<think>.*?</think>\s*', '');
                    content = regexprep(content, '^\s*\n', '');
                    fprintf("[%s] %s\n", message.role, content);
                else
                    fprintf("[%s]\n%s\n", message.role, content);
                end
            end
        end
    end
end

