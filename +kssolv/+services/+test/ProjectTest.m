function project = ProjectTest()
%PROJECTTEST 测试项目文件相关的函数
import kssolv.services.filemanager.Project

project = Project();
structure = Project.newItem('Structure');
structureName = project.addChildrenItemByName('Project', structure);
structureName2 = project.addChildrenItemByName(structureName, structure);
structureName3 = project.addChildrenItemByName(structureName2, structure);
structureName4 = project.addChildrenItemByName(structureName, structure);
project.removeItemByName(structureName3);
% project.getItemByName(structureName);
% project.removeItemByName(structureName);
% project.updateItemByName(structureName, struct('label', 's'));
workflow = Project.newItem('Workflow');
project.replaceItemByName(structureName4, workflow);
% project.saveToKsFile('ks.ks');
% project.loadKsFile('ks.ks');
end

