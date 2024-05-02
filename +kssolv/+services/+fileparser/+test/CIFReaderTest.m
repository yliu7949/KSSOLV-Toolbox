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

        function BN(testCase)
            % 测试 BN.cif 文件的读取和解析
            filePath = fullfile(testCase.CIFDirectory, 'BN.cif');
            cif = kssolv.services.fileparser.CIFReader(filePath);
            testCase.verifyEqual(cif.CIFObject.a, 2.50326420, 'Non equal');
        end

        function generateSetupFile(testCase)
            % 读取 CIF 文件
            filePath = fullfile(testCase.CIFDirectory, 'BN.cif');
            cif = kssolv.services.fileparser.CIFReader(filePath);
        
            % 获取信息
            name = cif.KSSOLVSetupObject.name;
            atomList = cif.KSSOLVSetupObject.atomList;
            xyzList = cif.KSSOLVSetupObject.xyzList;
            C = cif.KSSOLVSetupObject.C;
        
            % 检查 data 文件夹是否存在
            if ~exist('./data', 'dir')
                mkdir('./data');
            end
        
            % 打开文件
            fid = fopen('./data/output.m', 'w');
            if fid == -1
                error('KSSOLV:FileParser:CIFReaderTest:OpenFileError', 'Failed to open file: ./data/output.m');
            end
            
            % 写入文件内容
            fprintf(fid, '%% Auto-generated setup file by KSSOLV Toolbox\n');
            fprintf(fid, 'kssolvpptype(''pz-hgh'', ''UPF'');\n\n');
            
            fprintf(fid, '%% 1. Construct atoms\n');
            % 获取唯一的原子
            uniqueAtoms = unique(atomList);
            % 统计每种原子的数量
            atomCounts = histcounts(categorical(atomList, uniqueAtoms));
        
            fprintf(fid, 'atomList = [\n');
            for i = 1:numel(uniqueAtoms)
                fprintf(fid, '    repmat(Atom(''%s''), 1, %d)', uniqueAtoms(i), atomCounts(i));  % 显示原子符号和数量
                if i < numel(uniqueAtoms)
                    fprintf(fid, ' ...\n');
                end
            end
            fprintf(fid, '\n];\n\n');
            
            % 定义超胞
            fprintf(fid, '%% 2. Set up supercell\n');
            fprintf(fid, 'C = [\n');
            for i = 1:size(C, 1)
                fprintf(fid, '     ');
                for j = 1:size(C, 2)
                    fprintf(fid, '%f', C(i, j));
                    if j < size(C, 2)
                        fprintf(fid, '   ');
                    end
                end
                if i < size(C, 1)
                    fprintf(fid, '\n');
                end
            end
            fprintf(fid, '\n];\n\n');
            
            % 定义坐标
            fprintf(fid, '%% 3. Define the coordinates for the atoms\n');
            fprintf(fid, 'xyzList = [\n');
            for i = 1:size(xyzList, 1)
                fprintf(fid, '    ');
                for j = 1:3
                    fprintf(fid, '%f', xyzList(i, j));
                    if j < 3
                        fprintf(fid, '    ');
                    end
                end
                if i < size(xyzList, 1)
                    fprintf(fid, '\n');
                end
            end
            fprintf(fid, '\n];\n\n');
            
            % 配置晶体
            fprintf(fid, '%% 4. Configure the molecule (crystal)\n');
            % 假设截断能默认值为 25
            ecut = 25;
            fprintf(fid, 'mol = Molecule(''supercell'', C, ''atomlist'', atomList, ''xyzlist'', xyzList, ...\n    ''ecut'', %d, ''name'', ''%s'');\n', ecut, name);
            
            % 关闭文件
            fclose(fid);
        end  
    end
end