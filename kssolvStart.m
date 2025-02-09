function app = kssolvStart(ksFile, hostInBrowser)
%KSSOLVSTART 启动 KSSOLV 图形用户界面
%
% 该函数会展示图形用户界面并阻塞主进程，直到界面关闭。
% 用于编译独立应用程序时作为程序的主入口，以保持界面的持续显示。

arguments
    ksFile string = ""
    hostInBrowser (1, 1) logical = strcmpi(getenv("HostAppInBrowser"), 'true')
end

app = kssolv(ksFile, hostInBrowser);

while true
    pause(0.5);
    if ~isvalid(app) || ~app.AppContainer.Visible
        if nargout == 0
            clear app
        end
        return
    end
end
end

