classdef ChatBot < handle
    %CHATBOT 基于部署在本地 Ollama™ 中的大语言模型实现对话功能

    % 此类依赖 MathWorks 发布的 Large Language Models with MATLAB 工具
    %  - https://github.com/matlab-deep-learning/llms-with-matlab

    % 开发者：杨柳
    % 版权 2025 合肥瀚海量子科技有限公司

    properties
        bot (1, 1) % 对话机器人对象
        modelName (1, 1) string % 所使用的 Ollama™ 中 LLM 模型的名称
        systemPrompt (1, 1) string % 系统提示词
        messageHistory (1, 1) % 对话消息历史记录
    end

    methods
        function this = ChatBot(modelName, systemPrompt)
            %CHATBOT 构造函数，构造对话机器人对象
            arguments
                modelName (1, 1) string = "deepseek-r1:7b"
                systemPrompt (1, 1) string = "请用中文尽可能简洁地直接回复最终结论。"
            end

            this.modelName = modelName;
            this.systemPrompt = systemPrompt;
            this.messageHistory = messageHistory();
            this.bot = ollamaChat(modelName, systemPrompt, ...
                StreamFun=@(token) fprintf("%s", token));
        end

        function chat(this, prompt, useHistoryMessages)
            %CHAT 进行一次对话，可选择是否使用对话历史记录作为上下文
            arguments
                this
                prompt (1, 1) string = "你是谁？"
                useHistoryMessages (1, 1) logical = true
            end

            if useHistoryMessages
                % 将本次用户的 prompt 保存到历史消息中
                this.messageHistory = addUserMessage(this.messageHistory, prompt);

                % 携带所有历史消息获取 LLM 的响应消息
                [~, response] = generate(this.bot, this.messageHistory, MaxNumTokens=500);

                % 将 LLM 的响应消息保存到历史消息中
                this.messageHistory = addResponseMessage(this.messageHistory, response);
            else
                generate(this.bot, prompt, MaxNumTokens=500);
            end

            fprintf('\n');
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

