function iconPath = GetIcon(iconName)
%GETICON 获取自定义 Icon 的绝对路径
%   使用示例：
%       import kssolv.ui.util.GetIcon
%       RemoteIconPath = GetIcon('refresh.png');
%
%   参数说明：
%   iconName 图标名称，包含后缀

%   开发者：杨柳、高俊
%   版权 2024-2025 合肥瀚海量子科技有限公司

arguments
    iconName {mustBeNonempty}
end

iconPath = fullfile(fileparts(fileparts(mfilename('fullpath'))), ...
    ['resources/icons/', iconName]);

