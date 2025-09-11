classdef BandProcessingTask < kssolv.services.workflow.module.AbstractTask
    %BANDPROCESSINGTASK 二维能带计算任务

    %   开发者：杨柳
    %   版权 2025 合肥瀚海量子科技有限公司

    properties (Constant)
        TASK_NAME = 'Band Calculation'
        IDENTIFIER = 'BandProcessingTask'
        DESCRIPTION = 'K-point path interpolation and NSCF calculation'
    end

    methods (Access = protected)
        function this = setup(this)
            this.module = kssolv.services.workflow.module.ModuleType.Postprocessing;
            this.requiredTasks = ['SymmetryAnalysisTask', 'SCFTask', 'NSCFTask'];
            this.supportGPU = false;
            this.supportParallel = false;
        end
    end

    methods
        function setupOptionsUI(this)
            this.optionsUI = kssolv.services.workflow.module.postprocessing.BandProcessingTaskUI();
        end

        function output = executeTask(this, ~, input)
            if isempty(this.optionsUI)
                return
            end
            taskOptions = this.optionsUI.options;

            symmetryResult = input.symmetry;
            %{
            for i = 1:size(symmetryResult.path, 1)
                p1 = symmetryResult.path{i, 1};
                p2 = symmetryResult.path{i, 2};
                fprintf('   %s -- %s: %s -- %s\n', p1, p2, ...
                    mat2str(symmetryResult.point_coords(p1), 3), mat2str(symmetryResult.point_coords(p2), 3));
            end
            %}

            kPoints = generateKPoints(symmetryResult, taskOptions.numInterpolationPoints);

            output = input;
            output.NSCFOptions.rho0 = input.H.rho;
            output.bandProcessing.kPoints = kPoints;
            output.bandProcessing.energyBands = eband(input.molecule, output.NSCFOptions, kPoints);
        end
    end
end

function symmetryKPoints = generateKPoints(symmetryResult, numInterpolationPoints)
index = 1;
symmetryKPoints = cell(2 * size(symmetryResult.path, 1), 5);

for i = 1:size(symmetryResult.path, 1)
    % 始终将每段路径的第一个点添加到 symmetryKPoints 中
    point1 = replace(symmetryResult.path{i, 1}, 'GAMMA', 'Γ');
    coordinate1 = symmetryResult.point_coords(symmetryResult.path{i, 1});
    symmetryKPoints(index, :) = [num2cell(coordinate1), numInterpolationPoints, point1];
    index = index + 1;

    if i < size(symmetryResult.path, 1)
        % 若当前路径并非最后一段路径
        point2 = replace(symmetryResult.path{i, 2}, 'GAMMA', 'Γ');
        point3 = replace(symmetryResult.path{i+1, 1}, 'GAMMA', 'Γ');

        if strcmp(point2, point3)
            % 若当前路径的第二个点与下一段路径的第一个点相同，则跳过本段路径的第二个点
            continue
        else
            % 若当前路径的第二个点与下一段路径的第一个点不同，则添加本段路径的第二个点并设置分段点数为 2
            coordinate2 = symmetryResult.point_coords(symmetryResult.path{i, 2});
            symmetryKPoints(index, :) = [num2cell(coordinate2), 2, point2];
            index = index + 1;
            continue
        end
    else
        % 最后一段路径始终添加 point2
        point2 = replace(symmetryResult.path{i, 2}, 'GAMMA', 'Γ');
        coordinate2 = symmetryResult.point_coords(symmetryResult.path{i, 2});
        symmetryKPoints(index, :) = [num2cell(coordinate2), numInterpolationPoints, point2];
    end
end

symmetryKPoints = symmetryKPoints(1:index, :);
end
