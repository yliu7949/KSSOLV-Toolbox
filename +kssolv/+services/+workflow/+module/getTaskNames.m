function [taskNames, classNames] = getTaskNames(moduleType)
% GETTASKNAMES 获取指定模块下所有以 "Task" 结尾的任务类的 TASK_NAME 和对应的类名
%
% 输入参数说明:
%   moduleType: 必须是枚举类型 'kssolv.services.workflow.module.ModuleType' 的一个实例，表示需要查询的模块类型。
%
% 输出参数说明:
%   taskNames: 一个 cell 数组，包含模块中所有任务类的 TASK_NAME 属性值。
%   classNames: 一个与 taskNames 对应的 cell 数组，包含任务类的类名。
%
% 示例:
%   [taskNames, classNames] = getTaskNames(ModuleType.Computation);
%   taskNames 将包含所有 "Task" 结尾的类的 TASK_NAME，classNames 将包含对应的类名。

%   开发者：杨柳
%   版权 2024-2025 合肥瀚海量子科技有限公司

arguments
    moduleType kssolv.services.workflow.module.ModuleType
end

% 构建模块的包路径
modulePath = sprintf('kssolv.services.workflow.module.%s', lower(char(moduleType)));

% 获取模块的元信息 (meta.package)
try
    moduleMeta = meta.package.fromName(modulePath);

    % 如果模块不存在，返回空
    if isempty(moduleMeta)
        error('Module "%s" not found.', modulePath);
    end
catch
    error('Error loading module: %s', modulePath);
end

% 预分配 taskNames 和 classNames 的 cell 数组，根据类的数量预分配大小
numClasses = length(moduleMeta.ClassList);
taskNames = cell(1, numClasses);
classNames = cell(1, numClasses);
taskCount = 0;  % 用于计数有效的任务

% 遍历模块下的所有类
for i = 1:numClasses
    % 获取每个类的元信息
    classMeta = moduleMeta.ClassList(i);
    className = classMeta.Name;

    % 检查类名是否以 'Task' 结尾
    if endsWith(className, 'Task')
        try
            % 动态访问类的静态属性 TASK_NAME
            taskName = eval([className, '.TASK_NAME']);

            % 如果获取到 TASK_NAME，则增加计数并存储任务名和类名
            taskCount = taskCount + 1;
            taskNames{taskCount} = taskName;
            classNames{taskCount} = className;

        catch
            % 如果类没有 TASK_NAME 属性，发出警告
            warning('Class %s does not have a TASK_NAME property.', className);
        end
    end
end

% 去除空单元格，保留有效的任务名和类名
taskNames = taskNames(1:taskCount);
classNames = classNames(1:taskCount);
end
