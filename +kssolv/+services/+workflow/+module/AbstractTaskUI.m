classdef (Abstract) AbstractTaskUI < matlab.mixin.SetGet
    %ABSTRACTTASKUI Summary of this class goes here
    
    properties
        options
    end

    methods (Access = protected)
        function this = AbstractTaskUI(accordion)
            arguments
                accordion matlab.ui.container.internal.Accordion
            end
            this.setup(accordion);
        end
    end
    
    methods (Abstract)
        setup(this, accordion)
    end

    methods (Hidden, Static)
        function accordion = qeShow(debug)
            arguments
                debug logical = false
            end
            % 用于在单元测试中测试 TaskUI

            % 判断是否存在名为 "Unit Test" 的窗口
            existingFig = findall(0, 'Type', 'figure', 'Name', 'Unit Test');
            if ~isempty(existingFig)
                % 如果存在则关闭窗口
                close(existingFig);
            end

            % 创建画布和面板
            fig = uifigure("Name", "Unit Test");
            fig.Position(3) = 300;
            fig.Position(4) = 600;
            layout = uigridlayout(fig);
            layout.ColumnSpacing = 0;
            layout.RowSpacing = 0;
            layout.ColumnWidth = {'1x'};
            layout.RowHeight = {'1x'};

            accordion = matlab.ui.container.internal.Accordion('Parent', layout);

            if debug
                pause(2);
                webWindow = struct(struct(struct(fig).Controller).PlatformHost).CEF;
                webWindow.openDevTools();
            end
        end
    end
end

