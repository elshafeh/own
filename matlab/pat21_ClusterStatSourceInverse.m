clear ; clc ; dleiftrip_addpath ;

suj_list = [1:4 8:17];

cnd_freq    = {'9t13Hz','10t12Hz','9t13'};
cnd_time    = {{'.m600m300','.p800p1100'},{'.m600m400','.p600p800'},{'.m600m100','.p600p1100'}};

conds = {'VCnD','NCnD'};

ext_end = 'VN.dics' ;

for ntest = 1:length(cnd_freq)
    
    for sb = 1:length(suj_list)
        
        suj = ['yc' num2str(suj_list(sb))];
        
        for cnd = 1:2
            
            for cp = 1:3
                
                for ix = 1:2
                    
                    fname = dir(['../data/' suj '/source/*pt' num2str(cp) '*' conds{cnd} '*' cnd_freq{ntest} '*' cnd_time{ntest}{ix} '*' ext_end '*']);
                    fname = fname.name;
                    fprintf('Loading %50s\n',fname);
                    
                    load(['../data/' suj '/source/' fname]);
                    
                    if isstruct(source);
                        source = source.avg.pow;
                    end
                    
                    src_carr{cp,ix} = source ; clear source ;
                    
                end
                
                clear src_t
                
            end
            
            load ../data/template/source_struct_template_MNIpos.mat
            
            actv    = nanmean([src_carr{1,2} src_carr{2,2} src_carr{3,2}],2);
            bsl     = nanmean([src_carr{1,1} src_carr{2,1} src_carr{3,1}],2);
            
            source_avg{sb,cnd,ntest}.pow        = (actv - bsl) ./ bsl;
            source_avg{sb,cnd,ntest}.pos        = source.pos;
            source_avg{sb,cnd,ntest}.dim        = source.dim;
            
            clear src_carr actv bsl
            
        end
        
    end
    
end

for ntest = 1:length(cnd_freq)
    
    cfg                     =   [];
    cfg.dim                 =   source_avg{1,1}.dim;
    cfg.method              =   'montecarlo';
    cfg.statistic           =   'depsamplesT';
    cfg.parameter           =   'pow';
    cfg.correctm            =   'cluster';
    cfg.clusteralpha        =   0.05;             % First Threshold
    cfg.clusterstatistic    =   'maxsum';
    cfg.numrandomization    =   1000;
    cfg.alpha               =   0.025;
    cfg.tail                =   0;
    cfg.clustertail         =   0;
    cfg.design(1,:)         =   [1:14 1:14];
    cfg.design(2,:)         =   [ones(1,14) ones(1,14)*2];
    cfg.uvar                =   1;
    cfg.ivar                =   2;
    
    
    stat{ntest}                 = ft_sourcestatistics(cfg,source_avg{:,1,ntest},source_avg{:,2,ntest}) ;
    [min_p(ntest),p_val{ntest}] = h_pValSort(stat{ntest});

end

clearvars -except ntestot min_p p_val stat

for ntest = 1:size(stat,2)
    
    plim = 0.05 ;
    
    if min_p(ntest) < plim
        
        stat_int{ntest} = h_interpolate(stat{ntest});
        stat_int{ntest}.mask    = stat_int{ntest}.prob < plim;
        
        cfg                     = [];
        cfg.method              = 'slice';
        cfg.funparameter        = 'stat';
        cfg.maskparameter       = 'mask';
        cfg.nslices             = 16;
        cfg.slicerange          = [70 84];
        cfg.funcolorlim         = [-3 3];
        ft_sourceplot(cfg,stat_int{ntest});
        
    end
end