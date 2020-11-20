clear ; clc ; dleiftrip_addpath ;

suj_list = [1:4 8:17];

for sb = 1:length(suj_list)
    
    suj = ['yc' num2str(suj_list(sb))];
    
    load(['../data/' suj '/source/' suj '.eeg.testpack.mat'])
    
    for t = 1:size(source,1)
        
        for f = 1:size(source,2)
            
            nw_src{sb,t,f}.pow = source{t,f}.pow;
            nw_src{sb,t,f}.pos = source{t,f}.pos;
            nw_src{sb,t,f}.dim = source{t,f}.dim;
            
            clear x y
            
        end
        
    end
    
    clear source
    
end

source_avg = nw_src ; clearvars -except source_avg

for t = 2:3
    
    for f = 1:2
        
        cfg                             =   [];
        cfg.inputcoord                  =   'mni';
        cfg.dim                         =   source_avg{1,1}.dim;
        cfg.method                      =   'montecarlo';
        cfg.statistic                   =   'depsamplesT';
        cfg.parameter                   =   'pow';
        cfg.correctm                    =   'cluster';
        cfg.clusteralpha                =   0.05;             % First Threshold
        cfg.clusterstatistic            =   'maxsum';
        cfg.numrandomization            =   1000;
        cfg.alpha                       =   0.025;
        cfg.tail                        =   0;
        cfg.clustertail                 =   0;
        cfg.design(1,:)                 =   [1:14 1:14];
        cfg.design(2,:)                 =   [ones(1,14) ones(1,14)*2];
        cfg.uvar                        =   1;
        cfg.ivar                        =   2;
        stat{t-1,f}                     =   ft_sourcestatistics(cfg,source_avg{:,t,f},source_avg{:,1,f}) ;
        stat{t-1,f}                     =   rmfield(stat{t-1,f} ,'cfg');
        [min_p(t-1,f),p_val{t-1,f}]     =   h_pValSort(stat{t-1,f});
        %         vox_list{t-1,f}                 =   FindSigClusters(stat{t-1,f},min_p(t-1,f)+0.01);clc;
    end
end

clearvars -except stat min_p p_val vox_list

for t = 1:2
    
    for f = 1:2
        
        stat_int{t,f}       = h_interpolate(stat{t,f});
        stat_int{t,f}.mask  = stat_int{t,f}.prob < 0.05 ;
        
        cfg                     = [];
        cfg.method              = 'slice';
        cfg.funparameter        = 'stat';
        cfg.maskparameter       = 'mask';
        cfg.nslices             = 16;
        cfg.slicerange          = [70 84];
        cfg.funcolorlim         = [-6 6];
        ft_sourceplot(cfg,stat_int{t,f});
        
    end
    
end