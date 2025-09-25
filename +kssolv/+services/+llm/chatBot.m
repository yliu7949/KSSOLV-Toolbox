function bot = chatBot(modelName, systemPrompt, streamFunction)
%CHATBOT 构造对话机器人对象
arguments
    modelName (1, 1) string
    systemPrompt (1, 1) string = ""
    streamFunction (1, 1) function_handle = @(token) fprintf("%s\n", token)
end

if ~isempty(getenv("OPENAI_PROXY_URL")) && ~isempty(getenv("OPENAI_API_KEY"))
    if strlength(modelName) == 0 && ~isempty(getenv("OPENAI_MODEL_LIST"))
        availableModels = llms.openai.models;
        modelName = availableModels{1, 1};
    end

    try
        bot = kssolv.services.llm.online.ChatBot(modelName, systemPrompt, streamFunction);
    catch exception
        warning('KSSOLV:LLM:ServiceInitializationFailure', ...
            ['Failed to initialize LLM service. Please ensure :\n', ...
            'OPENAI_PROXY_URL and OPENAI_API_KEY are properly set for online service.\n'])
        bot = [];
    end
else
    try
        bot = kssolv.services.llm.ollama.ChatBot(modelName, systemPrompt, streamFunction);
    catch exception
        warning('KSSOLV:LLM:ServiceInitializationFailure', ...
            ['Failed to initialize LLM service. Please ensure :\n', ...
            'Ollama service is correctly configured for local usage.\n'])
        bot = [];
    end
end
end