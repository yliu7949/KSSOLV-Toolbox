function generateCommandReferences(toolboxPath, overwriteFile)
%GENERATECOMMANDREFERENCES 将 MATLAB 的类和命令生成文本文件以供自动补全

% 开发者：杨柳
% 版权 2025 合肥瀚海量子科技有限公司

arguments
    toolboxPath = fullfile(matlabroot, 'toolbox', 'matlab')
    overwriteFile (1, 1) logical = true
end

% 获取所有.m文件
mFiles = dir(fullfile(toolboxPath, '**', '*.m'));

% 设置输出文件路径
outputFilePath = fullfile(fileparts(mfilename('fullpath')), 'html', 'commandReferences.txt');

% 生成所有命令
commands = cell(length(mFiles), 1);
for i = 1:length(mFiles)
    filePath = fullfile(mFiles(i).folder, mFiles(i).name);
    commands{i} = constructCommand(filePath, toolboxPath);
end

% 去重并排序
commands = unique(commands);

% 确定写入模式
if overwriteFile && exist(outputFilePath, 'file')
    delete(outputFilePath);
end
fileMode = ternary(overwriteFile, 'w', 'a');

% 写入文件
fileID = fopen(outputFilePath, fileMode);
for i = 1:length(commands)
    fprintf(fileID, '%s\n', commands{i});
end
fclose(fileID);

import kssolv.ui.util.Localizer.*
fprintf(message('KSSOLV:toolbox:CommandReferencesFileGenerated'), outputFilePath);
end

function command = constructCommand(filePath, toolboxMatlabPath)
% 构建相对路径
relativePath = strrep(filePath, toolboxMatlabPath, '');
relativePath = relativePath(2:end);

% 提取包名和文件名
parts = strsplit(relativePath, '/');
packageName = '';
for i = 1:length(parts)
    if startsWith(parts{i}, '+')
        packageName = [packageName, parts{i}(2:end), '.']; %#ok<AGROW>
    end
end
packageName = packageName(1:end-1);

fileName = parts{end}(1:end-2);

% 生成访问命令
command = ternary(~isempty(packageName), ...
    [packageName, '.', fileName], ...
    fileName);
end

function result = ternary(condition, trueValue, falseValue)
% 三元运算符
if condition
    result = trueValue;
else
    result = falseValue;
end
end
