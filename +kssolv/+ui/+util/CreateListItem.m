function listitem = CreateListItem(parentname, itemname, tagPrefix, inputIcon)
    %CREATELISTITEM 创建 LISTIEM，并获取本地化选项名
    %   使用示例：
    %       FileProjectButtonPopup = PopupList();
    %       FileProjectButtonPopup_Open = CreateListItem('FileProject', 'Open', 'ProjectSection', Icon.ADD_16);
    %   参数说明：
    %   (1) 参数 parentname 规定为此 ListItem 所属的 Button 在创建时使用的 name 参数；
    %       如果该 ListItem 属于另一 ListItem，则 parentname 为
    %       父 ListItem 创建时使用的 itemname 参数.
    %   (2) 参数 inputIcon 指定图标；设置为 'none' 可创建不带有图标的条目.
    %
    %   开发者：林海饶
    %   版权 2024 合肥瀚海量子科技有限公司

import matlab.ui.internal.toolstrip.*
import kssolv.ui.util.Localizer.message
noicon = false;
label = message(['KSSOLV:toolbox:' parentname 'ButtonPopItem' itemname]);
if inputIcon == "none"
    noicon = true;
elseif class(inputIcon) == "matlab.ui.internal.toolstrip.Icon"
    icon = inputIcon;
elseif ischar(inputIcon) || isstring(inputIcon)
    icon = Icon(inputIcon);

else
    error('KSSOLV:CreatButton:inputIcon', 'Incorrect parameter data type.')
end
tag = [tagPrefix '_' itemname];

if noicon == true
    listitem = ListItem(label);
else
    listitem = ListItem(label, icon);
end
listitem.Tag = tag;
