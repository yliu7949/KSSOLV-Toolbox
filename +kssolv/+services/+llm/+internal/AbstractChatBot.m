classdef AbstractChatBot < kssolv.services.llm.internal.tools
    %ABSTRACTCHATBOT 基于大语言模型实现对话功能的抽象类

    % 此类依赖 MathWorks 发布的 Large Language Models with MATLAB 工具
    %  - https://github.com/matlab-deep-learning/llms-with-matlab

    % 开发者：杨柳
    % 版权 2025 合肥瀚海量子科技有限公司

    properties
        bot (1, 1) % 对话机器人对象
        modelName (1, 1) string % 所使用的 LLM 模型的名称
        modelCapabilities (:, 1) cell % 所使用的大语言模型的能力，例如支持函数调用等
        systemPrompt (1, 1) string % 系统提示词
        streamFunction (1, 1) % 流式传输函数
        messageHistory (1, 1) % 对话消息历史记录
    end

    properties (Access = protected)
        chatType % "ollamaChat" 或 "openAIChat"
    end

    methods (Abstract, Access = protected)
        buildChatBot(this) % 使用 ollamaChat 或 openAIChat 实例化对话机器人
    end

    methods
        function this = AbstractChatBot(chatType, modelName, systemPrompt, streamFunction)
            %CHATBOT 构造函数，构造对话机器人对象
            arguments
                chatType char {mustBeMember(chatType, {'ollamaChat', 'openAIChat'})} = 'openAIChat'
                modelName (1, 1) string = "gpt-5-mini"
                systemPrompt (1, 1) string = ""
                streamFunction (1, 1) function_handle = @(token) fprintf("%s\n", token)
            end

            this.chatType = chatType;
            this.modelName = modelName;
            this.systemPrompt = systemPrompt;
            this.streamFunction = streamFunction;
            this.messageHistory = messageHistory();

            if ~kssolv.services.llm.isLLMWithMATLABAddonAvailable
                return
            end

            getModelCapabilities(this);
            buildChatBot(this);
        end

        function chat(this, promptHistory, useHistoryMessages)
            %CHAT 进行一次对话，可选择是否使用对话历史记录作为上下文
            arguments
                this
                promptHistory (1, 1) string = "你是谁？"
                useHistoryMessages (1, 1) logical = true
            end

            if ~kssolv.services.llm.isLLMWithMATLABAddonAvailable
                return
            end

            % 将本次用户的 prompt 保存到历史消息中
            if useHistoryMessages
                this.messageHistory = addUserMessage(this.messageHistory, promptHistory);
                promptHistory = this.messageHistory;
            else
                tempMessageHistory = addUserMessage(messageHistory(), promptHistory); %#ok<CPROPLC>
                promptHistory = tempMessageHistory;
            end

            try
                % 携带所有历史消息获取 LLM 的响应消息
                [~, message, response] = generate(this.bot, promptHistory, MaxNumTokens=Inf);
            catch ME
                buildChatBot(this);
                [~, message, response] = generate(this.bot, promptHistory, MaxNumTokens=Inf);
            end

            % 将 LLM 的响应消息保存到历史消息中
            promptHistory = addResponseMessage(promptHistory, message);

            if response.StatusCode == "OK" && ismember('tools', this.modelCapabilities)
                if isfield(message, 'tool_calls') && ~isempty(message.tool_calls)
                    functionCall = message.tool_calls;
                    functionId = "";
                    if isfield(functionCall, "id")
                        functionId = string(functionCall.id);
                    end

                    functionResult = this.functionCallAttempt(functionCall);
                    promptHistory = addToolMessage(promptHistory, ...
                        functionId, functionCall.function.name, functionResult);
                    [~, message, ~] = generate(this.bot, promptHistory, MaxNumTokens=Inf);
                    promptHistory = addResponseMessage(promptHistory, message);
                end
            end

            if useHistoryMessages
                this.messageHistory = promptHistory;
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

        function getModelCapabilities(this)
            %GETMODELCAPABILITIES 获取模型的能力
            proxyBase = string(strtrim(getenv("OPENAI_PROXY_URL")));

            if isempty(proxyBase)
                % 本地 Ollama 模型
                try
                    url = "http://localhost:11434/api/show";
                    options = weboptions("Timeout", 30, "ContentType", "json");
                    response = webwrite(url, struct("name", this.modelName), options);
                    this.modelCapabilities = response.capabilities;
                catch
                    this.modelCapabilities = {};
                end
                return
            end

            % 将 URL 提取到 /v1（例如 https://aihubmix.com/v1）
            proxyBaseV1 = regexp(proxyBase, '^(https?://[^?#]*?/v1)', 'tokens', 'once');

            if contains(lower(proxyBaseV1), "/v1")
                % 若为 OpenAI 风格代理（例如 https://api.openai.com/v1）

                apiKey = getenv("OPENAI_API_KEY");
                if strlength(apiKey) == 0
                    error("OPENAI_API_KEY is not set, unable to get model information from OpenAI style agent.");
                end

                % 通过尝试 tool using 功能来判断在线大模型是否支持工具调用
                tempBot = openAIChat(this.systemPrompt, ModelName=this.modelName, ...
                    Temperature=0.6, Tools=this.toolsList);
                try
                    generate(tempBot, "Hi", MaxNumTokens=Inf);
                    this.modelCapabilities = {'tools'};
                catch
                    this.modelCapabilities = {};
                end
                return
            end

            try
                % 假设为 Ollama 兼容的代理/base（例如 http://my-ollama-host:11434）
                url = proxyBaseV1 + "/api/show";
                options = weboptions("Timeout", 30, "ContentType", "json");
                response = webwrite(url, struct("name", this.modelName), options);
                if isfield(response, "capabilities")
                    this.modelCapabilities = response.capabilities;
                else
                    this.modelCapabilities = {};
                end
            catch ME
                warning("Failed to obtain model capabilities.");
                this.modelCapabilities = {};
            end
        end
    end

    methods (Access = private)
        function functionCall = processResponseData(~, responseData)
            % [Unused]
            % 如果存在工具函数调用响应，则尝试调用相应的工具函数
            functionCall = [];
            if isstruct(responseData)
                data = responseData;
                if isfield(data, 'message') && isfield(data.message, 'tool_calls')
                    functionCall = data.message.tool_calls;
                end
            elseif iscell(responseData)
                data = responseData{1, 1};
                if isfield(data, 'message') && isfield(data.message, 'tool_calls')
                    functionCall = data.message.tool_calls;
                end
            elseif isa(responseData, 'uint8') && iscolumn(responseData)
                % 如果 responseData 是 nx1 的 uint8 数组，即流式传输数据
                lines = splitlines(char(responseData'));

                for i = 1:length(lines)
                    line = strtrim(lines{i});

                    if isempty(line)
                        continue;
                    end

                    if startsWith(line, 'data:')
                        % 提取 "data: " 后面的 JSON 部分
                        jsonString = strip(extractAfter(line, 'data:'));

                        % [DONE] 是结束标志
                        if strcmp(jsonString, '[DONE]')
                            break
                        end

                        % 解码 JSON 字符串为 MATLAB 结构体
                        try
                            dataStruct = jsondecode(jsonString);
                        catch ME
                            fprintf('Warning: JSON decoding failed, content: "%s". Error: %s\n', jsonString, ME.message);
                            continue;
                        end

                        % 提取并拼接内容
                        if isfield(dataStruct, 'choices') && ~isempty(dataStruct.choices)
                            choice = dataStruct.choices(1); % 通常只关心第一个 choice
                            if isfield(choice, 'delta') && isfield(choice.delta, 'tool_calls')
                                functionCall = choice.delta.tool_calls;
                                return
                            end

                            % 检查结束原因
                            if isfield(choice, 'finish_reason') && ~isempty(choice.finish_reason)
                                break
                            end
                        end
                    end
                end
            end
        end
    end
end
