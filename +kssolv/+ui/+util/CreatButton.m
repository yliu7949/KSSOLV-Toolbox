function button = CreatButton(type, name, tagPrefix, inputIcon)
    %CREATBUTTON 创建不同形式的 Button 控件
    %   使用示例：
    %       import kssolv.ui.util.CreatButton
    %       ProjectOpenButton = CreatButton('push', 'ProjectOpen', 'ProjectSection', Icon.OPEN_24);
    % 
    %   开发者：高俊
    %   版权 2024 合肥瀚海量子科技有限公司

import matlab.ui.internal.toolstrip.*
import kssolv.ui.util.Localizer.message
label = message(['KSSOLV:toolbox:' name 'ButtonLabel']);
if class(inputIcon) == "matlab.ui.internal.toolstrip.Icon"
    icon = inputIcon;
elseif ischar(inputIcon) || isstring(inputIcon)
    icon = Icon(inputIcon);
else
    error('KSSOLV:CreatButton:inputIcon', 'Incorrect parameter data type.')
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
