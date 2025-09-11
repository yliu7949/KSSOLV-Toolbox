function taskInstance = getTaskInstance(moduleType, taskName)
% GETTASKINSTANCE 根据模块类型和任务名获取类的实例
% 输入:
%   moduleType (ModuleType) - 模块类型枚举
%   taskName (char) - 任务名，例如 'SCF'
% 输出:
%   taskInstance - 返回指定任务类的实例

%   开发者：杨柳
%   版权 2024-2025 合肥瀚海量子科技有限公司

arguments
    moduleType kssolv.services.workflow.module.ModuleType
    taskName (1, :) char
end

% 获取该模块下所有任务名和对应的类名
[taskNames, classNames] = kssolv.services.workflow.module.getTaskNames(moduleType);

% 查找任务名是否在任务名列表中
taskIndex = find(strcmp(taskNames, taskName), 1);

% 如果没有找到对应的任务名，使用空白任务类以便于 Config Browser 的 UI 渲染
if isempty(taskIndex)
    taskInstance = kssolv.services.workflow.module.BlankTask();
    taskInstance.setModuleType(moduleType);
    return
end

% 获取与任务名对应的类名，得到类的完整路径
classPath = classNames{taskIndex};

try
    % 动态实例化类
    taskInstance = feval(classPath);
catch ME
    % 如果类不存在或实例化失败，抛出错误
    error('Unable to instantiate class "%s": %s', classPath, ME.message);
end
end
