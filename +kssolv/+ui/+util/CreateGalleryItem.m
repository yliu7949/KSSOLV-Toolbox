function item = CreateGalleryItem(name, tagPrefix, inputIcon)
%CREATGALLERYITEM 创建不同形式的 GalleryItem 控件
%   使用示例：
%       import kssolv.ui.util.CreateGalleryItem
%       item = CreateGalleryItem('Import', 'PlotSection', Icon.IMPORT_24);

%   开发者：高俊、杨柳
%   版权 2024 合肥瀚海量子科技有限公司

import matlab.ui.internal.toolstrip.*
import kssolv.ui.util.Localizer.message

if class(inputIcon) == "matlab.ui.internal.toolstrip.Icon"
    icon = inputIcon;
elseif ischar(inputIcon)
    icon = Icon(inputIcon);
else
    error('KSSOLV:CreateGalleryItem:inputIcon', 'Incorrect parameter data type.')
end

tag = [tagPrefix '_' name];
label = message(['KSSOLV:toolbox:' name 'GalleryItemLabel']);
description = message(['KSSOLV:toolbox:' name 'GalleryItemTooltip']);

item = GalleryItem(label, icon);
item.Tag = tag;
item.Description = description;

