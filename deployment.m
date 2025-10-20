function deployment(runtimeDelivery)
%DEPLOYMENT 编译 KSSOLV Toolbox 为独立应用程序，并生成安装包

% 开发者：杨柳
% 版权 2025 合肥瀚海量子科技有限公司

arguments
    runtimeDelivery {mustBeMember(runtimeDelivery, ["web", "installer", "none"])} = "installer"
end

% 确保安装了 LLMs with MATLAB 插件
addons = matlab.addons.installedAddons;
isInstalled = any(contains(addons.Name, ...
    "Large Language Models (LLMs) with MATLAB", 'IgnoreCase', true));
if ~isInstalled
    error('KSSOLV:Deployment:MissingRequiredAddOns', ...
        "在编译前需要手动安装 KSSOLV Toolbox 依赖的插件。");
end

% 设定代码依赖自动推断无法正确判断的、必须要包含的文件夹
projectRoot = fileparts(mfilename('fullpath'));
kssolv3Home = fullfile(projectRoot, "+kssolv", "+core", "kssolv-3o");
additionalFiles = [fullfile(projectRoot, "ks.ks"), ...
    fullfile(projectRoot, "+kssolv", "+ui"), ...
    fullfile(projectRoot, "+kssolv", "+services"), ...
    fullfile(kssolv3Home, "+example"), ...
    fullfile(kssolv3Home, "ppdata")];

% 设置编译属性并进行编译
buildOpts = compiler.build.StandaloneApplicationOptions(fullfile(projectRoot, "kssolv.m"));
buildOpts.AdditionalFiles = additionalFiles;
buildOpts.AutoDetectDataFiles = true;
buildOpts.OutputDir = fullfile(projectRoot, "StandaloneDesktopApp", "output", "build");
buildOpts.ObfuscateArchive = false;
buildOpts.Verbose = true;
buildOpts.EmbedArchive = true;
buildOpts.ExecutableIcon = fullfile(KSSOLV_Toolbox.UIResourcesDirectory, "icons", "LOGO.png");
buildOpts.ExecutableName = "KSSOLV_Toolbox";
buildOpts.ExecutableVersion = KSSOLV_Toolbox.Version;
buildOpts.TreatInputsAsNumeric = false;
buildResult = compiler.build.standaloneApplication(buildOpts);

% 下载 MATLAB Runtime 安装包
compiler.runtime.download;

% 设置打包属性并生成 KSSOLV Toolbox 的独立应用程序安装包
packageOpts = compiler.package.InstallerOptions(buildResult);
packageOpts.ApplicationName = KSSOLV_Toolbox.Name;
packageOpts.AuthorName = KSSOLV_Toolbox.Author;
packageOpts.AuthorEmail = KSSOLV_Toolbox.AuthorEmail;
packageOpts.AuthorCompany = KSSOLV_Toolbox.AuthorCompany;
packageOpts.Description = "基于 MATLAB 的平面波基组第一性原理计算工具箱。" + newline + KSSOLV_Toolbox.Description;
packageOpts.InstallerIcon = fullfile(projectRoot, "+kssolv", "+ui", "resources", "icons", "LOGO.png");
packageOpts.InstallerSplash = fullfile(projectRoot, "+kssolv", "+ui", "resources", "icons", "LOGO.png");
packageOpts.InstallerName = sprintf('KSSOLV_Toolbox_V%s', KSSOLV_Toolbox.Version);
packageOpts.OutputDir = fullfile(projectRoot, "StandaloneDesktopApp", "output", "package");
packageOpts.RuntimeDelivery = runtimeDelivery;
packageOpts.Summary = "平面波基组，第一性原理计算" + newline + KSSOLV_Toolbox.Summary;
packageOpts.Verbose = true;
packageOpts.Version = KSSOLV_Toolbox.Version;
compiler.package.installer(buildResult, "Options", packageOpts);
end
