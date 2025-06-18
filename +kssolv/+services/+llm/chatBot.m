function bot = chatBot(modelName, systemPrompt, streamFunction)
%CHATBOT 构造对话机器人对象
arguments
    modelName (1, 1) string = "o3-mini"
    systemPrompt (1, 1) string = ""
    streamFunction (1, 1) function_handle = @(token) fprintf("%s\n", token)
end

try
    if ~isempty(getenv("OPENAI_PROXY_URL")) && ~isempty(getenv("OPENAI_API_KEY"))
        bot = kssolv.services.llm.online.ChatBot(modelName, systemPrompt, streamFunction);
    else
        bot = kssolv.services.llm.ollama.ChatBot(modelName, systemPrompt, streamFunction);
    end
catch exception
    warning('KSSOLV:LLM:ServiceInitializationFailure', ...
        ['Failed to initialize LLM service.', ...
        'Ensure either:\n', ...
        '1. OPENAI_PROXY_URL and OPENAI_API_KEY are properly set for online service\n', ...
        '2. Ollama service is correctly configured for local usage']);
    bot = [];
end
end