classdef TogglePanel < matlab.ui.componentcontainer.ComponentContainer
    %TOGGLEPANEL 一个简单的可折叠面板组件，带有最小化功能
    
    properties
        Title = 'Toggle Panel'   % 面板的标题
        Minimized = false        % 表示面板是否最小化的布尔值
        MinimizeFcn = function_handle.empty()  % 最小化回调函数
    end
    
    properties(Access = private, Transient, NonCopyable)
        GridLayout       matlab.ui.container.GridLayout % 网格布局
        TitleLabel       matlab.ui.control.Label        % 标题文本标签（模拟按钮）
        ContentPanel     matlab.ui.container.Panel      % 内容面板
    end
    
    properties(Access = private)
        ContentHeight = 100 % 展开时内容面板的高度
    end
    
    methods(Access = protected)
        function setup(this)
            % 设置组件
            
            % 创建用于面板的网格布局
            this.GridLayout = uigridlayout(this, [2, 1]);
            this.GridLayout.RowHeight = {'fit', this.ContentHeight}; % 调整行高
            this.GridLayout.ColumnWidth = {'1x'};
            this.GridLayout.Padding = [0 0 0 0]; % 取消网格布局的边框
            
            % 创建标题标签，模拟按钮效果
            this.TitleLabel = uilabel(this.GridLayout, ...
                'Text', ['▼ ' this.Title], ...
                'FontColor', [0 0 0], ...        % 黑色字体
                'BackgroundColor', 'none', ...   % 无边框效果
                'HorizontalAlignment', 'left', ...
                'FontSize', 14, ...
                'FontWeight', 'bold');
            this.TitleLabel.Layout.Row = 1;
            this.TitleLabel.Layout.Column = 1;
            
            % 设置点击事件，用于折叠/展开内容
            this.TitleLabel.ButtonDownFcn = @(src, event) toggleContent(this);
            
            % 创建内容面板
            this.ContentPanel = uipanel(this.GridLayout);
            this.ContentPanel.Layout.Row = 2;
            this.ContentPanel.Layout.Column = 1;
            this.ContentPanel.BackgroundColor = [0.95 0.95 0.95];
            
            % 添加自定义UI组件到内容面板（此处为示例内容）
            uilabel(this.ContentPanel, 'Text', '这里是内容区域。');
        end
        
        function update(this)
            % 更新组件显示（例如调整大小时）
            % 根据 Minimized 属性调整面板显示状态
            if this.Minimized
                this.GridLayout.RowHeight{2} = 0;  % 折叠内容
                this.TitleLabel.Text = ['► ' this.Title];  % 更新箭头指向和标题
                this.TitleLabel.FontColor = [0.5 0.5 0.5]; % 灰色箭头
            else
                this.GridLayout.RowHeight{2} = this.ContentHeight;  % 展开内容
                this.TitleLabel.Text = ['▼ ' this.Title];  % 更新箭头指向和标题
                this.TitleLabel.FontColor = [0.5 0.5 0.5]; % 灰色箭头
            end
        end
    end
    
    methods
        function set.Minimized(this, value)
            % 设置 Minimized 属性并切换内容显示
            if islogical(value) && isscalar(value)
                this.Minimized = value;
                this.update();  % 更新UI以反映新的状态
                
                % 如果定义了 MinimizeFcn，则触发该回调函数
                if ~isempty(this.MinimizeFcn)
                    this.MinimizeFcn(this);  % 调用回调函数
                end
            else
                error('Minimized 属性必须为逻辑标量。');
            end
        end
    end
    
    methods(Access = private)
        function toggleContent(this)
            % 切换内容的可见性（折叠/展开），并设置 Minimized 状态
            this.Minimized = ~this.Minimized;  % 切换 Minimized 属性
        end
    end
end
