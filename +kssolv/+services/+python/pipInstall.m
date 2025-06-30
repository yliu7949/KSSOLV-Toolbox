function installResult = pipInstall(packageName, option)
%PIPINSTALL 使用 pip 安装 Python 包
%   INSTALLRESULT = kssolv.services.python.pipInstall(PACKAGENAME)
%   使用 pip 安装指定的 Python 包并返回安装结果
%
%   INSTALLRESULT = kssolv.services.python.pipInstall(PACKAGENAME, 'Name', Value)
%   使用一个或多个名称-值对参数指定额外的安装选项
%
%   输入参数：
%       PACKAGENAME - 要安装的 Python 包名称（字符串）
%
%   名称-值对参数：
%       'version' - 要安装的包特定版本（字符串）
%       'upgrade' - 是否升级已安装的包（逻辑值）
%       'mirror'  - 是否使用镜像站加速（字符串）
%
%   输出：
%       INSTALLRESULT - pip 返回的安装结果（可选）
%
%   示例：
%       import kssolv.services.python.*
%       pipInstall('numpy', 'version', '1.21.0', 'upgrade', true)
%
%   另见 kssolv.services.python.pipCommand

% 该函数修改自：
% https://github.com/mathworks/climatedatastore/blob/main/toolbox/%2Bmlboost/%2Bpython/pipInstall.m

% 开发者：杨柳
% 版权 2025 合肥瀚海量子科技有限公司

arguments
    % 要安装的 Python 包名称
    packageName (1, 1) string
    % 要安装的包特定版本（可选）
    option.version (1, 1) string = ""
    % 是否升级已安装的包（可选）
    option.upgrade (1, 1) logical = false
    % 是否使用镜像站加速（可选，默认启用清华源）
    option.mirror (1, 1) string = "https://pypi.tuna.tsinghua.edu.cn/simple"
end

% 根据输入参数构建 pip 命令字符串，以"install"开头，后接包名称
% 如果指定了版本，将其追加到命令中
% 如果升级选项为 true，添加"--upgrade"标志
command = sprintf("install %s", packageName);
if option.version ~= ""
    command = command + sprintf("==%s", option.version);
end
if option.upgrade
    command = command + " --upgrade";
end
if strlength(option.mirror) ~= 0
    command = command + " -i " + option.mirror;
end

% 使用 kssolv.services.python.pipCommand 函数执行 pip 命令
% 并将输出存储在 cmdout 中
cmdout = kssolv.services.python.pipCommand(command);

% 如果请求了输出参数，将命令输出赋值给 installResult
if nargout > 0
    installResult = cmdout;
end
end
