clear; global ft_default
ft_default.spmversion = 'spm12';

for ns = 1:51
    
    subjectname                         = ['sub' num2str(ns)];
    
    fname                               = ['../data/prepro/vis/data' num2str(ns) '.mat'; ];
    fprintf('\nloading %s\n',fname);
    load(fname);
    
    fname                               = ['../data/prepro/vis/grad' num2str(ns) '.mat'; ];
    fprintf('\nloading %s\n',fname);
    load(fname);
    
    data.grad                           = grad; clear grad;
    
    fname                               = ['../data/source/mri/mri_' num2str(ns) '.mat'; ];
    fprintf('\nloading %s\n',fname);
    load(fname);
    
    fname                               = '../data/template/template_grid_1cm.mat';
    fprintf('\nloading %s\n',fname);
    load(fname);
    
    [vol, grid]                         = h_create_normalisedHeadmodel(mri,template_grid); clear fname;
    
    cfg                                 = [];
    cfg.grid                            = grid;
    cfg.headmodel                       = vol;
    cfg.grad                            = data.grad;
    cfg.channel                         = 'MEG';
    leadfield                           = ft_prepare_leadfield(cfg);
    
    cfg                                 = [];
    cfg.channel                         = data.label;
    leadfield                           = ft_selectdata(cfg,leadfield);
    
    fname_out                           = ['../data/source/lead/' subjectname '.vis.leadVolGrid.mat'];
    fprintf('\nsaving %s\n',fname_out);
    save(fname_out,'vol','grid','leadfield','-v7.3');

    % look at evoked response to be sure!
    com_filter                          = nbk_vis_common_filter(data,leadfield,vol);
    
    [source,ext_name]                   = nbk_vis_dics_separate(data,[0 0.5],leadfield,vol,com_filter);
    fname_out                           = ['../data/source/vis/' subjectname '.' ext_name  '.dics.mat'];
    fprintf('\nsaving %s\n',fname_out);
    save(fname_out,'source','-v7.3');
    
    [source,ext_name]                   = nbk_vis_dics_separate(data,[-0.6 -0.1],leadfield,vol,com_filter);
    fname_out                           = ['../data/source/vis/' subjectname '.' ext_name  '.dics.mat'];
    fprintf('\nsaving %s\n',fname_out);
    save(fname_out,'source','-v7.3');
    
    keep ns    

end