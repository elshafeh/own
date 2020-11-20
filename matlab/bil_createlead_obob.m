clear ; clc;

if isunix
    project_dir             = '/project/3015079.01/';
else
    project_dir             = 'P:/3015079.01/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName             = suj_list{nsuj};
    
    chk                     = dir(['/project/3015039.06/bil/mri/' subjectName '.processedmri.plusnas.mat']);
        
    template_file           = '../data/stock/obob_parcellation_grid_5mm.mat'; %

    if isempty(chk)
        mri_filename      	= '/home/common/matlab/fieldtrip/template/anatomy/single_subj_T1.nii';
        [vol, grid]         = h_create_templateheadmodel(mri_filename,template_file);
    else
        mri_filename      	= [chk(1).folder filesep chk(1).name];
        fprintf('mri file found: %s\n',mri_filename);
        [vol, grid]       	= h_create_normalisedHeadmodel(mri_filename,template_file);
    end
    
    
    fname                   = [project_dir 'data/' subjectName '/preproc/' subjectName '_firstCueLock_ICAlean_finalrej.mat'];
    fprintf('loading: %s\n',fname);
    load(fname);
    
    cfg                  	= [];
    cfg.sourcemodel       	= grid;
    cfg.headmodel        	= vol;
    cfg.grad               	= dataPostICA_clean.grad;
    cfg.channel            	= 'MEG';
    leadfield              	= ft_prepare_leadfield(cfg);

    figure(1); clf, hold on;
    ft_plot_sens(dataPostICA_clean.grad, 'unit','cm');
    ft_plot_mesh(leadfield.pos(leadfield.inside,:));
    ft_plot_headmodel(vol, 'unit','cm', 'edgecolor', 'none', 'facealpha', 0.4);
    view([10, 20]);
    figure(2); clf,hold on
    ft_plot_sens(dataPostICA_clean.grad, 'unit','cm');
    ft_plot_mesh(leadfield.pos(leadfield.inside,:));
    ft_plot_headmodel(vol, 'unit','cm', 'edgecolor', 'none', 'facealpha', 0.4);
    view([-90, 45]);
    
    
    fname_out               = ['/project/3015039.06/bil/head/' subjectName '.volgridLead.bobWithNas.mat'];
    fprintf('saving %s\n',fname_out);
    save(fname_out,'vol','grid','leadfield','-v7.3');


end