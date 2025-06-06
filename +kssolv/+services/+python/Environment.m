classdef Environment < handle
    %ENVIRONMENT 管理 Python 虚拟环境及依赖
    %   使用方法：
    %       pythonEnvironment = kssolv.services.python.Environment.getInstance();
    %       pythonEnvironment.validate();

    % 开发者：杨柳
    % 版权 2025 合肥瀚海量子科技有限公司

    properties
        virtualEnvironmentPath (1, :) char % 虚拟环境绝对路径
        pythonExecutable (1, :) char % Python 解释器路径（虚拟环境内）
    end

    properties (Access = private)
        environmentBackup (1, 1) struct % 原有的 pyenv 设置备份
        requiredPackages = ["mp_api"] % 需要安装的包列表
    end

    properties (Access = private, Constant)
        virtualEnvironmentFolder = fullfile(userpath, 'KSSOLV_Toolbox', 'python', 'venv');
    end

    methods (Access = private)
        function this = Environment()
            % 私有构造函数，只能通过 getInstance 获取实例
            this.environmentBackup = struct("Executable", pyenv().Executable, ...
                "ExecutionMode", pyenv().ExecutionMode);
            this.setupVirtualEnvironment();
            this.configurePythonEnvironment();
            this.installDependencies();
        end
    end

    methods (Static)
        function singletonInstance = getInstance(reset)
            %GETINSTANCE 单例模式获取唯一实例，reset 为 true 时清除 instance 变量
            arguments
                reset (1, 1) logical = false
            end

            persistent instance
            if reset
                instance = [];
            else
                if isempty(instance) || ~isvalid(instance)
                    instance = kssolv.services.python.Environment();
                end
            end

            singletonInstance = instance;
        end
    end

    methods
        function delete(this)
            % 析构函数，恢复为原有的 pyenv 设置
            if strcmp(pyenv().Status, 'Loaded')
                terminate(pyenv);
            end
            pyenv('Version', this.environmentBackup.Executable, ...
                'ExecutionMode', this.environmentBackup.ExecutionMode);

            % 清除 instance 变量
            kssolv.services.python.Environment.getInstance(true);
        end

        function pipInstall(~, packageName)
            % 在虚拟环境中执行 pip 安装
            installCommand = sprintf('%s -m pip install %s', pyenv().Executable, packageName);
            fprintf('Executing installation command: %s\n', installCommand);
            [status, result] = system(installCommand);
            if status ~= 0
                error('Package installation failed: %s', result);
            end
        end

        function pythonCommand = getPythonExecutablePath(this)
            % 获取虚拟环境内的 Python 解释器路径
            pythonCommandParts = split(pyenv().Executable, filesep);
            pythonCommand = fullfile(this.virtualEnvironmentPath, pythonCommandParts{end-1}, pythonCommandParts{end});
            assert(isfile(pythonCommand), 'Python interpreter not found: %s', pythonCommand);
        end

        function validate(this)
            %VALIDATE 验证环境是否配置正确
            assert(isequal(pyenv().Executable, this.pythonExecutable), ...
                'Python interpreter path does not point to the virtual environment');
            try
                pyrun("import mp_api");
                disp('Environment validation passed.');
            catch exception
                error('Dependency verification failed: %s', exception.message);
            end
        end
    end

    methods (Access = private)
        function setupVirtualEnvironment(this)
            % 如果虚拟环境不存在，则创建虚拟环境
            this.virtualEnvironmentPath = kssolv.services.python.Environment.virtualEnvironmentFolder;
            if ~isfolder(this.virtualEnvironmentPath)
                fprintf('Creating virtual environment: %s\n', this.virtualEnvironmentPath);
                [status, message] = mkdir(this.virtualEnvironmentPath, 's');
                if status ~= 0
                    error('Directory creation failed: %s', message);
                end

                createVenvCommand = sprintf('%s -m venv "%s"', pyenv().Executable, this.virtualEnvironmentPath);
                [status, result] = system(createVenvCommand);
                if status ~= 0
                    error('Virtual environment creation failed: %s', result);
                end

                % 获取原有 pyenv 中的 python 命令名称，为 python 或 python3
                pythonCommand = split(pyenv().Executable, filesep);
                pythonCommand = pythonCommand{end};
                pythonCommand = fullfile(this.virtualEnvironmentPath, 'bin', pythonCommand);

                upgradePipCommand = sprintf('%s -m pip install --upgrade pip', pythonCommand, this.virtualEnvironmentPath);
                system(upgradePipCommand);
            end
            this.pythonExecutable = this.getPythonExecutablePath();
        end

        function configurePythonEnvironment(this)
            % 配置 MATLAB 的 Python 环境
            if ~strcmp(pyenv().Executable, this.pythonExecutable)
                if strcmp(pyenv().Status, 'Loaded')
                    terminate(pyenv);
                end
                pyenv('Version', this.pythonExecutable, 'ExecutionMode', 'OutOfProcess');
            end
        end

        function installDependencies(this)
            % 安装所需 Python 包
            for package = this.requiredPackages
                fprintf('Checking package: %s ...\n', package);
                try
                    pyrun(sprintf("import %s", package));
                catch
                    this.pipInstall(package);
                end
            end
        end
    end
end

