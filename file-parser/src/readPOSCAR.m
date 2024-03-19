function sys = readPOSCAR(args)
    fid = fopen(args.POSCAR,'r');
    
    %Get the comment line
    name = fgetl(fid);
    
    %Get scaling factor; negative scaling factor represents the desired cell volume
    seperate_scaling = false;
    volume_scaling = false;
    scaling = strsplit(fgetl(fid));
    if length(scaling) == 1
        scaling = str2double(scaling);
        if scaling < 0
            volume_scaling = true;
            volume = -scaling;
        end
    else
        seperate_scaling = true;
        scaling = str2double(scaling);
    end
    
    %Read lattice vectors
    a1=str2double(strsplit(fgetl(fid)));
    a2=str2double(strsplit(fgetl(fid)));
    a3=str2double(strsplit(fgetl(fid)));
    
    if ~seperate_scaling
        if ~volume_scaling
            C=scaling*[a1;a2;a3];
        else
            C=[a1;a2;a3];
            scaling=nthroot((volume/abs(det(C))),3);
            C=scaling*C;
        end
    else
        C=[a1;a2;a3];
        C=C*diag(scaling);
    end
    
    %Read atom species
    species = strsplit(fgetl(fid));
    num = str2double(strsplit(fgetl(fid)));
    n_species = length(species);
    n_atoms = sum(num);
    a = zeros(1,n_species,'Atom');
    atomlist = zeros(1,n_atoms,'Atom');
    idx = 1;
    for i = 1:n_species
        a(i) = Atom(species{i});
        for j = 1:num(i)
            atomlist(idx) =a(i);
            idx =idx+1;
        end
    end
    
    is_selectivedymanics = false;
    tmpline = upper(fgetl(fid));
    if tmpline(1) == 'S'
        is_selectivedymanics = true;
        tmpline = upper(fgetl(fid));
    end
    
    is_direct = true;
    if tmpline(1) == 'C' || tmpline(1) == 'K'
        is_direct = false;
    end
    
    %Read atomic coordinates
    coeffs=zeros(n_atoms,3);
    for i = 1:n_atoms
        tmpline=strsplit(fgetl(fid));
        coeffs(i,:)=str2double(tmpline(1:3));
    end
    
    if is_direct
        xyzlist=coeffs*C;
    else
        if ~seperate_scaling
            xyzlist=coeffs*scaling;
        else
            xyzlist=coeffs*diag(scaling);
        end
    end
    
    %Read kpoint informatin from KPOINTS
    nk=0;
    if isfield(args,'KPOINTS')
        lines = readlines(args.KPOINTS);
        tmpline=upper(lines(3));
        if tmpline(1)=='G'
            nks=str2double(strsplit(lines(4)));
            num_k=nks(1)*nks(2)*nks(3);
            if num_k>1
                nk=nks;
            end    
        end
    end   
    
    %Read ecut from INCAR
    ecut=12.5;
    if isfield(args,'INCAR')
        lines = readlines(args.INCAR);
        for fid =1:length(lines)
            tmpline=lines(fid);
            idx=regexp(tmpline,'\s*ECUT\s*\=\s*[0-9.]*\s*');
            if idx~=1
                continue;
            end
            tmpline=regexp(tmpline,'\s*ECUT\s*\=\s*[0-9.]{1,}\s*','match');
            ecut = str2double(regexp(tmpline{1},'[0-9.]*','match'))/27.211396641308; 
        end
    end   
    
    %Overwrite with args if given
    ng=[];
    funct='PBE';
	temperature=0;
    if isfield(args,'nk')
        nk=args.nk;
    end
    if isfield(args,'ng')
        ng=args.ng;
    end
    if isfield(args,'ecut')
        ecut=args.ecut;
    end
    if isfield(args,'funct')
        funct=args.funct;
    end
    if isfield(args,'temperature')
        temperature=args.temperature;
    end
    
    %Generate system struct
    if nk==0
        sys = Molecule('supercell',C,'n1',ng,'n2',ng,'n3',ng, 'atomlist',atomlist, 'xyzlist' ,xyzlist, ...
			'ecut',ecut, 'name',name,'funct',funct,'temperature',temperature);
    else
        if numel(nk)==1
            nk=[nk,nk,nk];
        end
        sys = Crystal('supercell',C,'n1',ng,'n2',ng,'n3',ng, 'atomlist',atomlist, 'xyzlist' ,xyzlist, ...
                'ecut',ecut, 'name',name, 'autokpts', nk,'funct',funct,'temperature',temperature);
    end