clear;
% Test1: Si8
% args=struct('CIF','Si.cif');
% cry=readCIF(args);

% Test2: Al2O3
args=struct('CIF','Al2O3.cif','nk',2,'ecut',10);%,'KPOINTS','Si.vasp/KPOINTS','INCAR','Si.vasp/INCAR');
cry=readCIF(args);