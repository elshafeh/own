clear ; clc ; close all ; dleiftrip_addpath;

suj_list = [1:4 8:17];

for sb = 1:length(suj_list)
    
    suj         = ['yc' num2str(suj_list(sb))];
    ext_comp    = 'nDT.N1';
    lst_time    = {'bsl','actv'};
    lst_cue     = 'RLNV';
    
    for cnd_cue = 1:4
        
        for cnd_time = 1:2
            source_carr{cnd_time} = [];
            
            for prt = 1:3
                
                fname = dir(['../data/source/' suj '.*pt' num2str(prt) '*' lst_cue(cnd_cue) ext_comp '*' lst_time{cnd_time} '*']);
                fname = fname.name;
                fprintf('\nLoading %50s',fname);
                load(['../data/source/' fname]);
                source_carr{cnd_time} = [source_carr{cnd_time} source] ; clear source
                
            end
            
            source_carr{cnd_time} = nanmean(source_carr{cnd_time},2);
            
        end
        
        load ../data/template/source_struct_template_MNIpos.mat
        
        pow = (source_carr{2}-source_carr{1}) ./ source_carr{1} ;
        
        source_avg{sb,cnd_cue}.pow            = pow; clear source_carr pow;
        source_avg{sb,cnd_cue}.pos            = source.pos ;
        source_avg{sb,cnd_cue}.dim            = source.dim ;
        
        clear source
        
    end
    
end

cfg                 = h_prepare_cluster_source(0.01,source_avg{1,1});

cnd_stat = [1 2; 1 3; 2 3; 4 3];
lst_stat = {'RmL','RmN','LmN','VmN'};

for cs = 1:4
    stat{cs}                = ft_sourcestatistics(cfg, source_avg{:,cnd_stat(cs,1)},source_avg{:,cnd_stat(cs,2)});
    [min_p(cs),p_val{cs}]   = h_pValSort(stat{cs});
end

for cs = 1:4
    list{cs}                = FindSigClusters(stat{cs},0.11);
end

for cs = 1:4
    stat_int                    = h_interpolate(stat{cs});
    stat_int.mask               = stat_int.prob < 0.11;
    stat_int.stat               = stat_int.stat .* stat_int.mask;
    cfg                         = [];
    cfg.method                  = 'slice';
    cfg.funparameter            = 'stat';
    cfg.maskparameter           = 'mask';
    cfg.nslices                 = 16;
    %     cfg.slicerange              = [70 84];
    cfg.funcolorlim             = [-5 5];
    ft_sourceplot(cfg,stat_int);clc;
    title(lst_stat{cs});
end