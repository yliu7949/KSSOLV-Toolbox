function plan = buildfile
%BUILDFILE 根据任务函数构建编译计划并执行编译

import matlab.buildtool.tasks.CodeIssuesTask

plan = buildplan(localfunctions);
plan("check") = CodeIssuesTask(WarningThreshold=0, ...
    Results=".buildtool/code-issues/results.sarif");
plan("check").Dependencies = "init";

plan("pcode").Inputs = "+kssolv/**/*.m";
plan("pcode").Outputs = plan("pcode").Inputs.replace(".m",".p");
plan("pcode").Dependencies = "check";

plan.DefaultTasks = "package";
plan("package").Dependencies = "pcode";
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
uuid = "KSSOLV";
toolboxFolder = fileparts(mfilename('fullpath'));

options = matlab.addons.toolbox.ToolboxOptions(toolboxFolder, uuid);
options.AuthorName = "Liu Yang";
options.AuthorEmail = "and@mail.ustc.edu.cn";
options.AuthorCompany = "University of Science and Technology of China";
options.Description = "A MATLAB-Based Plane Wave Basis Set First-Principles Calculation Toolbox.";
options.Summary = "Plane Wave Basis, First-Principles Calculation";

options.OutputFile = fullfile(toolboxFolder, "KSSOLV_Toolbox.mltbx");
options.ToolboxName = "KSSOLV Toolbox";
options.ToolboxVersion = "0.1.0";
options.AppGalleryFiles = "kssolv.m";
options.SupportedPlatforms.Win64 = true;
options.SupportedPlatforms.Maci64 = true;
options.SupportedPlatforms.Glnxa64 = true;
options.SupportedPlatforms.MatlabOnline = true;

options.MinimumMatlabRelease = "R2023a";
options.MaximumMatlabRelease = "";

filteredConditions = ~contains(options.ToolboxFiles, 'ks.ks') & ...
    ~contains(options.ToolboxFiles, 'buildfile.m') & ...
    ~contains(options.ToolboxFiles, 'data/') & ...
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
