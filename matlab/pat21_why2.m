clear ; clc ;

for sb = 1:2
    
    suj_list = [2 4];
    
    suj = ['yc' num2str(suj_list(sb))] ;
   
    mri{sb} = ft_read_mri(['../mri/' suj '_T1_converted_V2.mri']);
    
    cfg             = [];
    cfg.downsample  = 1;
    seg{sb}         = ft_volumesegment(cfg, mri{2});
    
    cfg                 = [];
    cfg.output          = {'brain','skull','scalp'};
    segmentedmri{sb}    = ft_volumesegment(cfg, mri{sb});
    
    cfg                 =   [];
%     cfg.tissue          =   {'brain','skull','scalp'};
%     cfg.numvertices     =   [3000 2000 1000];
    bnd{sb}             =   ft_prepare_mesh(cfg,seg{sb});
    
    cfg                 = [];
    cfg.method          ='dipoli';
    vol{sb}             = ft_prepare_headmodel(cfg, bnd{sb});
    
    clearvars -except vol bnd segmentedmri mri sb
    
end