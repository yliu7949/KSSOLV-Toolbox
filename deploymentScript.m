clear;clc

projectRoot = fileparts(mfilename('fullpath'));
kssolv3Home = fullfile(projectRoot, "+kssolv", "+core", "kssolv-3o");
additionalFiles = [fullfile(projectRoot, "+kssolv", "+ui"), ...
    fullfile(projectRoot, "+kssolv", "+services"), ...
    fullfile(kssolv3Home, "+example"), ...
    fullfile(kssolv3Home, "ppdata")];

% Create target build options object, set build properties and build.
buildOpts = compiler.build.StandaloneApplicationOptions(fullfile(projectRoot, "kssolvStart.m"));
buildOpts.AdditionalFiles = additionalFiles;
buildOpts.AutoDetectDataFiles = true;
buildOpts.OutputDir = fullfile(projectRoot, "StandaloneDesktopApp", "output", "build");
buildOpts.ObfuscateArchive = false;
buildOpts.Verbose = true;
buildOpts.EmbedArchive = true;
buildOpts.ExecutableIcon = fullfile(projectRoot, "+kssolv", "+ui", "resources", "icons", "LOGO.png");
buildOpts.ExecutableName = "KSSOLV_Toolbox";
buildOpts.ExecutableVersion = "0.2.0";
buildOpts.TreatInputsAsNumeric = false;
buildResult = compiler.build.standaloneApplication(buildOpts);

% Download the MATLAB Runtime to include in the installer.
compiler.runtime.download;

% Create package options object, set package properties and package.
packageOpts = compiler.package.InstallerOptions(buildResult);
packageOpts.ApplicationName = "KSSOLV Toolbox";
packageOpts.AuthorName = "微光萌生";
packageOpts.AuthorEmail = "and@mail.ustc.edu.cn";
packageOpts.AuthorCompany = "微光萌生初创团队";
packageOpts.Description = "基于 MATLAB 的平面波基组第一性原理计算工具箱。" + newline + "A MATLAB-Based Plane Wave Basis Set First-Principles Calculation Toolbox.";
packageOpts.InstallerIcon = fullfile(projectRoot, "+kssolv", "+ui", "resources", "icons", "LOGO.png");
packageOpts.InstallerSplash = fullfile(projectRoot, "+kssolv", "+ui", "resources", "icons", "LOGO.png");
packageOpts.OutputDir = fullfile(projectRoot, "StandaloneDesktopApp", "output", "package");
packageOpts.RuntimeDelivery = "installer";
packageOpts.Summary = "平面波基组，第一性原理计算" + newline + "Plane Wave Basis, First-Principles Calculation";
packageOpts.Verbose = true;
packageOpts.Version = "0.2.0";
compiler.package.installer(buildResult, "Options", packageOpts);
