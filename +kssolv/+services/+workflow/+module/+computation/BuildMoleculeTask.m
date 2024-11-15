classdef BuildMoleculeTask < kssolv.services.workflow.module.AbstractTask
    %BUILDMOLECULETASK 由结构信息生成 KSSOLV 的 Molecule/Crystal 类的实例

    properties (Constant)
        TASK_NAME = 'Build Molecule';
        DESCRIPTION = 'Build Molecule/Crystal object of KSSOLV';
    end

    methods (Access = protected)
        function this = setup(this)
            this.module = kssolv.services.workflow.module.ModuleType.Computation;
            this.requiredTaskNames = [];
            this.supportGPU = false;
            this.supportParallel = false;
        end
    end

    methods
        function getOptionsUI(this)
            this.optionsUI = kssolv.services.workflow.module.computation.BuildMoleculeTaskUI();
        end

        function output = executeTask(this, ~, ~)
            if isempty(this.optionsUI)
                return
            end
            taskOptions = this.optionsUI.options;

            % 设定赝势
            pseudopotential.PpType(taskOptions.pseudopotentialPpType);

            % 构建 Molecule/Crystal 实例
            structure = taskOptions.structures(1);
            if strcmp(taskOptions.type, 'Crystal')
                molecule = Crystal('supercell', structure.C, 'atomlist', ...
                    Atom(cellstr(structure.atomList)), 'xyzlist', structure.xyzList, 'name', structure.name);
            else
                molecule = Molecule('supercell', structure.C, 'atomlist', ...
                    Atom(cellstr(structure.atomList)), 'xyzlist', structure.xyzList, 'name', structure.name);
            end

            % 为 Molecule/Crystal 实例设置选项
            fields = fieldnames(taskOptions);
            for i = 1:length(fields)
                fieldName = fields{i};
                if ~strcmp(fieldName, 'type') && ~strcmp(fieldName, 'pseudopotentialPpType') ...
                        && ~strcmp(fieldName, 'structures') && ~strcmp(fieldName, 'autokpts')
                    molecule.(fieldName) = taskOptions.(fieldName);
                end
            end

            % 为 Crystal 实例设置选项
            if strcmp(taskOptions.type, 'Crystal')
                molecule.autokpts = taskOptions.autokpts;
            end

            % 输出到 output
            output.molecule = molecule;
        end
    end
end

