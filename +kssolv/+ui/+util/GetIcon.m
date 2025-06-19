function iconPath = GetIcon(iconName, iconExt)
%GETICON 获取自定义 Icon 的绝对路径
%   使用示例：
%       import kssolv.ui.util.GetIcon
%       RemoteIconPath = GetIcon('remote', 'png');
%       RemoteIconPath = GetIcon('remote');
%
%   参数说明：
%   iconName 图标名称，不包含后缀；
%   iconExt  图标的后缀名，如 'png' 或 'jpg'，默认为 'png'；

%   开发者：高俊、杨柳
%   版权 2024 合肥瀚海量子科技有限公司

arguments
    iconName {mustBeNonempty}
    iconExt = 'png'
end

iconPath = fullfile(fileparts(fileparts(mfilename('fullpath'))), ...
    ['resources/icons/', iconName, '.', iconExt]);

