classdef BlankTaskUI < kssolv.services.workflow.module.AbstractTaskUI
    %BLANKTASKUI 空白的任务 UI 类

    %   开发者：杨柳
    %   版权 2024-2025 合肥瀚海量子科技有限公司

    properties (Dependent)
        options
    end

    properties (Transient)
        widgets
    end

    methods (Access = protected)
        function setupDefaultOptions(~)
        end
        function setup(~, ~)
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

        function output = get.options(this)
            % 获取控件对应的值
            this.privateOptions = struct();
            output = this.privateOptions;
        end
    end
end

