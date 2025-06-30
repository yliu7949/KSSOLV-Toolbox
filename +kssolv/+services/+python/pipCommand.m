function commandOutput = pipCommand(pipArguments)
%PIPCOMMAND 使用指定的 pip 可执行路径执行 pip 命令
%   COMMANDOUTPUT = pipCommand(PIPARGUMENTS)
%
%   输入参数：
%       PIPARGUMENTS - 包含 pip 命令及参数（字符串）
%
%   输出：
%       COMMANDOUTPUT - pip 命令执行后的输出结果
%
%   示例：
%       import kssolv.services.python.*
%       commandOutput = pipCommand('install mp_api')
%
%   另见 kssolv.services.python.pythonCommand

% 开发者：杨柳
% 版权 2025 合肥瀚海量子科技有限公司

arguments
    pipArguments (1, 1) string
end

% 将 pip 命令与参数组合，并由 python 执行 pip 命令
commandArguments = sprintf('-m pip %s', pipArguments);
commandOutput = kssolv.services.python.pythonCommand(commandArguments);
end
