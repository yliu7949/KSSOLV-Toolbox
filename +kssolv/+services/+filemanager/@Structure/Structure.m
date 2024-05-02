classdef Structure < kssolv.services.filemanager.AbstractItem
    %STRUCTURE 定义了KSSOLV Toolbox 结构类和相关操作函数

    %   开发者：杨柳
    %   版权 2024 合肥瀚海量子科技有限公司
    
    methods
        function this = Structure(label)
            %STRUCTURE 构造函数
            arguments
                label string = "Structure"
            end
            this = this@kssolv.services.filemanager.AbstractItem(label, "Structure");
        end
        
        function showMoleculerDisplay(this)
            % 使用 Data 数据中的文件路径以打开对应结构的渲染界面
            kssolv.ui.components.figuredocument.MoleculerDisplay(this.Data.filePath).Display();
        end
    end
end

