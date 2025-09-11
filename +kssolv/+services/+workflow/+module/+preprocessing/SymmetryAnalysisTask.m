classdef SymmetryAnalysisTask < kssolv.services.workflow.module.AbstractTask
    %SYMMETRYANALYSISTASK 对称性分析和用于能带计算的 K 点路径推荐任务。

    % 该类依赖 +kssolv/+core/processsuite 包。

    %   开发者：杨柳
    %   版权 2025 合肥瀚海量子科技有限公司

    properties (Constant)
        TASK_NAME = 'Symmetry & K-Path'
        IDENTIFIER = 'SymmetryAnalysisTask'
        DESCRIPTION = 'Symmetry and K-Path Analysis'
    end

    methods (Access = protected)
        function this = setup(this)
            this.module = kssolv.services.workflow.module.ModuleType.Preprocessing;
            this.requiredTasks = 'BuildMoleculeTask';
            this.supportGPU = false;
            this.supportParallel = false;
        end
    end

    methods
        function setupOptionsUI(this)
            this.optionsUI = kssolv.services.workflow.module.preprocessing.SymmetryAnalysisTaskUI();
        end

        function output = executeTask(this, ~, input)
            if isempty(this.optionsUI)
                return
            end
            taskOptions = this.optionsUI.options;

            structure = convertMoleculeToCell(input.molecule);
            result = seekpath.hpkot.getPath(structure, taskOptions.withTimeReversal, ...
                taskOptions.symmetryThreshold, taskOptions.symmetryPrecision, taskOptions.angleTolerance);

            output = input;
            output.symmetry = result;
        end
    end
end

function structureCell = convertMoleculeToCell(MoleculeObject)
cell = MoleculeObject.supercell .* 0.5291772083;
positions = MoleculeObject.xyzlist / MoleculeObject.supercell;
atomicNumbers = [MoleculeObject.atomlist.anum]';

structureCell = {cell, positions, atomicNumbers};
end

