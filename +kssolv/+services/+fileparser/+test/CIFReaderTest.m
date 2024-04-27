classdef CIFReaderTest < matlab.unittest.TestCase
    %CIFREADERTEST 测试 CIFReader 函数

    %   开发者：杨柳
    %   版权 2024 合肥瀚海量子科技有限公司

    properties
        CIFDirectory
    end
    
    methods(TestClassSetup)
        function setFilePath(testCase)
            % 设置文件路径为测试类文件所在文件夹的 CIF 子文件夹
            testCase.CIFDirectory = fullfile(fileparts(mfilename('fullpath')), 'CIF');
        end
    end
    
    methods(Test)    
        function Al2O3(testCase)
            % 测试 Al2O3.cif 文件的读取和解析
            filePath = fullfile(testCase.CIFDirectory, 'Al2O3.cif');
            cif = kssolv.services.fileparser.CIFReader(filePath);
            testCase.verifyEqual(cif.CIFObject.a, 5.17795526, 'Non equal');
        end
    end
    
end