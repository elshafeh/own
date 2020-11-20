clear ; clc;

if isunix
    project_dir             = '/project/3015079.01/';
else
    project_dir             = 'P:/3015079.01/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = [33 20 10]
    
    subjectName             = suj_list{nsuj};
    
    res_vox                 = '1cm';
    
    chk                     = dir(['I:\bil\mri\' subjectName '.processedmri.plusnas.mat']);    
    template_file           = ['../data/stock/template_grid_' res_vox '.mat'];

    if isempty(chk)
        mri_filename      	= 'H:/common/matlab/fieldtrip/template/anatomy/single_subj_T1_1mm.nii';
        [vol, grid]         = h_create_templateheadmodel(mri_filename,1);
    else
        mri_filename      	= [chk(1).folder filesep chk(1).name];
        [vol, grid]       	= h_create_normalisedHeadmodel(mri_filename,template_file);
    end
    
    fprintf('mri file found: %s\n',mri_filename);
    
    fname                   = ['I:\bil\head\' subjectName '.datainfo.mat'];
    fprintf('loading: %s\n',fname);
    load(fname);
    
    cfg                  	= [];
    cfg.sourcemodel       	= grid;
    cfg.headmodel        	= vol;
    cfg.grad               	= datainfo.grad;
    cfg.channel            	= 'MEG';
    leadfield              	= ft_prepare_leadfield(cfg);

    fname_out               = ['I:\bil\head\' subjectName '.volgridLead.' res_vox '.withNas.mat'];
    fprintf('saving %s\n',fname_out);
    save(fname_out,'vol','grid','leadfield','-v7.3');

end