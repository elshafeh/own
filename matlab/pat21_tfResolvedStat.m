clear;clc;dleiftrip_addpath;

for f = 1:2
    
    for t = 10:18
        
        suj_list = [1:4 8:17];
        
        for sb = 1:14
            
            cond = {'RCnD','LCnD','NCnD'};
            suj = ['yc' num2str(suj_list(sb))] ;
            
            for c = 1:3
                
                fname_in = [suj '.' cond{c} '.tfResolved.9&13Hz.m700p1200ms.mat'];
                fprintf('Loading %50s \n',fname_in);
                load(['../data/' suj '/source/' fname_in])
                
                lm1 = find(round(tResolvedAvg.time,2) == -0.6);
                lm2 = find(round(tResolvedAvg.time,2) == -0.2);
                
                bsl = mean(tResolvedAvg.pow(:,f,lm1:lm2),3);
                
                load ../data/template/source_struct_template_MNIpos.mat
                
                tResolvedAvg.pow(:,f,t) = (tResolvedAvg.pow(:,f,t) - bsl) ./ bsl ;
                
                source_avg{sb,c}.pow        = tResolvedAvg.pow(:,f,t);
                source_avg{sb,c}.pos        = source.pos;
                source_avg{sb,c}.dim        = source.dim;
                source_avg{sb,c}.inside     = source.inside;
                
            end
            
        end
        
        cfg                     =   [];
        cfg.dim                 =   source.dim;
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
        
        stat{1}                 = ft_sourcestatistics(cfg,source_avg{:,1},source_avg{:,2}) ;
        stat{2}                 = ft_sourcestatistics(cfg,source_avg{:,1},source_avg{:,3}) ;
        stat{3}                 = ft_sourcestatistics(cfg,source_avg{:,2},source_avg{:,3}) ;
        
        cnd_freq = {'low','high'};
        cnd_stat = {'RL','RN','LN'};
        
        cnd_time = -0.7:0.1:1.2;
        
        for s = 1:3
            
            [min_p,p_val]   = h_pValSort(stat{s});
            allP{f,s,t}     = p_val;
            p_lim           = 0.1;
            
            if min_p < p_lim
                
                stat_int           = h_interpolate(stat{s});
                stat_int.mask      = stat_int.prob < p_lim;
                
                cfg                     = [];
                cfg.method              = 'slice';
                cfg.funparameter        = 'stat';
                cfg.maskparameter       = 'mask';
                cfg.nslices             = 16;
                cfg.slicerange          = [70 84];
                cfg.funcolorlim         = [-3 3];
                ft_sourceplot(cfg,stat_int);
                fname = [cnd_stat{s} '.' cnd_freq{f} '.' num2str(round(cnd_time(t),1)*1000)];
                title([fname ' p =' num2str(round(min_p,4))]);
                saveFigure(gcf,['../plots/tfstat/' fname '.png']);
                close all;
            end
            
        end
        
        clearvars -except t f min_p allP
        
    end
    
end

ClusterResults = {};

cnd_freq = {'low','high'};
cnd_stat = {'RL','RN','LN'};

cnd_time = -0.7:0.1:1.2;

ix = 0 ;

for x = 1:size(allP,1)
    for y = 1:size(allP,2)
        for z = 1:size(allP,3)
            if allP{x,y,z}(1,1) < 0.1
                ix = ix + 1;
                ClusterResults{ix,1} = cnd_freq{x};
                ClusterResults{ix,2} = cnd_stat{y};
                ClusterResults{ix,3} = num2str(cnd_time(z)*1000);
            end
        end
    end
end