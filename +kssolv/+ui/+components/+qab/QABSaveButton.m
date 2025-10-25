classdef QABSaveButton < matlab.ui.internal.toolstrip.impl.QABPushButton
    %QABSAVEBUTTON 自定义图标的 QAB 保存按钮

    %   开发者：杨柳
    %   版权 2025 合肥瀚海量子科技有限公司

    methods
        %% Constructor
        function this = QABSaveButton(varargin)
            this = this@matlab.ui.internal.toolstrip.impl.QABPushButton(varargin{:});
            this.setPropertyDefaults();
        end
    end

    methods (Access = private)
        function setPropertyDefaults(this)
            import kssolv.ui.util.Localizer.message

            action = this.getAction();

            % Set Icon property
            action.Icon = matlab.ui.internal.toolstrip.Icon('saved');
            action.QuickAccessIcon = matlab.ui.internal.toolstrip.Icon('saved');

            % Set Text property
            action.Text = message('KSSOLV:toolbox:QABSaveButtonLabel');

            % Set Description property
            action.Description = message('KSSOLV:toolbox:QABSaveButtonTooltip');

            % Set Enabled property
            action.Enabled = true;

            % Set Tag property
            this.Tag = 'QABSaveButton';
        end
    end
end