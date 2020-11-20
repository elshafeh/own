clear;

if ispc
    proj_dir    = 'P:/';
    home_dir    = 'H:/';
else
    proj_dir    = '/project/';
    home_dir    = '/home/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

ln_pol                              = [];

for nsuj = 1:length(suj_list)-1
    
    subjectName                     = suj_list{nsuj};
    polhemus_file                   = dir([proj_dir '3015079.01/meg_data/Polhemus/bil_' subjectName '.pos']);
    
    if ~isempty(polhemus_file)
        polhemus                    = ft_read_headshape([polhemus_file(1).folder filesep polhemus_file(1).name]);
        ln_pol                      = [ln_pol;length(polhemus.pos)];
        
    end
end

keep ln_pol

plot(ln_pol);