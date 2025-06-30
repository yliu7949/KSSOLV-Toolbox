function result = pipShow(packageName)
%PIPSHOW 获取指定 Python 包的详细信息
%   RESULT = kssolv.services.python.pipShow(PACKAGENAME)
%   使用 pip show 获取指定的 Python 包的详细信息，并将其返回为结构体
%
%   输入：
%       PACKAGENAME - 一个字符串，指定要查询的包的名称
%
%   输出：
%       RESULT - 包含包信息字段的结构体，如
%                Name（名称）、Version（版本）、Summary（简介）、Home-page（主页）、Author（作者）等
%
%   示例：
%       info = kssolv.services.python.pipShow('mp_api');
%       disp(info.Version);
%
%   另见 kssolv.services.python.pipCommand

% 该函数修改自：
% https://github.com/mathworks/climatedatastore/blob/main/toolbox/%2Bmlboost/%2Bpython/pipShow.m

% 开发者：杨柳
% 版权 2025 合肥瀚海量子科技有限公司

arguments
    packageName (1, 1) string
end

% 对指定包调用 pip show
pipShowOutput = kssolv.services.python.pipCommand("show " + packageName);

% 初始化结构体
result = struct();

% 将输出按行拆分并去除多余的空格
lines = strsplit(pipShowOutput, '\n');
lines = strtrim(lines);
lines(lines == "") = [];

% 解析每一行并添加到结构体
for i = 1:length(lines)
    property = strtrim(extractBefore(lines(i), ":"));
    value = strtrim(extractAfter(lines(i), ":"));
    result.(matlab.lang.makeValidName(property)) = value;
end
end
