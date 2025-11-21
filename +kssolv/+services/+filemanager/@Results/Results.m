classdef Results < kssolv.services.filemanager.AbstractItem
    %RESULTS 定义了 KSSOLV Toolbox 的计算结果类和相关操作函数

    %   开发者：杨柳
    %   版权 2025 合肥瀚海量子科技有限公司

    properties (Hidden)
        datasetsItem
        plotsItem
    end

    methods
        function this = Results(label, type)
            %RESULTS 构造函数
            arguments
                label string = "Results"
                type string = "Results"
            end
            this = this@kssolv.services.filemanager.AbstractItem(label, type);

            this.datasetsItem = kssolv.services.filemanager.AbstractItem('Datasets', 'Folder');
            this.addChildrenItem(this.datasetsItem);
            this.plotsItem = kssolv.services.filemanager.AbstractItem('Plots', 'Folder');
            this.addChildrenItem(this.plotsItem);
        end

        function addDataset(this, data, workflowLabel)
            % 将运行计算工作流得到的输出作为 Dataset 存入 Project/Results 下
            arguments
                this
                data (:, 1) {mustBeNonempty}
                workflowLabel = 'Default'
            end

            datasetItem = kssolv.services.filemanager.AbstractItem('Dataset', 'Dataset');
            datasetItem.data = data;
            datasetItem.label = sprintf('Run %s', workflowLabel);
            this.datasetsItem.addChildrenItem(datasetItem);
        end

        function tag = addPlot(this, figure, plotLabel)
            % 将可视化任务得到的 Figure 存入 Project/Results 下
            arguments
                this
                figure (:, 1) {mustBeNonempty}
                plotLabel = 'Figure'
            end

            plotItem = kssolv.services.filemanager.AbstractItem('Plot', 'Plot');
            plotItem.data = figure;
            plotItem.label = plotLabel;
            this.plotsItem.addChildrenItem(plotItem);
            tag = plotItem.name;
        end
    end

    methods (Static)
        function resultsItem = getResultsItem()
            project = kssolv.ui.util.DataStorage.getData('Project');
            resultsItem = project.findChildrenItem('Results');
        end
    end
end

