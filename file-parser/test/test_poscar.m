clear;
%Test1: Si8
% args=struct('POSCAR','Si.vasp/POSCAR');
% mol=readPOSCAR(args);

%Test2: Al2O3
args=struct('POSCAR','Al2O3.vasp/POSCAR');%,'KPOINTS','Si.vasp/KPOINTS','INCAR','Si.vasp/INCAR');
cry=readPOSCAR(args);