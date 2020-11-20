clear ; clc ; dleiftrip_addpath ;

for ntestot = 1:8
    
    if ntestot < 5
        ntest = ntestot;
    else
        ntest = ntestot-4;
    end
    
    load ../data/yc1/source/yc1.pt1.CnD.all.mtmfft.8t10Hz.m600m200.bsl.5mm.source.mat
    load ../data/yc1/headfield/yc1.VolGrid.5mm.mat ; clc ;
    
    template_source = source ; clear source
    
    suj_list = [1:4 8:17];
    
    all_cond    = 'RLN';
    cnd_freq    = '9t13Hz';
    cnd_time    = {{'.m600m200','.p300p700'},{'.m600m200','.p200p600'},{'.m600m200','.p600p1000'},{'.m600m200','.p600p1000'}};
    
    c2c = [1 2;1 3;1 3;2 3];
    
    conds = {[all_cond(c2c(ntest,1)) 'CnD'],[all_cond(c2c(ntest,2)) 'CnD']};
    
    if ntestot < 5
        ext_end = [all_cond(c2c(ntest,1)) all_cond(c2c(ntest,2)) '.5mm'];
    else
        ext_end = [all_cond(c2c(ntest,1)) all_cond(c2c(ntest,2)) 'exp.5mm'];
    end
    
    for sb = 1:length(suj_list)
        
        suj = ['yc' num2str(suj_list(sb))];
        
        for cnd = 1:2
            
            for cp = 1:3
                
                for ix = 1:2
                    
                    fname = dir(['../data/' suj '/source/*pt' num2str(cp) '*' conds{cnd} '*' cnd_freq '*' cnd_time{ntest}{ix} '*' ext_end '*']);
                    fname = fname.name;
                    fprintf('Loading %50s\n',fname);
                    
                    load(['../data/' suj '/source/' fname]);
                    
                    if isstruct(source);
                        source = source.avg.pow;
                    end
                    
                    src_t{ix} = source ; clear source ;
                    
                end
                
                src_carr{cp} = (src_t{2}-src_t{1}) ./ src_t{1};

                clear src_t
                
            end
            
            source_avg{sb,cnd}.pow        = mean([src_carr{1} src_carr{2} src_carr{3}],2);
            source_avg{sb,cnd}.pos        = grid.MNI_pos;
            source_avg{sb,cnd}.freq       = template_source.freq;
            source_avg{sb,cnd}.dim        = template_source.dim;
            source_avg{sb,cnd}.method     = template_source.method;
            
            clear src_carr
            
        end
        
    end
    
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
    
    if ntestot < 5
        end_row = 1;
    else
        end_row = 2;
    end
    
    stat{end_row,ntest}                 = ft_sourcestatistics(cfg,source_avg{:,1},source_avg{:,2}) ;
    [min_p{end_row,ntest},p_val{end_row,ntest}] = h_pValSort(stat{end_row,ntest});
    
    clearvars -except ntestot min_p p_val stat
    
end

for a = 1:2
    for b = 1:4
        
        p_lim = 0.11 ;
        
        if min_p{a,b} < p_lim && min_p{a,b} > 0 
            
            stat_int{a,b} = h_interpolate(stat{a,b});
            stat_int{a,b}.mask    = stat_int{a,b}.prob < p_lim;
            
            cfg                     = [];
            cfg.method              = 'slice';
            cfg.funparameter        = 'stat';
            cfg.maskparameter       = 'mask';
            cfg.nslices             = 16;
            cfg.slicerange          = [70 84];
            cfg.funcolorlim         = [-3 3];
            ft_sourceplot(cfg,stat_int{a,b});
            
        end
    end
end