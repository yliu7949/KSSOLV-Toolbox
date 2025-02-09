classdef WebWindow < handle
    properties
        webWindow matlab.internal.webwindow
    end

    methods
        function webWindow = getWebWindow(this)
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
end

