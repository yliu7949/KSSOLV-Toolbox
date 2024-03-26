function project = ProjectTest()
%PROJECTTEST 测试项目文件相关的函数
import kssolv.services.fileManager.Project

project = Project();
structure = Project.newItem('Structure');
structureName = project.addChildrenItem('Project', structure);
structureName2 = project.addChildrenItem(structureName, structure);
structureName3 = project.addChildrenItem(structureName2, structure);
structureName4 = project.addChildrenItem(structureName, structure);
project.removeItemByName(structureName3);
% project.getItemByName(structureName);
% project.removeItemByName(structureName);
% project.updateItemByName(structureName, struct('label', 's'));
workflow = Project.newItem('Workflow');
project.replaceItemByName(structureName4, workflow);
% project.saveToKsFile('ks.ks');
% project.loadKsFile('ks.ks');
end

