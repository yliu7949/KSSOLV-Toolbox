function pipPackages = pipList()
%PIPLIST 使用 pip freeze 获取已安装的 Python 包
%   PIPPACKAGES = kssolv.services.python.pipList()
%   使用 pip freeze 获取当前环境中安装的所有 Python 包及其版本，并返回为表格
%
%   输出：
%       PIPPACKAGES - 包含包名和版本的表格
%
%   示例：
%       pipPackages = kssolv.services.python.pipList()
%
%   另见 kssolv.services.python.pipCommand

% 该函数修改自：
% https://github.com/mathworks/climatedatastore/blob/main/toolbox/%2Bmlboost/%2Bpython/pipList.m

% 开发者：杨柳
% 版权 2025 合肥瀚海量子科技有限公司

% 调用 pip freeze
pipFreeze = kssolv.services.python.pipCommand("list --format=freeze --disable-pip-version-check");

% 将输出拆分为行，去除空行
lines = strtrim(splitlines(pipFreeze));
lines(lines == "") = [];

% 将每一行分割为包名和版本号
parts = split(lines, '==');

% 创建一个表格，包含包名和版本
pipPackages = table(parts(:, 1), parts(:, 2), 'VariableNames', {'Package', 'Version'});
end
