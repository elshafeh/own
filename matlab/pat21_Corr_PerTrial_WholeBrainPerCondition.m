clear ; clc ; dleiftrip_addpath;

ext_freq = {'10t16Hz'};cnd_filt = {'SingleTrial.NewDpss'};

for sb = 1:14
    
    suj_list = [1:4 8:17];
    
    suj = ['yc' num2str(suj_list(sb))];
    
    list_time = {'m600m300','p900p1200'};
    
    for cnd_time = 1:2
        
        sourceAppend{cnd_time} = [];
        
        for prt = 1:3
            
            fname = dir(['../data/source/' suj '.pt' num2str(prt) ...
                '*.CnD.*' ext_freq{:} '*' list_time{cnd_time} ...
                '*' cnd_filt{:} '*mat']);
            
            fname = fname.name;
            
            fprintf('Loading %50s\n',fname);
            
            load(['../data/source/' fname]);
            
            sourceAppend{cnd_time} = [ sourceAppend{cnd_time} source]; clear source ;
            
        end
    end
    
    load '../data/yctot/rt/rt_cond_classified.mat';
    fprintf('Calculating Correlation\n');
    
    nw_sourceAppend = (sourceAppend{2}-sourceAppend{1}) ./ sourceAppend{1} ;
    sourceAppend    = nw_sourceAppend;
    clear nw_sourceAppend ;
    
    for cond_cue = 1:3
        
        data        = sourceAppend(:,rt_indx{sb,cond_cue})';
        rt          = rt_classified{sb,cond_cue};
        [rho,p]     = corr(data,rt , 'type', 'Spearman');
        
        rhoM        = rho ;
        
        rhoF        = .5.*log((1+rho)./(1-rho));
        rhoMF       = .5.*log((1+rhoM)./(1-rhoM));
        
        source_avg{sb,cond_cue}.pow      = rhoF;
        
        load ../data/template/source_struct_template_MNIpos.mat
        
        source_avg{sb,cond_cue}.pos    = source.pos;
        source_avg{sb,cond_cue}.dim    = source.dim;
        source_avg{sb,cond_cue}.inside = source.inside;
        
        clear source rho*
        
    end
    
    clear sourceAppend nw_sourceAppend ;
    
end


clearvars -except source_avg

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
nsuj                    =   size(source_avg,1);
cfg.design(1,:)         =   [1:nsuj 1:nsuj];
cfg.design(2,:)         =   [ones(1,nsuj) ones(1,nsuj)*2];
cfg.uvar                =   1;
cfg.ivar                =   2;

stat{1}   =   ft_sourcestatistics(cfg,source_avg{:,3},source_avg{:,2});
stat{2}   =   ft_sourcestatistics(cfg,source_avg{:,3},source_avg{:,1});
stat{3}   =   ft_sourcestatistics(cfg,source_avg{:,2},source_avg{:,1});

for cond_s = 1:3
    [min_p(cond_s),p_val{cond_s}]   = h_pValSort(stat{cond_s});
end

for cond_s = 1:3
    vox_list{cond_s} = FindSigClusters(stat{cond_s},min_p(cond_s)+0.00001);
end


list_stat = {'RmL','RmU','LmU'};

for cond_s = 1:3
    
    stat_int{cond_s}          = h_interpolate(stat{cond_s});
    stat_int{cond_s}.cfg      = [];
    stat_int{cond_s}.mask     = stat_int{cond_s}.prob < min_p(cond_s)+0.00001;
    
    cfg                     = [];
    cfg.method              = 'slice';
    cfg.funparameter        = 'stat';
    cfg.maskparameter       = 'mask';
    %         cfg.nslices             = 16;
    %         cfg.slicerange          = [70 84];
    cfg.funcolorlim         = [-3 3];
    ft_sourceplot(cfg,stat_int{cond_s});clc;
    title(list_stat{cond_s})
end
