function sys = readCIF(args)
    fid=fopen(args.CIF,'r');
    
    line=fgetl(fid);
    tmp=regexp(line,'\s*data_');
    %Get name
    while ~feof(fid) && (isempty(tmp) || tmp(1)~=1)
        line=fgetl(fid);
        tmp=regexp(line,'\s*data_');
    end
    
    tmpline=regexp(line,'data_\S*','match');
    name=tmpline{1}(6:end);
    cifsys=struct('name',name);
    
    %Read CIF file
    line=fgetl(fid);
    while ~feof(fid)
        %Read normal entries
        tmp=regexp(line,'\s*_');
        if ~isempty(tmp) && tmp(1)==1
            tmpline=regexp(line,'_\S{1,}','match');
            field=replace(tmpline{1}(2:end),'.','_');
            value_idx=regexp(line,'_\S{1,}\s*','end');
            value=regexp(line(value_idx+1:end),'\S{1,}','match');
            if ~isnan(str2double(value))
                value=str2double(value);
            cifsys.(field)=value;
            end
            line=fgetl(fid);
            continue;
        end
        
        %Read loop entries
        tmp=regexp(line,'loop_');
        if ~isempty(tmp) && tmp(1)==1
            n_fields=0;
            field_loop={};
            line=fgetl(fid);
            while ~feof(fid)
                tmp_loop=regexp(line,'\s*_');
                if ~isempty(tmp_loop) && tmp_loop(1)==1
                    n_fields=n_fields+1;
                    tmpline_loop=regexp(line,'_\S{1,}','match');
                    field_loop(n_fields)={replace(tmpline_loop{1}(2:end),'.','_')};
                    line=fgetl(fid);
                else
                    break;
                end
            end
            n_entries=0;
            value_loop={};
            while 1
                tmpline_loop=regexp(line,'\s*','split');
                tmp_loop=regexp(line,'\s*_');
                tmp=regexp(line,'loop_');
                if ~isempty(tmp_loop) && tmp_loop(1)==1
                    break;
                elseif isempty(tmpline_loop)
                    break;
                elseif ~isempty(tmp) && tmp(1)==1
                    break;
                else
                    n_entries=n_entries+1;
                    if isempty(tmpline_loop{1})
                        tmpline_loop=tmpline_loop(2:end);
                    end
                end
                for i =1:n_fields
                    value=tmpline_loop{i};
                    value_loop(n_entries,i)={value};
                end
                if feof(fid)
                    break;
                end
                line=fgetl(fid);
            end
            for i=1:n_fields
                if ~isnan(str2double(value_loop(:,i)))
                    value=str2double(value_loop(:,i));
                else
                    value=value_loop(:,i);
                end
                cifsys.(field_loop{i})=value;
            end
            continue;
        end
        line=fgetl(fid);
    end
    
    %Read lattice vectors
    if isfield(cifsys,'cell_vector_a') && isfield(cifsys,'cell_vector_b') && isfield(cifsys,'cell_vector_c')
        C=[cifsys.cell_vector_a;cifsys.cell_vector_b;cifsys.cell_vector_c]';
    elseif isfield(cifsys,'cell_length_a') && isfield(cifsys,'cell_length_b') && isfield(cifsys,'cell_length_c')
        a=cifsys.cell_length_a;
        b=cifsys.cell_length_b;
        c=cifsys.cell_length_c;
        alpha=cifsys.cell_angle_alpha;
        beta=cifsys.cell_angle_beta;
        gamma=cifsys.cell_angle_gamma;
        tmp_cos=((c*sind(beta))^2+(b*sind(gamma))^2-((b^2+c^2-2*b*c*cosd(alpha))-(b*cosd(gamma)-c*cosd(beta))^2))/(2*(c*sind(beta))*(b*sind(gamma)));
        tmp_sin=sqrt(1-tmp_cos^2);
        a1=[a,0,0];
        a2=[b*cosd(gamma),b*sind(gamma),0];
        a3=[c*cosd(beta),c*sind(beta)*tmp_cos,c*sind(beta)*tmp_sin];
        C=[a1;a2;a3];
    end
    
    
    %Read atom species
    if isfield(cifsys,'atom_site_type_symbol')
        n_atoms=length(cifsys.atom_site_type_symbol);
    end
    atomlist = zeros(1,n_atoms,'Atom');
    for i = 1:n_atoms
        atomlist(i) = Atom(cifsys.atom_site_type_symbol{i});
    end

    
    %Read atomic coordinates
    coeffs=zeros(n_atoms,3);
    if isfield(cifsys,'atom_site_fract_x') && isfield(cifsys,'atom_site_fract_y') && isfield(cifsys,'atom_site_fract_z')
        coeffs(:,1)=cifsys.atom_site_fract_x;
        coeffs(:,2)=cifsys.atom_site_fract_y;
        coeffs(:,3)=cifsys.atom_site_fract_z;
        xyzlist=coeffs*C;
    %elseif isfield(cifsys,'atom_site_Cartn_x') && isfield(cifsys,'atom_site_Cartn_y') && isfield(cifsys,'atom_site_Cartn_z')
    end
    
    %Overwrite with args if given
    nk=0;
    ng=[];
    funct='PBE';
	temperature=0;
    ecut=12.5;
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
        nk=1;
    end
    if numel(nk)==1
        nk=[nk,nk,nk];
    end
    sys = Crystal('supercell',C,'n1',ng,'n2',ng,'n3',ng, 'atomlist',atomlist, 'xyzlist' ,xyzlist, ...
                'ecut',ecut, 'name',name, 'autokpts', nk,'funct',funct,'temperature',temperature);