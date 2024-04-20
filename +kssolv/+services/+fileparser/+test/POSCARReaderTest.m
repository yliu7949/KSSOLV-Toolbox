classdef POSCARReaderTest < matlab.unittest.TestCase
    %POSCARREADERTEST 测试 POSCARReader 函数

    %   �?发�?�：杨柳
    %   版权 2024 合肥瀚海量子科技有限公司

    properties
        POSCARDirectory
    end
    
    methods(TestClassSetup)
        function setFilePath(testCase)
            % 设置文件路径为测试类文件�?在文件夹�? POSCAR 子文件夹
            testCase.POSCARDirectory = fullfile(fileparts(mfilename('fullpath')), 'POSCAR');
        end
    end
    
    methods(Test)    
        function Al2O3(testCase)
            % 测试 Al2O3.poscar 文件的读取和解析
            filePath = fullfile(testCase.POSCARDirectory, 'Al2O3.poscar');
            poscar = kssolv.services.fileparser.POSCARReader(filePath);
            testCase.verifyEqual(poscar.POSCARObject.C(1,1), 4.805028, 'Non equal');
            % testCase.verifyEqual(poscar.POSCARObject.equivalentPositionAsXyz, {'x, y, z'}, 'Non equal');
        end
    end
end