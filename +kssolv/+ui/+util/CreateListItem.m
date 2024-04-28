function item = CreateListItem(type, name, tagPrefix, isDescription, inputIcon)
    %CREATELISTITEM 创建不同形式的 ListItem 控件
    %   使用示例：
    %       import kssolv.ui.util.CreateListItem
    %       OpenFileListItem = CreateListItem('default', 'OpenFile', 'ProjectSection', 1, Icon.ADD_16);
    %       OpenFileListItem = CreateListItem('popup', 'OpenFile', 'ProjectSection', 0, 'new');
    %       OpenFileListItem = CreateListItem('default', 'OpenFile', 'ProjectSection');
    % 
    %   参数说明：
    %   type 用于指定建立特定类型的 ListItem 控件；
    %   name 用于获取 ListItem 控件的 label 和 Description；
    %   tagPrefix 作为前缀和 name 一起确定 ListItem 控件的 Tag；
    %   isDescription 用于指定是否进行控件 Description 的获取和赋值；
    %   inputIcon 用于指定控件的图标，可接受的参数类型如下：
    %       （1）未传入 inputIcon 参数，建立不带图标的 ListItem 控件；
    %       （2）字符数组，调用 CSS 类构建自定义图标；
    %       （3）Icon 中提供的标准图标，如 Icon.ADD_16；       
     
    %   开发者：高俊、林海饶
    %   版权 2024 合肥瀚海量子科技有限公司

arguments
    type
    name
    tagPrefix
    isDescription = 0
    inputIcon = ""
end

import matlab.ui.internal.toolstrip.*
import kssolv.ui.util.Localizer.message

label = message(['KSSOLV:toolbox:' name 'ListItemLabel']);
if inputIcon == ""
    icon = '';
elseif class(inputIcon) == "matlab.ui.internal.toolstrip.Icon"
    icon = inputIcon;
elseif ischar(inputIcon)
    icon = Icon(inputIcon);
else
    error('KSSOLV:CreateListItem:inputIcon', 'Incorrect parameter data type.')
end
switch type
    case 'default'
        item = ListItem(label, icon);
    case 'popup'
        item = ListItemWithPopup(label, icon);
end
tag = [tagPrefix '_' name];
item.Tag = tag;

if isDescription
    description = message(['KSSOLV:toolbox:' name 'ListItemTooltip']);
    item.Description = description; 
end

