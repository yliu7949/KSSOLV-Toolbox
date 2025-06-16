function app = kssolv(ksFile, hostInBrowser)
%KSSOLV 运行 KSSOLV 的图形用户界面

% 开发者：杨柳
% 版权 2024-2025 合肥瀚海量子科技有限公司

arguments
    ksFile string = ""
    hostInBrowser (1, 1) logical = strcmpi(getenv("HostAppInBrowser"), 'true')
end

% 创建 project 并保存至 DataStorage
import kssolv.services.filemanager.Project

if ksFile == ""
    project = Project();
else
    kssolv.ui.util.DataStorage.setData('LoadingKsFile', true);

    ksFile = fullfile(pwd, ksFile);
    project = Project.loadKsFile(ksFile);
end
kssolv.ui.util.DataStorage.setData('Project', project);
kssolv.ui.util.DataStorage.setData('ProjectFilename', ksFile);
kssolv.ui.util.DataStorage.setData('LoadingKsFile', false);

% 添加 +core 下面的 KSSOLV 文件夹到 MATLAB 路径中
try
    addpath(fullfile(fileparts(mfilename('fullpath')), '+kssolv', '+core', 'kssolv-3o'));
    evalc('KSSOLV.startup()');
catch
end

% 初始化图形用户界面
app = kssolv.KSSOLVToolbox();
app.HostInBrowser = hostInBrowser;

% 展示图形用户界面
app.show();
end

