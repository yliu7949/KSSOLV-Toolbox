classdef CustomButton < matlab.ui.componentcontainer.ComponentContainer & ...
        matlab.ui.control.internal.model.mixin.IconIDableComponent & ...
        matlab.ui.control.internal.model.mixin.MultilineTextComponent & ...
        matlab.ui.control.internal.model.mixin.WordWrapComponent & ...
        matlab.ui.control.internal.model.mixin.ClickableComponent

    % CUSTOMBUTTON 自定义样式的无边框按钮组件，支持文字按钮和图标按钮。

    %   开发者：杨柳
    %   版权 2024 合肥瀚海量子科技有限公司

    properties
        Icon = ''
        AdditionalIcons = {}
        LayoutBackgroundColor = 'white'
        LayoutHorizontalAlignment {mustBeMember(LayoutHorizontalAlignment, {'flex-start', 'center', 'flex-end'})} = 'center'
    end

    properties (Access = private, Transient, NonCopyable)
        HTMLComponent matlab.ui.control.HTML % 内部的 uihtml 组件
        GridLayout matlab.ui.container.GridLayout % 网格布局

        IconURL
        IconType
        IconIndex = 0
        IconList
    end

    methods (Access = protected)
        function setup(this)
            % 初始化组件
            this.GridLayout = uigridlayout(this, [1, 1]);
            this.GridLayout.BackgroundColor = this.LayoutBackgroundColor;
            this.GridLayout.Padding = [0, 0, 0, 0];
            this.GridLayout.ColumnSpacing = 0;
            this.GridLayout.RowSpacing = 0;
            this.GridLayout.ColumnWidth = {'1x'};  % 自动适应列宽
            this.GridLayout.RowHeight = {'1x'};

            this.HTMLComponent = uihtml(this.GridLayout);
            this.HTMLComponent.HTMLEventReceivedFcn = @this.eventReceiver;
            this.refreshHTML();
        end

        function update(this)
            % 当属性变化时更新组件
            this.refreshHTML();
        end
    end

    methods
        function set.Icon(this, newValue)
            arguments
                this
                newValue (1, :) char
            end

            [pathName,fileName,fileExt] = fileparts(newValue);
            if ~isempty(fileName) && ~isempty(fileExt)
                % 检查文件类型是否有效
                if ismember(lower(fileExt(2:end)), {'svg','png','jpg','jpeg','gif'})
                    % 检查文件是否存在于路径中
                    if exist(newValue, 'file') == 2
                        % 打开文件读取
                        fid = fopen(newValue, 'r');
                        if (fid == -1)
                            % 无法读取文件时抛出错误
                            throwAsCaller(MException(message('MATLAB:ui:components:cannotReadIconFile', ...
                                strcat(fileName,fileExt))));
                        else
                            % 关闭已打开的文件
                            fclose(fid);
                            this.Icon = newValue;
                            this.set("privateIconType", 'file');
                            this.set("privateIconURL", [fullfile(pathName,fileName),fileExt]);
                            markPropertiesDirty(this, {'Icon'});
                        end

                    else
                        % 文件路径无效时抛出错误
                        throwAsCaller(MException(message('MATLAB:ui:components:invalidIconNotInPath', ...
                            strcat(fileName,fileExt))));
                    end
                else
                    % 无效文件格式时抛出错误
                    throwAsCaller(MException(message('MATLAB:ui:components:invalidIconFormat', ...
                        'png, jpg, jpeg, gif, svg')));
                end
            else
                iconsFolder = fullfile(matlabroot, "ui", "icons");
                registryJSON = fullfile(iconsFolder, "registry.json");

                % 若不是文件路径，读取 registry.json 文件
                if isfile(registryJSON)
                    % 读取 registry.json 文件
                    registryData = jsondecode(fileread(registryJSON));

                    % 判断是否存在与 this.IconURL 相同的键名
                    if isfield(registryData, newValue)
                        this.Icon = newValue;
                        this.set("IconType", 'preset');
                        this.set("IconURL", fullfile(iconsFolder, registryData.(newValue){1}, newValue + ".svg"));
                        markPropertiesDirty(this, {'Icon'});
                    else
                        % 若 registry.json 中无匹配的键名
                        error('Icon does not match any entry in the registry.');
                    end
                else
                    % 若 registry.json 文件不存在
                    error('Registry file not found: %s', registryJSON);
                end
            end
        end

        function set.LayoutBackgroundColor(this, newValue)
            this.LayoutBackgroundColor = newValue;
            gridLayout = this.get("GridLayout");
            gridLayout.BackgroundColor = newValue;
        end
    end

    methods (Access = private)
        function eventReceiver(this, ~, event)
            switch event.HTMLEventName
                case 'ButtonClicked'
                    % 如果有 AdditionalIcons，则每次点击时依次切换 AdditionalIcons 中的图标
                    if ~isempty(this.AdditionalIcons)
                        this.IconIndex = mod(this.IconIndex, length(this.AdditionalIcons)) + 1;
                        this.Icon = this.AdditionalIcons{this.IconIndex}; 
                    end

                    % 执行用户定义的 ClickedFcn 函数
                    if ~isempty(this.ClickedFcn)
                        this.ClickedFcn();
                    end
            end
        end

        function refreshHTML(this)
            % 生成并设置 HTML 内容
            htmlContent = this.generateHTML();
            this.HTMLComponent.HTMLSource = htmlContent;
        end

        function html = generateHTML(this)
            % 生成按钮的 HTML、CSS 和 JavaScript 内容

            % CSS 样式
            if isempty(this.IconID) || isempty(fieldnames(this.IconID))
                imgWidth = '100%';
            else
                imgWidth = sprintf('%dpx', this.IconID.width);
            end
            cssStyles = {
                '<style>'
                'html, body {'
                '   height: 100%;'
                '   margin: 0;'
                '}'
                'body {'
                '   background-color: transparent;'
                '   display: flex;'
                sprintf('   justify-content: %s;', this.LayoutHorizontalAlignment)
                '}'
                '.custom-button {'
                '   border: 1px solid transparent;'  % 默认透明边框
                '   background-color: transparent;'
                '   padding: 3px;'
                '   cursor: pointer;'
                '   font-size: 14px;'
                '   display: inline-flex;'
                '   align-items: center;'
                '   justify-content: center;'
                '   user-select: none;'
                '   max-width: 100%;'
                '   max-height: 100%;'
                '}'
                '.custom-button:hover {'
                '   background-color: #ffffff;'
                '   border-color: #7d7d7d;' % 悬浮时改变边框颜色
                '   border-radius: 4px;'
                '}'
                '.custom-button:focus {'
                '   outline: none;'
                '   border-color: #478ad7;' % 聚焦时改变边框颜色
                '   border-radius: 4px;'
                '}'
                '.custom-button:active {'
                '   background-color: #d9d9d9;'
                '   border-color: #007ACC;'
                '   border-radius: 4px;'
                '}'
                '.custom-button img {'
                sprintf('   width: %s;', imgWidth)
                '   height: auto;'
                '}'
                '.custom-button svg {'
                sprintf('   width: %s;', imgWidth)
                '   height: auto;'
                '   max-width: 24px;'
                '   max-height: 24px;'
                '}'
                '</style>'
                };

            % 将 cssStyles 转换为字符串
            cssStylesString = strjoin(cssStyles, '\n');

            % 按钮类型
            if isempty(this.Icon)
                % 纯文字按钮
                buttonHTML = sprintf('<button class="custom-button">%s</button>', this.Text);
            else
                % 图标按钮
                if strcmp(this.IconType, "preset")
                    svgContent = fileread(this.IconURL);
                    buttonHTML = sprintf(...
                        '<button class="custom-button">%s%s</button>', ...
                        svgContent, this.Text);
                else
                    buttonHTML = sprintf(...
                        '<button class="custom-button"><img src="%s" alt="Icon">%s</button>', ...
                        this.IconURL, this.Text);
                end
            end

            % JavaScript 脚本
            jsScript = {
                '<script type="text/javascript">'
                '    // MATLAB 执行此设置函数'
                '    function setup(htmlComponent) {'
                '       let button = document.querySelector(".custom-button");'
                '       button.addEventListener("click", () => {'
                '           htmlComponent.sendEventToMATLAB("ButtonClicked", 1);'
                '       });'
                '       button.addEventListener("mousedown", () => {'
                '           button.focus();'
                '       });'
                '    }'
                '</script>'
                };

            % 将 jsScript 转换为字符串
            jsScriptStr = strjoin(jsScript, '\n');

            % 组合所有内容
            htmlTemplate = {
                '<!DOCTYPE html>'
                '<html lang="zh-CN">'
                '<head>'
                '    <meta charset="UTF-8">'
                '    <title>Custom Button</title>'
                cssStylesString
                '</head>'
                '<body>'
                '<div>'
                buttonHTML
                '</div>'
                ''
                jsScriptStr
                '</body>'
                '</html>'
                };
            html = strjoin(htmlTemplate, '\n');
        end
    end

    methods (Hidden)
        function markPropertiesDirty(this, propertyNames)
            arguments
                this
                propertyNames cell
            end

            if size(propertyNames, 1) == 1
                switch propertyNames{1, 1}
                    case 'IconID'
                        if ~isempty(fieldnames(this.IconID))
                            this.Icon = this.IconID.id;
                        end
                    case 'Icon'
                    case 'ClickedFcn'
                end
            end
        end

        function htmlContent = exportHTML(this)
            htmlContent = this.generateHTML();
        end
    end

    methods (Hidden, Static)
        function button1 = qeShow()
            % 用于单元测试中的 CustomButton 示例，可使用以下命令：
            % kssolv.ui.components.custom.CustomButton.qeShow();

            % 判断是否存在名为 "Unit Test" 的窗口
            existingFig = findall(0, 'Type', 'figure', 'Name', 'Unit Test');
            if ~isempty(existingFig)
                % 如果存在则关闭窗口
                close(existingFig);
            end

            % 创建画布和面板
            fig = uifigure("Name", "Unit Test");
            layout = uigridlayout(fig);
            layout.ColumnWidth = {'1x', '1x'};
            layout.RowHeight = {'1x', '1x'};

            % 将 CustomButton 添加到画布
            button1 = kssolv.ui.components.custom.CustomButton(layout);
            button1.Text = "Test";

            button1 = kssolv.ui.components.custom.CustomButton(layout);
            button1.ClickedFcn = @() disp('YES');
            matlab.ui.control.internal.specifyIconID(button1, 'webBrowserUI', 24);

            button1 = kssolv.ui.components.custom.CustomButton(layout);
            button1.LayoutHorizontalAlignment = "flex-start";
            button1.Text = '<b style="font-size:12px">&nbsp;Title</b>';
            button1.AdditionalIcons = {'treeExpandUI', 'treeCollapseUI'};
            matlab.ui.control.internal.specifyIconID(button1, 'treeCollapseUI', 8);
            disp(button1.generateHTML);

            button1 = kssolv.ui.components.custom.CustomButton(layout);
            button1.LayoutHorizontalAlignment = "flex-end";
            button1.Text = "&nbsp;Title";
            button1.AdditionalIcons = {'treeCollapseUI', 'treeExpandUI'};
            matlab.ui.control.internal.specifyIconID(button1, 'treeExpandUI', 8);
        end
    end
end
