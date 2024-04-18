function app = kssolv(ksFile)
%KSSOLVGUI 运行 KSSOLV 的用户图形界面
% 开发者：杨柳
% 版权 2024 合肥瀚海量子科技有限公司

arguments
    ksFile string = ""
end

% 创建 project 并保存至 DataStorage
import kssolv.services.filemanager.Project
if ksFile == ""
    project = Project();
else
    project = Project.loadKsFile(ksFile);
end
kssolv.ui.util.DataStorage.setData('Project', project);
kssolv.ui.util.DataStorage.setData('ProjectFilename', ksFile);

% 初始化及运行用户图形界面
app = kssolv.KSSOLVToolbox();
end

