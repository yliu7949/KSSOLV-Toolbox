function item = CreatGalleryItem(name, tagPrefix, inputIcon)
    %CREATGALLERYITEM 创建不同形式的 GalleryItem 控件
    %   使用示例：
    %       import kssolv.ui.util.CreatGalleryItem
    %       item = CreatGalleryItem('Import', 'PlotSection', Icon.IMPORT_24);
    % 
    %   开发者：高俊
    %   版权 2024 合肥瀚海量子科技有限公司

import matlab.ui.internal.toolstrip.*
import kssolv.ui.util.Localizer.message
label = message(['KSSOLV:toolbox:' name 'GalleryItemLabel']);
if class(inputIcon) == "matlab.ui.internal.toolstrip.Icon"
    icon = inputIcon;
elseif ischar(inputIcon) || isstring(inputIcon)
    icon = Icon(inputIcon);
else
    error('KSSOLV:CreatGalleryItem:inputIcon', 'Incorrect parameter data type.')
end
description = message(['KSSOLV:toolbox:' name 'GalleryItemTooltip']);
tag = [tagPrefix '_' name];
item = GalleryItem(label, icon);
item.Tag = tag;
item.Description = description; 
