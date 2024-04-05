classdef Workflow < kssolv.services.filemanager.AbstractItem
    %WORKFLOW 定义了以".wf"为扩展名的 KSSOLV Toolbox 工作流类和相关操作函数
    %   开发者：杨柳
    %   版权 2024 合肥瀚海量子科技有限公司

    properties
        layout
        layoutJSON string
        editedNode
    end
    
    methods
        function obj = Workflow()
            %WORKFLOW 构造函数
            obj = obj@kssolv.services.filemanager.AbstractItem("Workflow", "Workflow");
        end
    end
end

