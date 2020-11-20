clear ; clc ; close all ; dleiftrip_addpath;

suj_list = [1:4 8:17];

for sb = 1:length(suj_list)
    
    suj         = ['yc' num2str(suj_list(sb))];
    ext_comp    = 'nDT.extended';
    lst_time    = {'bsl','N1','P2','P3'};
    
    for cnd = 1:length(lst_time)
        for prt = 1:3
            fname = dir(['../data/source/' suj '.*pt' num2str(prt) '*' ext_comp '*' lst_time{cnd} '*']);
            fname = fname.name;
            fprintf('\nLoading %50s',fname);
            load(['../data/source/' fname]);
            source_carr{sb,cnd,prt} = source ; clear source
        end
    end
end

clearvars -except source_carr

for sb = 1:14
    for cnd = 1:4
        source_avg{sb,cnd}.pow            = nanmean([source_carr{sb,cnd,1} source_carr{sb,cnd,2} source_carr{sb,cnd,3}],2);
        load ../data/template/source_struct_template_MNIpos.mat
        source_avg{sb,cnd}.pos            = source.pos ;
        source_avg{sb,cnd}.dim            = source.dim ;
    end
end

clearvars -except source_avg;

cfg                 = h_prepare_cluster_source(0.0025,source_avg{1,1});

for cnd = 2:4
    stat{cnd-1}     = ft_sourcestatistics(cfg, source_avg{:,cnd},source_avg{:,1});
    stat{cnd-1}                 = rmfield(stat{cnd-1} ,'cfg');
    [min_p(cnd-1),p_val{cnd-1}]       = h_pValSort(stat{cnd-1});
    list{cnd-1}                = FindSigClusters(stat{cnd-1},0.05);
end

for cnd = 1:3
    stat_int{cnd}            = h_interpolate(stat{cnd});
    stat_int{cnd}.mask       = stat_int{cnd}.prob < 0.05;
    stat_int{cnd}.stat       = stat_int{cnd}.stat .* stat_int{cnd}.mask;
    
    cfg                         = [];
    cfg.method                  = 'slice';
    cfg.funparameter            = 'stat';
    cfg.maskparameter           = 'mask';
    cfg.nslices                 = 16;
    cfg.slicerange              = [70 84];
    cfg.funcolorlim             = [-5 5];
    ft_sourceplot(cfg,stat_int{cnd});clc;
end