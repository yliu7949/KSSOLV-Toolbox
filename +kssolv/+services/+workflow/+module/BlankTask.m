classdef BlankTask < kssolv.services.workflow.module.AbstractTask
    %BLANKTASK 空白的任务类

    properties (Constant)
        TASK_NAME = '';
        DESCRIPTION = '';
    end

    methods
        function setup(~)
            % 保持函数体为空
        end

        function setModuleType(this, moduleType)
            arguments
                this 
                moduleType kssolv.services.workflow.module.ModuleType
            end
            this.module = moduleType;
        end

        function getOptionsUI(~, accordion)
            % 该 Task 没有 options 选项，因此不提供 Options UI
            arguments
                ~
                accordion matlab.ui.container.internal.Accordion
            end

            if size(accordion.Children, 1) >= 4
                if accordion.Children(3).Title == "Options"
                    % 删除旧的 Options AccordionPanel
                    delete(accordion.Children(3));
                end

                if accordion.Children(3).Title == "Advanced Options"
                    % 删除旧的 Advanced Options AccordionPanel，注意在 Children 中的位置仍然是第三个
                    delete(accordion.Children(3));
                end
            end
        end
    end
end

