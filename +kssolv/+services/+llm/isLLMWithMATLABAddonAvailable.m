function isAvailable = isLLMWithMATLABAddonAvailable()
%ISLLMWITHMATLABADDONAVAILABLE 检查 Large Language Models (LLMs) with MATLAB 工具是否可用

% 开发者：杨柳
% 版权 2025 合肥瀚海量子科技有限公司

addons = matlab.addons.installedAddons;
isInstalled = any(contains(addons.Name, ...
    "Large Language Models (LLMs) with MATLAB", 'IgnoreCase', true));
isAvailable = isInstalled || exist('ollamaChat', 'class');
end

