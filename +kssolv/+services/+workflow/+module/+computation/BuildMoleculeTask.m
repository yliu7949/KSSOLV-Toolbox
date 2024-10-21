classdef BuildMoleculeTask < kssolv.services.workflow.module.AbstractTask
    %BUILDMOLECULETASK 由结构信息生成 KSSOLV 的 Molecule/Crystal 类的实例

    properties (Constant)
        TASK_NAME = 'Build Molecule';
        DESCRIPTION = 'Build Molecule/Crystal object of KSSOLV';
    end

    methods
        function this = setup(this)
            this.module = kssolv.services.workflow.module.ModuleType.Computation;
            this.requiredTaskNames = [];
            this.supportGPU = false;
            this.supportParallel = false;
        end

        function getOptionsUI(this, accordion)
            arguments
                this
                accordion matlab.ui.container.internal.Accordion
            end
            this.optionsUI = kssolv.services.workflow.module.computation.BuildMoleculeTaskUI(accordion);
        end

        function output = executeTask(this, ~, ~)
            if isempty(this.optionsUI)
                return
            end
            options = this.optionsUI.options;

            % 设定赝势
            pseudopotential.PpType(options.pseudopotentialPpType);

            % 构建 Molecule/Crystal 实例
            structure = options.structures(1);
            if strcmp(options.type, 'Crystal')
                molecule = Crystal('supercell', structure.C, 'atomlist', structure.atomlist, 'xyzlist', structure.xyzlist);
            else
                molecule = Molecule('supercell', structure.C, 'atomlist', structure.atomlist, 'xyzlist', structure.xyzlist);
            end

            % 为 Molecule/Crystal 实例设置选项
            fields = fieldnames(options);
            for i = 1:length(fields)
                fieldName = fields{i};
                if ~strcmp(fieldName, 'type') && ~strcmp(fieldName, 'pseudopotentialPpType') ...
                        && ~strcmp(fieldName, 'structures') && ~strcmp(fieldName, 'autokpts')
                    molecule.(fieldName) = options.(fieldName);
                end
            end

            % 为 Crystal 实例设置选项
            if strcmp(options.type, 'Crystal')
                molecule.autokpts = options.autokpts;
            end

            % 输出到 output
            output.molecule = molecule;
        end
    end
end

