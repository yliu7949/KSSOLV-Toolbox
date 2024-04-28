function button = CreateButton(type, name, tagPrefix, inputIcon)
    %CREATEBUTTON 创建不同形式的 Button 控件
    %   使用示例：
    %       import kssolv.ui.util.CreateButton
    %       FileProjectButton = CreateButton('push', 'FileProject', 'ProjectSection', Icon.OPEN_24);
    %       FileProjectButton = CreateButton('split', 'FileProject', 'ProjectSection', 'openFolder');
    %       FileProjectButton = CreateButton('dropdown', 'FileProject', 'ProjectSection');
    % 
    %   参数说明：
    %   type 用于指定建立特定类型的 Button 控件；
    %   name 用于获取 Button 控件的 label 和 Description；
    %   tagPrefix 作为前缀和 name 一起确定 Button 控件的 Tag；
    %   inputIcon 用于指定控件的图标，可接受的参数类型如下：
    %       （1）未传入 inputIcon 参数，建立不带图标的 Button 控件；
    %       （2）字符数组，调用 CSS 类构建自定义图标；
    %       （3）Icon 中提供的标准图标，如 Icon.PLAY_24； 
    
    %   开发者：高俊
    %   版权 2024 合肥瀚海量子科技有限公司

arguments
    type
    name
    tagPrefix
    inputIcon = ""
end

import matlab.ui.internal.toolstrip.*
import kssolv.ui.util.Localizer.message

label = message(['KSSOLV:toolbox:' name 'ButtonLabel']);
if inputIcon == ""
    icon = '';
elseif class(inputIcon) == "matlab.ui.internal.toolstrip.Icon"
    icon = inputIcon;
elseif ischar(inputIcon)
    icon = Icon(inputIcon);
else
    error('KSSOLV:CreateButton:inputIcon', 'Incorrect parameter data type.')
end
description = message(['KSSOLV:toolbox:' name 'ButtonTooltip']);
tag = [tagPrefix '_' name];
switch type
    case 'push'
        button = Button(label, icon);
    case 'dropdown'
        button = DropDownButton(label, icon);
    case 'split'
        button = SplitButton(label, icon);
    case 'toggle'
        button = ToggleButton(label, icon);
end
button.Tag = tag;
button.Description = description; 

