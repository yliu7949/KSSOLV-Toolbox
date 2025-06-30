function commandOutput = pythonCommand(pythonArguments)
%PYTHONCOMMAND 使用指定的 python 可执行路径执行 python 命令
%   COMMANDOUTPUT = pythonCommand(PYTHONARGUMENTS)
%
%   输入参数：
%       PYTHONARGUMENTS - 包含 python 命令及参数（字符串）
%
%   输出：
%       COMMANDOUTPUT - python 命令执行后的输出结果
%
%   异常：
%       如果未提供参数或 python 命令执行失败，将抛出错误
%
%   示例：
%       import kssolv.services.python.*
%       commandOutput = pythonCommand('-m pip install mp_api')
%
%   另见 kssolv.services.python.pipCommand

% 该函数修改自：
% https://github.com/mathworks/climatedatastore/blob/main/toolbox/%2Bmlboost/%2Bpython/pipCommand.m

% 开发者：杨柳
% 版权 2025 合肥瀚海量子科技有限公司

arguments
    pythonArguments (1, 1) string
end

% 将 python 命令与提供的参数组合
fullCommand = sprintf('"%s" %s', pyenv().Executable, pythonArguments);

% 使用 system 函数执行命令
[exitStatus, commandOutput] = system(fullCommand);
commandOutput = string(commandOutput);

% 检查命令是否执行成功
if exitStatus ~= 0
    error("KSSOLV:python:pythonCommandFailed", "python command ""%s"" failed: ""%s"" (exit code %d)", ...
        pythonArguments, strtrim(commandOutput), exitStatus);
end
end