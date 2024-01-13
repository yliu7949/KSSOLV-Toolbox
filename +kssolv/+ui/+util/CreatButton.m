function button = CreatButton(type,name,tag_prefix,icon0)
    %KSSOLVTOOLBOX 的工具类函数 用于创建不同形式的 Button 控件，这些控件主要被添加到Tab下的Column中； 
    %   开发者：高俊
    %   版权 2024 合肥瀚海量子科技有限公司

import matlab.ui.internal.toolstrip.*
import kssolv.ui.util.Localizer.message
label = message(['KSSOLV:toolbox:' name 'ButtonLabel']);
if class(icon0) == "matlab.ui.internal.toolstrip.Icon"
    icon = icon0;
elseif ischar(icon0) || isstring(icon0)
    icon = Icon(icon0);
else
    error('KSSOLV:CreatButton:icon0', 'Incorrect parameter data type.')
end
description = message(['KSSOLV:toolbox:' name 'ButtonTooltip']);
tag = [tag_prefix '_' name];
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
