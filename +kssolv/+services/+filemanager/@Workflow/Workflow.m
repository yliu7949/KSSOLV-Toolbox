classdef Workflow < kssolv.services.filemanager.AbstractItem
    %WORKFLOW 定义了以".wf"为扩展名的 KSSOLV Toolbox 工作流类和相关操作函数

    %   开发者：杨柳
    %   版权 2024 合肥瀚海量子科技有限公司

    properties (Hidden)
        layout struct
        layoutJSON string
        editedNode
    end
    
    methods
        function this = Workflow(label, type)
            %WORKFLOW 构造函数
            arguments
                label string = "Workflow"
                type string = "Workflow"
            end
            this = this@kssolv.services.filemanager.AbstractItem(label, type);
            % nodes 列表存储 UI 层的 node 类，每个 node 类包含 panel 和 code
            % workflowTree 是一个 n*2 的元胞数组，存储 node 名以表示工作流的执行顺序
            this.data = struct("nodes", [], "workflowTree", cell(0,2));
        end

        function updateLayoutJSON(this, newJSON)
            % 更新
            this.layoutJSON = newJSON;
            try
                this.layout = jsondecode(newJSON);
            catch ME
                error('KSSOLV:FileManager:Workflow:LayoutJSONDecodeError', ...
                      'Error decoding the JSON from Workflow component: %s', ME.message);
            end
        end
    end
end

