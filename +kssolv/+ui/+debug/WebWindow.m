classdef WebWindow < handle
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

