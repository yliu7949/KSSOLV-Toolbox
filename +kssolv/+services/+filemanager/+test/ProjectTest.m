function project = ProjectTest()
%PROJECTTEST 测试项目文件相关的函数
import kssolv.services.filemanager.*

project = Project();

workflowParent = Workflow();
project.addChildrenItem(workflowParent);
workflow1 = Workflow('Workflow1');
workflow2 = Workflow('Workflow2');
workflowParent.addChildrenItem(workflow1);
workflowParent.addChildrenItem(workflow2);

project.saveToKsFile('ks.ks');
% project.loadKsFile('ks.ks');
end

