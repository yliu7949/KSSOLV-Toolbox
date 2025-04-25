function plan = buildfile
%BUILDFILE 根据任务函数构建编译计划并执行编译

import matlab.buildtool.tasks.CodeIssuesTask

plan = buildplan(localfunctions);
plan("check") = CodeIssuesTask(WarningThreshold = Inf, ...
    Results = ".buildtool/code-issues/results.sarif");
plan("check").Dependencies = "init";

plan("pcode").Inputs = "+kssolv/**/*.m";
plan("pcode").Outputs = plan("pcode").Inputs.replace(".m",".p");
plan("pcode").Dependencies = "check";

plan("package").Dependencies = "pcode";

plan.DefaultTasks = "cleanPcode";
plan("cleanPcode").Inputs = plan("pcode").Outputs;
plan("cleanPcode").Dependencies = "package";

plan("stats").Inputs = "**/*.m";
plan("stats").Dependencies = "init";
end

function initTask(~)
% 初始化
try
    rmdir('build', 's');
catch
end
end

function pcodeTask(context)
% 将所有 .m 结尾的工程文件加密混淆为 .p 文件
filePaths = context.Task.Inputs.paths;
pcode(filePaths{:}, "-inplace", "-R2022a");
end

function packageTask(~)
% 打包编译结果
identifier = '5200919d-0e3d-4525-ad64-977f32dedd5d';
toolboxFolder = fileparts(mfilename('fullpath'));

options = matlab.addons.toolbox.ToolboxOptions(toolboxFolder, identifier);
options.AuthorName = "Liu Yang";
options.AuthorEmail = "and@mail.ustc.edu.cn";
options.AuthorCompany = "University of Science and Technology of China";
options.Description = "A MATLAB-Based Plane Wave Basis Set First-Principles Calculation Toolbox.";
options.Summary = "Plane Wave Basis, First-Principles Calculation";

options.OutputFile = fullfile(toolboxFolder, "KSSOLV_Toolbox.mltbx");
options.ToolboxName = "KSSOLV Toolbox";
options.ToolboxVersion = "0.1.1";
options.AppGalleryFiles = "kssolv.m";
options.SupportedPlatforms.Win64 = true;
options.SupportedPlatforms.Maci64 = true;
options.SupportedPlatforms.Glnxa64 = true;
options.SupportedPlatforms.MatlabOnline = true;

options.MinimumMatlabRelease = "R2024a";
options.MaximumMatlabRelease = "";

filteredConditions = ~endsWith(options.ToolboxFiles, '.ks') & ...
    ~contains(options.ToolboxFiles, 'buildfile.m') & ...
    ~contains(options.ToolboxFiles, '+test/') & ...
    ~endsWith(options.ToolboxFiles, '.mltbx') & ...
    ~endsWith(options.ToolboxFiles, '.DS_Store') & ...
    ~endsWith(options.ToolboxFiles, '.keep') & ...
    ~endsWith(options.ToolboxFiles, '.gitignore') & ...
    ~endsWith(options.ToolboxFiles, '.gitattributes') & ...
    ~(contains(options.ToolboxFiles, '+kssolv/') & endsWith(options.ToolboxFiles, '.m'));
options.ToolboxFiles = options.ToolboxFiles(filteredConditions);

matlab.addons.toolbox.packageToolbox(options);
end

function cleanPcodeTask(context)
% 删除生成的 .p 文件
filePaths = context.Task.Inputs.paths;
for i = 1:length(filePaths)
    if isfile(filePaths{i})
        delete(filePaths{i});
    end
end
end

function statsTask(context)
% 统计所有 .m 文件的数量和总代码行数（非空行和非注释行）
filePaths = context.Task.Inputs.paths;
filePaths = filePaths(~contains(filePaths, filesep + "+core" + filesep));
numFiles = numel(filePaths);
totalLines = 0;
codeLines = 0;

for i = 1:numFiles
    fileContent = fileread(filePaths{i});
    lines = strsplit(fileContent, '\n');
    totalLines = totalLines + numel(lines);
    for j = 1:numel(lines)
        line = strtrim(lines{j});
        if ~isempty(line) && ~startsWith(line, '%')
            codeLines = codeLines + 1;
        end
    end
end

fprintf('Total number of .m files: %d\n', numFiles);
fprintf('Total lines of code: %d\n', totalLines);
fprintf('Total non-empty, non-comment lines of code: %d\n', codeLines);
end
