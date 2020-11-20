for sb = 1:21
    
    suj         = ['yc' num2str(sb)];
    lst_cnd     = {'NLCnD','NRCnD','LCnD','RCnD'};
    
    lst_mth     = {'PLV','canolty','ozkurt','tort'};
    lst_chn     = {'audR'};
    lst_tme     = {'m1000m200','p200p1000'};
    
    
    for cnd = 1:length(lst_cnd)
        for chn = 1:length(lst_chn)
            for nmethod = 1:length(lst_mth)
                for ntime = 1:length(lst_tme)
                    
                    fname   = ['../data/new_rama_data/' suj '.' lst_cnd{cnd} '.NewRama3Cov.' lst_tme{ntime} '.' lst_chn{chn} '.' lst_mth{nmethod} 'PAC.mat'];
                    
                    fprintf('Loading %30s\n',fname);
                    load(fname);
                    
                    grand_avg{sb,cnd,chn,nmethod,ntime}.powspctrm(1,:,:)    = seymour_pac.mpac_norm;
                    grand_avg{sb,cnd,chn,nmethod,ntime}.freq                = seymour_pac.amp_freq_vec;
                    grand_avg{sb,cnd,chn,nmethod,ntime}.time                = seymour_pac.pha_freq_vec;
                    grand_avg{sb,cnd,chn,nmethod,ntime}.label               = {'MI'};
                    grand_avg{sb,cnd,chn,nmethod,ntime}.dimord              = 'chan_freq_time';
                    
                    clear seymour_pac
                    
                end
            end
        end
    end
end

clearvars -except grand_avg lst_* ; clc ; 

for sb = 1:size(grand_avg,1)
    for cnd = 1:size(grand_avg,2)
        for nchan = 1:size(grand_avg,3)
            for nmethod  =1:size(grand_avg,4)
                
                cfg             = [];
                cfg.operation = 'x1-x2';
                cfg.parameter = 'powspctrm';
                new_gavg{sb,cnd,nchan,nmethod} = ft_math(cfg,grand_avg{sb,cnd,nchan,nmethod,2},grand_avg{sb,cnd,nchan,nmethod,1});
                
            end
        end
    end
end

grand_avg = new_gavg ; clear new_gavg ;

clearvars -except grand_avg lst_* ; clc ; 

cfg                     = [];
cfg.latency             = [7 12];
cfg.frequency           = [50 100];
cfg.dim                 = grand_avg{1}.dimord;
cfg.method              = 'montecarlo';
cfg.statistic           = 'ft_statfun_depsamplesT';
cfg.parameter           = 'powspctrm';

cfg.correctm            = 'cluster';

cfg.computecritval      = 'yes';
cfg.numrandomization    = 1000;
cfg.alpha               = 0.025;
cfg.tail                = 0;
nsubj                   = size(grand_avg,1);
cfg.design(1,:)         = [1:nsubj 1:nsubj];
cfg.design(2,:)         = [ones(1,nsubj) ones(1,nsubj)*2];
cfg.uvar                = 1;
cfg.ivar                = 2;

for chn = 1:length(lst_chn)
    for nmethod = 1:length(lst_mth)
        
        stat{chn,nmethod,1}         = ft_freqstatistics(cfg,grand_avg{:,3,chn,nmethod}, grand_avg{:,1,chn,nmethod});
        stat{chn,nmethod,2}         = ft_freqstatistics(cfg,grand_avg{:,4,chn,nmethod}, grand_avg{:,2,chn,nmethod});
        
        stat{chn,nmethod,1}.label   =  {[lst_chn{chn} '.' lst_mth{nmethod} '.LvNL']};
        stat{chn,nmethod,2}.label   =  {[lst_chn{chn} '.' lst_mth{nmethod} '.RvNR']};

    end
end

for chn = 1:size(stat,1)
    for nmethod = 1:size(stat,2)
        for ntest = 1:size(stat,3)
            [min_p(chn,nmethod,ntest),p_val{chn,nmethod,ntest}] = h_pValSort(stat{chn,nmethod,ntest});
        end
    end
end

close all;

figure; 
i = 0 ;

for ntest = 1:size(stat,3)
    for chn = 1:size(stat,1)
        for nmethod = 1:size(stat,2)
            
            i = i + 1;
            
            stat{chn,nmethod,ntest}.mask    = stat{chn,nmethod,ntest}.prob < 0.05;
            
            subplot(2,4,i)
            cfg                             = [];
            cfg.parameter                   = 'stat';
            cfg.maskparameter               = 'mask';
            cfg.maskstyle                   = 'outline';
            cfg.zlim                        = [-2 2];
            
            ft_singleplotTFR(cfg,stat{chn,nmethod,ntest});
            
            title([stat{chn,nmethod,ntest}.label num2str(min_p(chn,nmethod,ntest))]);
            
            xlabel('Phase (Hz)'); ylabel('Amplitude (Hz)');
            
        end
    end
end

