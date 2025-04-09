classdef POSCARReaderTest < matlab.unittest.TestCase
    %POSCARREADERTEST 测试 POSCARReader 函数

    %   开发者：付礼中 杨柳
    %   版权 2024 合肥瀚海量子科技有限公司

    properties
        POSCARDirectory
    end
    
    methods(TestClassSetup)
        function setFilePath(testCase)
            % 设置文件路径，指向测试类文件所在文件夹的 POSCAR 子文件夹
            testCase.POSCARDirectory = fullfile(fileparts(mfilename('fullpath')), 'POSCAR');
        end
    end
    
    methods(Test)    
        function Al2O3(testCase)
            % 测试 Al2O3.POSCAR 文件的读取和解析
            filePath = fullfile(testCase.POSCARDirectory, 'Al2O3.vasp');
            poscar = kssolv.services.fileparser.POSCARReader(filePath);
            testCase.verifyEqual(poscar.KSSOLVSetupObject.C(1,1), 9.784917168360971, 'Non equal');
        end
    end
end