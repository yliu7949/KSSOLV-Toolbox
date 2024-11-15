classdef BlankTaskUI
    %BLANKTASKUI 空白的任务 UI 类

    properties (Dependent)
        options
    end

    properties
        widgets
    end

    methods (Access = protected)
        function setup(~)
        end
    end

    methods
        function attachUIToAccordion(~, accordion)
            arguments
                ~
                accordion matlab.ui.container.internal.Accordion
            end

            if size(accordion.Children, 1) >= 4
                if accordion.Children(3).Title == "Options"
                    % 移除旧的 Options AccordionPanel
                    accordion.Children(3).Parent = [];
                end

                if accordion.Children(3).Title == "Advanced Options"
                    % 移除旧的 Advanced Options AccordionPanel，注意在 Children 中的位置仍然是第三个
                    accordion.Children(3).Parent = [];
                end
            end
        end

        function detachUIFromAccordion(~)
        end

        function output = get.options(~)
            % 获取控件对应的值
            output = struct.empty;
        end
    end
end

