clear ; clc ; close all ; dleiftrip_addpath;

suj_list = [1:4 8:17];

lst = 'RLNV';

for cnd_cue = 1:4
    
    for sb = 1:length(suj_list)
        
        suj         = ['yc' num2str(suj_list(sb))];
        ext_comp    = [lst(cnd_cue) 'nDT.N1'];
        lst_time    = {'bsl','actv'};
        
        for cnd = 1:2
            
            source_carr = [];
            
            for prt = 1:3
                
                fname = dir(['../data/source/' suj '.*pt' num2str(prt) '*' ext_comp '*' lst_time{cnd} '*']);
                fname = fname.name;
                fprintf('\nLoading %50s',fname);
                load(['../data/source/' fname]);
                
                source_carr = [source_carr source] ; clear source
                
            end
            
            load ../data/template/source_struct_template_MNIpos.mat
            
            source_avg{sb,cnd}.pow            = nanmean(source_carr,2); clear source_carr ;
            source_avg{sb,cnd}.pos            = source.pos ;
            source_avg{sb,cnd}.dim            = source.dim ;
            
            clear source
            
        end
        
    end
    
    cfg                 = h_prepare_cluster_source(0.05,source_avg{1,1});
    stat                = ft_sourcestatistics(cfg, source_avg{:,2},source_avg{:,1});
    stat                = rmfield(stat,'cfg');
    [min_p,p_val]       = h_pValSort(stat);
    list                = FindSigClusters(stat,0.05);
    
    stat_int            = h_interpolate(stat);
    stat_int.mask       = stat_int.prob < 0.05;
    stat_int.stat       = stat_int.stat .* stat_int.mask;
    
    cfg                         = [];
    cfg.method                  = 'slice';
    cfg.funparameter            = 'stat';
    cfg.maskparameter           = 'mask';
    cfg.nslices                 = 16;
    cfg.slicerange              = [70 84];
    cfg.funcolorlim             = [-4 4];
    ft_sourceplot(cfg,stat_int);clc;
    
end