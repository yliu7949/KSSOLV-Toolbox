classdef WebWindow < handle
    %WEBWINDOW 获取当前 AppContainer 的 webWindow 用于界面调试

    % 开发者：杨柳
    % 版权 2025 合肥瀚海量子科技有限公司

    properties
        webWindow matlab.internal.webwindow
    end

    methods
        function webWindow = get.webWindow(this)
            arguments (Output)
                webWindow matlab.internal.webwindow
            end

            appContainer = kssolv.ui.util.DataStorage.getData('AppContainer');
            if isempty(appContainer)
                return
            end

            % Reference: https://ww2.mathworks.cn/matlabcentral/fileexchange/131274-cctools
            warning('off', 'MATLAB:structOnObject');

            webWindow = struct(appContainer).Window;
            this.webWindow = webWindow;
        end
    end

    methods (Static)
        function openDevTools()
            webWindow = kssolv.ui.debug.WebWindow().webWindow;

            if ~isempty(webWindow)
                webWindow.openDevTools();
            end
        end
    end
end

