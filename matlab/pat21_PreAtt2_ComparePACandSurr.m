clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

for sb = 1:14
    
    suj_list = [1:4 8:17];
    
    lst_cnd = {'CnD'};
    lst_mth = {'PLV','canolty','ozkurt','tort'};
    lst_chn = {'audL','audR'};
    lst_tme = {'period1','period2'};
    
    suj     = ['yc' num2str(suj_list(sb))];
    
    for cnd = 1:length(lst_cnd)
        for chn = 1:length(lst_chn)
            for nmethod = 1:length(lst_mth)
                for ntime = 1:length(lst_tme)
                    
                    fname   = ['../data/all_data/' suj '.' lst_cnd{cnd} '.Rama3Cov.' lst_tme{ntime} '.' lst_chn{chn} '.' lst_mth{nmethod} 'PAC.mat'];
                    fprintf('Loading %30s\n',fname);
                    load(fname);
                    
                    grand_avg{sb,cnd,chn,nmethod,ntime,1}.powspctrm(1,:,:)    = mpac;
                    grand_avg{sb,cnd,chn,nmethod,ntime,1}.freq                = mpac_index.amp_freq_vec;
                    grand_avg{sb,cnd,chn,nmethod,ntime,1}.time                = mpac_index.pha_freq_vec;
                    grand_avg{sb,cnd,chn,nmethod,ntime,1}.label               = {'MI'};
                    grand_avg{sb,cnd,chn,nmethod,ntime,1}.dimord              = 'chan_freq_time';
                    
                    grand_avg{sb,cnd,chn,nmethod,ntime,2}.powspctrm(1,:,:)    = mpac_surr;
                    grand_avg{sb,cnd,chn,nmethod,ntime,2}.freq                = mpac_index.amp_freq_vec;
                    grand_avg{sb,cnd,chn,nmethod,ntime,2}.time                = mpac_index.pha_freq_vec;
                    grand_avg{sb,cnd,chn,nmethod,ntime,2}.label               = {'MI'};
                    grand_avg{sb,cnd,chn,nmethod,ntime,2}.dimord              = 'chan_freq_time';
                    
                    clear mpac*
                    
                end
            end
        end
    end
end

clearvars -except grand_avg mpac_index ; clc ;

cfg                     = [];
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

ntotal                  = 2*2*4;
i                       = 0;
h_wait                  = waitbar(0,'Testing PAC');

for cnd = 1
    for chn = 1:2
        for nmethod = 1:4
            for ntime = 1:2
                
                i = i + 1;
                waitbar(i/ntotal)
                
                lst_mth                                     = {'PLV','canolty','ozkurt','tort'};
                lst_chn                                     = {'audL','audR'};
                lst_tme                                     = {'periodBSL','periodACT'};
                
                stat{cnd,chn,nmethod,ntime}                 = ft_freqstatistics(cfg,grand_avg{:,cnd,chn,nmethod,ntime,1}, grand_avg{:,cnd,chn,nmethod,ntime,2});
                stat{cnd,chn,nmethod,ntime}.label           = {[lst_tme{ntime} ' ' lst_chn{chn} ' ' lst_mth{nmethod}]};
                
            end
        end
    end
end

close(h_wait) ;

clearvars -except grand_avg stat ;

for cnd = 1
    for chn = 1:2
        for nmethod = 1:4
            for ntime = 1:2
            [min_p(cnd,chn,nmethod,ntime),p_val{cnd,chn,nmethod,ntime}] = h_pValSort(stat{cnd,chn,nmethod,ntime});
            end
        end
    end
end

clearvars -except grand_avg stat min_p p_val; close all;

for ntime = 1:2
    
    figure; i = 0 ;
    
    for cnd = 1
        for chn = 1:2
            for nmethod = 1:4
                
                i = i + 1;
                
                stat{cnd,chn,nmethod,ntime}.mask    = stat{cnd,chn,nmethod,ntime}.prob < 0.13;
                
                subplot(2,4,i)
                cfg                                 = [];
                cfg.parameter                       = 'stat'; cfg.maskparameter           = 'mask';
                cfg.maskstyle                       = 'outline';
                cfg.zlim                            = [-80 80];
                ft_singleplotTFR(cfg,stat{cnd,chn,nmethod,ntime});
                xlabel('Phase (Hz)'); ylabel('Amplitude (Hz)');
                
            end
        end
    end
end