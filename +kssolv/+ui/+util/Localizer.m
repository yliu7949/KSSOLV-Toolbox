classdef Localizer < handle
    %LOCALIZER 本地化管理器，根据 Identifier 获取 resources 路径下相应的本地化翻译
    %   参考链接：
    %       https://ww2.mathworks.cn/matlabcentral/answers/373512-how-can-i-open-message-key-catalog#answer_296850
    %   使用示例：
    %   （1）导入本类：
    %       import kssolv.ui.util.Localizer.*
    %   （2）使用本类的 message 函数获取与 Identifier 对应的本地化翻译，Identifier 
    %       的格式为："KSSOLV:<XML 无后缀文件名>:<XML 文件 entry 条目中的 Key>"。
    %       例如：
    %       message('KSSOLV:toolbox:WelcomeMessage')
    %
    %   开发者：杨柳
    %   版权 2024 合肥瀚海量子科技有限公司
    properties (Access = private)
        % 键：Identifier，值：对应的本地化翻译
        keyValueMap containers.Map
        % 上一次读取 XML 文件时使用的 locale
        currentLocale
    end

    methods (Access = private)
        function this = Localizer(locale)
            % 构造函数，私有化以实现单例模式
            % 获取本地化设置，如 zh_CN
            this.currentLocale = locale;
            % 本地化文件夹的位置：+kssolv/+ui/resources/locales/${locale}
            resourceFolder = fullfile(fileparts(fileparts(mfilename('fullpath'))), 'resources');
            localeFolder = fullfile(resourceFolder, 'locales', locale);
            if exist(localeFolder, 'dir')
                % 读取该本地化文件夹下所有 XML 文件，并全部缓存到 keyValueMap 中
                xmlFiles = dir(fullfile(localeFolder, '*.xml'));
                this.keyValueMap = containers.Map('KeyType', 'char', 'ValueType', 'char');
                for i = 1:length(xmlFiles)
                    xmlFilePath = fullfile(xmlFiles(i).folder, xmlFiles(i).name);
                    xmlFileName = split(xmlFiles(i).name, '.');
                    xmlFileName = xmlFileName{1, 1};
                    this.keyValueMap = [this.keyValueMap; this.readXmlFile(xmlFilePath, xmlFileName)];
                end
            else
                error('KSSOLV:Localizer:ResourceFolderNotFound', 'Resources folder not found.');
            end
        end

        function keyValueMap = readXmlFile(~, xmlFilePath, fileName)
            % 读取 XML 文件并将内容转换为键值对集合
            xDoc = xmlread(xmlFilePath);
            allEntries = xDoc.getElementsByTagName('entry');
            keyValueMap = containers.Map('KeyType', 'char', 'ValueType', 'char');
            for k = 0:allEntries.getLength-1
                thisEntry = allEntries.item(k);
                key = ['KSSOLV:', fileName, ':', char(thisEntry.getAttribute('key'))];
                value = char(thisEntry.getTextContent());
                keyValueMap(key) = value;
            end
        end
    end

    methods (Static, Access = public)
        function instance = getInstance(varargin)
            % 返回类的唯一实例
            narginchk(0, 1);
            persistent userLocale
            if isempty(userLocale)
                temp = feature('locale').messages;
                temp = split(temp, '.');
                userLocale = temp{1, 1};
            end

            persistent uniqueInstance
            if nargin == 0
                % 无输入参数，则尝试直接返回当前非空的 uniqueInstance 实例
                if ~isempty(uniqueInstance)
                    instance = uniqueInstance;
                    return
                else
                    % 若 uniqueInstance 为空，则需要使用构造函数构造实例
                    locale = userLocale;
                end
            elseif isempty(varargin{1})
                % 若输入参数为 ""，则指定 locale 为 MATLAB 正在使用的界面语言
                locale = userLocale;
            else
                locale = varargin{1};
            end

            if isempty(uniqueInstance) || ~strcmp(locale, uniqueInstance.currentLocale)
                % 重载所有的本地化 XML 文件
                uniqueInstance = kssolv.ui.util.Localizer(locale);
            end
            instance = uniqueInstance;
        end

        function setLocale(locale)
            % 手动指定 locale
            kssolv.ui.util.Localizer.getInstance(locale);
        end

        function msg = message(key)
            % 返回给定键的本地化字符串
            instance = kssolv.ui.util.Localizer.getInstance();
            if isKey(instance.keyValueMap, key)
                msg = instance.keyValueMap(key);
            else
                % 未找到键时的默认行为
                error('KSSOLV:Localizer:KeyNotFound', 'Key not found.');
            end
        end
    end
end

