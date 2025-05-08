classdef CommandWindow < matlab.ui.internal.databrowser.AbstractDataBrowser
    %COMMANDWINDOW 自定义的 Data Browser 组件，存放命令行窗口相关控件

    % 开发者：杨柳
    % 版权 2025 合肥瀚海量子科技有限公司

    properties
        Widgets % 小组件
        ChatBot % 对话机器人
    end

    methods
        function this = CommandWindow()
            %COMMANDWINDOW 构造此类的实例
            title = kssolv.ui.util.Localizer.message('KSSOLV:toolbox:CommandWindowTitle');
            % 调用超类构造函数
            this = this@matlab.ui.internal.databrowser.AbstractDataBrowser('CommandWindow', title);
            % 自定义 widget 和 layout
            buildUI(this);
            % 设定 FigurePanel 的 Tag
            this.Panel.Tag = 'CommandWindow';
            % 设定合适的高度
            this.Panel.PreferredHeight = 280;
            % 将该 Browser 放在界面右侧
            this.Panel.Region = "bottom";

            % 构造对话机器人
            this.ChatBot = kssolv.services.llm.ollama.ChatBot("qwen2.5:7b", '', ...
                    @(tokens) this.addChat(tokens));
        end
    end

    methods (Static)
        generateCommandReferences()
    end

    methods (Access = protected)
        function buildUI(this)
            fig = this.Figure;
            g = uigridlayout(fig);
            g.BackgroundColor = "white";
            g.Padding = [0 0 0 0];
            g.RowHeight = {'1x'};
            g.ColumnWidth = {'1x'};

            htmlFile = fullfile(fileparts(mfilename('fullpath')), 'html', 'index.html');

            h = uihtml(g, "HTMLSource", htmlFile);
            this.Widgets.html = h;

            % 向 html 组件传递参考命令列表以供自动补全
            this.readCommandReferencesFile()

            % 接收从 HTML 组件触发的事件
            h.HTMLEventReceivedFcn = @this.eventReceiver;
        end
    end

    methods (Access = private)
        function readCommandReferencesFile(this)
            % 逐行读取 commandReferences.txt 文件中的 MATLAB 命令列表
            currentFolder = fileparts(mfilename('fullpath'));
            commandReferencesFile = fullfile(currentFolder, 'html', 'commandReferences.txt');

            fileID = fopen(commandReferencesFile, 'r');
            if fileID == -1
                warning('文件无法打开: %s', commandReferencesFile);
            end

            % 初始化一个空的 cell 数组来存储每一行
            data = {};

            % 逐行读取文件并将每一行存储到 h.Data 中
            lineIndex = 1;
            while ~feof(fileID)
                line = fgetl(fileID);
                if ischar(line)
                    data{lineIndex} = line; %#ok<AGROW>
                    lineIndex = lineIndex + 1;
                end
            end

            fclose(fileID);
            this.Widgets.html.Data = data;
        end

        function addChat(this, content)
            %ADDCHAT 向 html 组件流式更新 tokens
            % content = replace(content, newline, " <br>");
            this.Widgets.html.sendEventToHTMLSource('TokensStreamed', content);
            drawnow
        end

        function eventReceiver(this, src, event)
            switch event.HTMLEventName
                case 'CommandSubmitted'
                    this.callbackCommandSubmitted(src, event);
                case 'UserPromptSubmitted'
                    this.callbackUserPromptSubmitted(src, event);
            end
        end

        function callbackCommandSubmitted(this, ~, event)
            % 执行命令行窗口提交的命令
            command = event.HTMLEventData;

            if isempty(command)
                % 如果命令为空则直接回复空白
                this.Widgets.html.sendEventToHTMLSource('ResultUpdated', '');
                return
            end

            % 在函数工作区内预置持久变量 ANS，可简化上一次计算结果的使用
            persistent ANS %#ok<NUSED>

            try
                output = evalc('base', command); %#ok<EVLC>
            catch ME
                output = ME.message;
            end

            this.Widgets.html.sendEventToHTMLSource('ResultUpdated', output);
        end

        function callbackUserPromptSubmitted(this, ~, event)
            % 执行命令行窗口提交的用户提示词
            userPrompt = event.HTMLEventData;
            this.ChatBot.chat(userPrompt.prompt, userPrompt.useHistory);
        end
    end

    methods (Hidden)
        function app = qeShow(this)
            % 用于在单元测试中测试 CommandWindow
            % 示例命令：
            % cw = kssolv.ui.components.databrowser.CommandWindow();
            % cw.qeShow()

            % 创建 AppContainer
            appOptions.Tag = sprintf('kssolv(%s)', char(matlab.lang.internal.uuid));
            appOptions.Title = kssolv.ui.util.Localizer.message('KSSOLV:toolbox:UnitTestTitle');
            appOptions.ToolstripEnabled = true;
            app = matlab.ui.container.internal.AppContainer(appOptions);

            % 保存 AppContainer 至 DataStorage
            kssolv.ui.util.DataStorage.setData('AppContainer', app);

            % 将 CommandWindow 添加到 App Container
            this.addToAppContainer(app);
            % 展示界面
            app.Visible = true;
        end
    end
end
