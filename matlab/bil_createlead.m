clear ; clc;

if isunix
    project_dir             = '/project/3015079.01/';
else
    project_dir             = 'P:/3015079.01/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName             = suj_list{nsuj};
    
    %     chk                     = dir([project_dir 'data/' subjectName '/mri/' subjectName '.processedmri.mat']);
    chk                     = dir(['/project/3015039.06/bil/mri/' subjectName '.processedmri.plusnas.mat']);
    
    
    template_file           = '../data/stock/template_grid_0.5cm.mat';%'../data/stock/obob_parcellation_grid_5mm.mat'; %

    if isempty(chk)
        % if subject has no mri
        mri_filename      	= '/home/common/matlab/fieldtrip/template/anatomy/single_subj_T1.nii';
        [vol, grid]         = h_create_templateheadmodel(mri_filename,template_file);
    else
        mri_filename      	= [chk(1).folder filesep chk(1).name];
        [vol, grid]       	= h_create_normalisedHeadmodel(mri_filename,template_file);
    end
    
    fprintf('mri file found: %s\n',mri_filename);
    
    fname                   = [project_dir 'data/' subjectName '/preproc/' subjectName '_firstCueLock_ICAlean_finalrej.mat'];
    fprintf('loading: %s\n',fname);
    load(fname);
    
    cfg                  	= [];
    cfg.sourcemodel       	= grid;
    cfg.headmodel        	= vol;
    cfg.grad               	= dataPostICA_clean.grad;
    cfg.channel            	= 'MEG';
    leadfield              	= ft_prepare_leadfield(cfg);

    %     fname_out               = ['/project/3015039.06/bil/head/' subjectName '.volgridLead.obob.mat'];
    fname_out               = ['/project/3015039.06/bil/head/' subjectName '.volgridLead.0.5cm.withNas.mat'];
    
    fprintf('saving %s\n',fname_out);
    save(fname_out,'vol','grid','leadfield','-v7.3');


end