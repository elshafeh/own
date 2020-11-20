clear ; clc ; 

for sb = 1:14
    
    fprintf(['Treating YC' num2str(sb) '\n']);
    
    for cnd = 1:3
        
        for prt = 1:3
            
            list_suj = [1:4 8:17];
            suj      = ['yc' num2str(list_suj(sb))];
            list_cnd = {'RCnD','LCnD','NCnD'};
            
            load(['../data/' suj '/source/' suj '.pt' num2str(prt) '.' list_cnd{cnd} '.tfResolved.5t15Hz.m700p2000ms.mat']);
            
            list_time = tResolvedAvg.time ;
            list_freq = tResolvedAvg.freq ;
            
            t1 = find(round(tResolvedAvg.time,1) == -0.6);
            t2 = find(round(tResolvedAvg.time,1) == -0.2);
            
            bsl_prt         = repmat(mean(tResolvedAvg.pow(:,:,t1:t2),3),1,1,size(tResolvedAvg.pow,3));
            pow_prt_corr    = (tResolvedAvg.pow-bsl_prt)./bsl_prt;
            pow_prt_icor    = tResolvedAvg.pow;
            
            corr_carr{prt} = pow_prt_corr ;
            icor_carr{prt} = pow_prt_icor ;
            
            clear bsl_prt pow_prt_corr pow_prt_icor t1 t2 list_suj suj list_cnd tResolvedAvg
            
            
        end
        
        clear prt
        
        cnd_corr_befor  = mean(cat(4,corr_carr{:}),4);
        cnd_corr_after  = mean(cat(4,icor_carr{:}),4);
        
        t1 = find(round(list_time,1) == -0.6);
        t2 = find(round(list_time,1) == -0.2);
        
        bsl         	 = repmat(mean(cnd_corr_after(:,:,t1:t2),3),1,1,size(cnd_corr_after,3));
        cnd_corr_after   = (cnd_corr_after-bsl)./bsl;
        
        clear t1 t2 bsl corr_carr icor_carr
        
        source_avg{sb,cnd,1} = cnd_corr_befor ;
        source_avg{sb,cnd,2} = cnd_corr_after ;
        
        clear cnd_corr_befor cnd_corr_after source
        
    end
    
    clearvars -except source_avg sb list_time list_freq
    
end

for cnd_bsl = 1:2
    for freq = 1:3
        for time = 1:9
            
            nsuj                        =   size(source_avg,1);
            load ../data/template/source_struct_template_MNIpos.mat
            
            for sb  = 1:nsuj
                for cnd = 1:3
                    allsuj{sb,cnd}.pow = source_avg{sb,cnd,cnd_bsl}(:,freq,time);
                    allsuj{sb,cnd}.pos = source.pos ;
                    allsuj{sb,cnd}.dim = source.dim ;
                end
            end
            
            clear source
            
            cfg                         =   [];
            cfg.dim                     =   allsuj{1,1}.dim;
            cfg.method                  =   'montecarlo';
            cfg.statistic               =   'depsamplesT';
            cfg.parameter               =   'pow';
            cfg.correctm                =   'cluster';
            cfg.clusteralpha            =   0.05;             % First Threshold
            cfg.clusterstatistic        =   'maxsum';
            cfg.numrandomization        =   1000;
            cfg.alpha                   =   0.025;
            cfg.tail                    =   0;
            cfg.clustertail             =   0;
            cfg.design(1,:)             =   [1:nsuj 1:nsuj];
            cfg.design(2,:)             =   [ones(1,nsuj) ones(1,nsuj)*2];
            cfg.uvar                    =   1;
            cfg.ivar                    =   2;
            
            stat{cnd_bsl,freq,time,1}   = ft_sourcestatistics(cfg,allsuj{:,1},allsuj{:,2}); % RL
            stat{cnd_bsl,freq,time,2}   = ft_sourcestatistics(cfg,allsuj{:,1},allsuj{:,3}); % RN
            stat{cnd_bsl,freq,time,3}   = ft_sourcestatistics(cfg,allsuj{:,2},allsuj{:,3}); % LN
            
            clear allsuj
       
            for cnd_s = 1:3
                [min_p(cnd_bsl,freq,time,cnd_s),p_val{cnd_bsl,freq,time,cnd_s}] = h_pValSort(stat{cnd_bsl,freq,time,cnd_s});
            end
        end
    end
end

clearvars -except source_avg stat list_time list_freq min_p p_val

list_stat = {'RL','RN','LN'};
list_bsl  = {'before','after'};

Summary = [];
hi      = 0 ;

for cnd_bsl = 1:2
    for cnd_s = 1:3
        for freq = 1:3
            for time = 1:9
                
                if min_p(cnd_bsl,freq,time,cnd_s) < 0.05 && min_p(cnd_bsl,freq,time,cnd_s) > 0
                    
                    hi = hi + 1 ;
                    
                    Summary(hi).bsl     = list_bsl{cnd_bsl};
                    Summary(hi).freq    = list_freq(freq);
                    Summary(hi).time    = round(list_time(time),2)*1000;
                    Summary(hi).stat    = list_stat{cnd_s};
                    Summary(hi).min_p   = min_p(cnd_bsl,freq,time,cnd_s);
                    Summary(hi).p_list  = p_val{cnd_bsl,freq,time,cnd_s};
                    
                end
                
            end
        end
    end
end

clearvars -except source_avg stat list_time list_freq Summary min_p p_val

list_stat = {'RL','RN','LN'};
list_bsl  = {'before','after'};

for cnd_s = 1:3
    for cnd_bsl = 1:2
        for freq = 1:3
            for time = 1:9
                
                if min_p(cnd_bsl,freq,time,cnd_s) < 0.05 && min_p(cnd_bsl,freq,time,cnd_s) > 0
                    
                    stat_int        = h_interpolate(stat{cnd_bsl,freq,time,cnd_s});
                    stat_int.mask   = stat_int.prob < 0.05 ;
                    
                    cfg                     = [];
                    cfg.method              = 'slice';
                    cfg.funparameter        = 'stat';
                    cfg.maskparameter       = 'mask';
                    cfg.nslices             = 16;
                    cfg.slicerange          = [70 84];
                    cfg.funcolorlim         = [-3 3];
                    ft_sourceplot(cfg,stat_int);clc;
                    
                    title([list_bsl{cnd_bsl} ',' num2str(list_freq(freq)) 'Hz,' num2str(round(list_time(time),2)*1000) 'ms,' list_stat{cnd_s}])
                    saveFigure(gcf,['../plots/new_dics_2by2/' list_bsl{cnd_bsl} ',' num2str(list_freq(freq)) 'Hz,' ...
                        num2str(round(list_time(time),2)*1000) 'ms,' list_stat{cnd_s} '.png']);
                    
                    clear stat_int;
                    close all;
                    
                end
                
            end
        end
    end
end

for cnd_bsl = 1:2
    for freq = 1:3
        for time = 1:9
            stat{cnd_bsl,freq,time,1}.cfg =[];
            stat{cnd_bsl,freq,time,2}.cfg =[];
            stat{cnd_bsl,freq,time,3}.cfg =[];
        end
    end
end