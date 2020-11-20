clear ; clc ;  dleiftrip_addpath ;

for sb = 1:14
    
    suj_list = [1:4 8:17];
    
    suj = ['yc' num2str(suj_list(sb))];
    
    cnd_list = {'CnD','RCnD','LCnD','NCnD'};
    ext_mat = 'BigCov' ;
    
    for cnd = 1:length(cnd_list)
        
        ext1        =   [cnd_list{cnd} '.MaxAudVizMotor.' ext_mat '.VirtTimeCourse'];
        fname_in    =   ['../data/all_data/' suj '.'  ext1 '.all.wav.NewEvoked.1t20Hz.m3000p3000.mat'];
        
        fprintf('\nLoading %50s \n',fname_in); load(fname_in);
        
        if isfield(freq,'hidden_trialinfo')
            freq    = rmfield(freq,'hidden_trialinfo');
        end
        
        nw_chn  = [1 1;2 2; 3 5; 4 6];
        nw_lst  = {'Left Occipital','Right Occipital','Left Auditory','Right Auditory'};
        
        for l = 1:size(nw_chn,1)
            cfg             = [];
            cfg.channel     = nw_chn(l,:);
            cfg.avgoverchan = 'yes';
            nwfrq{l}        = ft_selectdata(cfg,freq);
            nwfrq{l}.label  = nw_lst(l);
        end
        
        cfg             = [];
        cfg.parameter   = 'powspctrm';cfg.appenddim   = 'chan';
        freq            = ft_appendfreq(cfg,nwfrq{:}); clear nwfrq
        
        cfg                         = [];
        cfg.baseline                = [-0.6 -0.2];
        cfg.baselinetype            = 'relchange';
        freq                        = ft_freqbaseline(cfg,freq);
        
        for nchan = 1:length(freq.label)
            
            load ../data/yctot/gavg/CnD_percentage_correct_gavg.mat
            
            allsuj_behav{sb,cnd,nchan,1} = sub_per{sb};
            
            load ../data/yctot/rt/rt_CnD_adapt.mat;
            
            new_mat = rt_all{sb};
            
            allsuj_behav{sb,cnd,nchan,2} = median(new_mat);
            allsuj_behav{sb,cnd,nchan,3} = mean(new_mat);
            
            clear rt_all sub_per
            
            allsuj_GA{sb,cnd,nchan}              = freq;
            allsuj_GA{sb,cnd,nchan}.powspctrm    = freq.powspctrm(nchan,:,:);
            allsuj_GA{sb,cnd,nchan}.label        = freq.label(nchan);
            
        end
    end 
end

clearvars -except allsuj_*

cfg                     = [];
cfg.method              = 'montecarlo';
cfg.latency             = [0.6 1.1];
cfg.frequency           = [7 15];
cfg.statistic           = 'ft_statfun_correlationT';
cfg.clusterstatistics   = 'maxsum';
cfg.correctm            = 'cluster';
cfg.clusteralpha        = 0.05;
cfg.tail                = 0;
cfg.clustertail         = 0;
cfg.alpha               = 0.025;
cfg.numrandomization    = 1000;
cfg.ivar                = 1;

corr_list               = {'Spearman'};

for ncue = 1:size(allsuj_GA,2)
    for nchan = 1:size(allsuj_GA,3)
        for ncorr = 1:length(corr_list)
            for nbehav = 1:size(allsuj_behav,4)
                
                cfg.type                                        = corr_list{ncorr};
                cfg.design(1,1:14)                              = [allsuj_behav{:,ncue,nchan,nbehav}];
                stat{ncue,nchan,ncorr,nbehav}                   = ft_freqstatistics(cfg, allsuj_GA{:,ncue,nchan});
                
            end
        end
    end
end

clearvars -except stat allsuj_*

for ncue = 1:size(stat,1)
    for nchan = 1:size(stat,2)
        for ncorr = 1:size(stat,3)
            for nbehav = 1:size(stat,4)
                [min_p(ncue,nchan,ncorr,nbehav),p_val{ncue,nchan,ncorr,nbehav}]             = h_pValSort(stat{ncue,nchan,ncorr,nbehav});
            end
        end
    end
end

clearvars -except stat allsuj_* min_p p_val

for ncue = 1:size(stat,1)
    
    figure;
    i = 0 ;
    
    for nchan = 1:size(stat,2)
        for ncorr = 1:size(stat,3)
            for nbehav = 1:size(stat,4)
                
                i = i + 1;
                
                stoplot       = stat{ncue,nchan,ncorr,nbehav};
                stoplot.mask  = stoplot.prob < 0.11;
                
                cnd_list = {'CnD','RCnD','LCnD','NCnD'};
                list_behav    = {'perCorrect ','medianRT ','meanRT '};
                
                subplot(size(stat,2),size(stat,4),i)
                
                cfg                         = [];
                cfg.parameter               = 'stat';
                cfg.maskparameter           = 'mask';
                cfg.maskstyle               = 'outline';
                cfg.zlim                    = [-2 2];
                ft_singleplotTFR(cfg,stoplot);
                title([cnd_list{ncue} ' ' stoplot.label{1} list_behav{nbehav} num2str(min_p(ncue,nchan,ncorr,nbehav))]);
              
                xlabel('Time (Sec)'); ylabel('Frequency (Hz)');
                
            end
        end
    end
end