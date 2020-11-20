clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

for sb = 1:14
    
    suj_list = [1:4 8:17];
    
    lst_cnd = {'CnD','LCnD','RCnD','NCnD'};
    lst_mth = {'canolty','tort','ozkurt','PLV'};
    lst_chn = {'audL','audR','RIPS3'};
    lst_tme = {'m1000m200','p200p1000'};
    
    suj     = ['yc' num2str(suj_list(sb))];
    
    for cnd = 1:length(lst_cnd)
        for chn = 1:length(lst_chn)
            for nmethod = 1:length(lst_mth)
                for ntime = 1:length(lst_tme)
                    
                    fname   = ['../data/all_data/' suj '.' lst_cnd{cnd} '.Rama3Cov.' lst_tme{ntime} '.' lst_chn{chn} '.' lst_mth{nmethod} 'PAC.mat'];
                    fprintf('Loading %30s\n',fname);
                    load(fname);
                    
                    grand_avg{sb,cnd,chn,nmethod,ntime}.powspctrm(1,:,:)    = mpac_norm;
                    grand_avg{sb,cnd,chn,nmethod,ntime}.freq                = mpac_index.amp_freq_vec;
                    grand_avg{sb,cnd,chn,nmethod,ntime}.time                = mpac_index.pha_freq_vec;
                    grand_avg{sb,cnd,chn,nmethod,ntime}.label               = {'MI'};
                    grand_avg{sb,cnd,chn,nmethod,ntime}.dimord              = 'chan_freq_time';
                    
                    clear mpac*
                    
                end
            end
        end
    end
end

clearvars -except grand_avg mpac_index lst_*; clc ;

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

ntotal                  = length(lst_cnd)*length(lst_chn)*length(lst_mth);
i                       = 0;
h_wait                  = waitbar(0,'Testing PAC');

for cnd = 1:length(lst_cnd)
    for chn = 1:length(lst_chn)
        for nmethod = 1:length(lst_mth)
            
            i = i + 1;
            waitbar(i/ntotal)
            stat{cnd,chn,nmethod}         = ft_freqstatistics(cfg,grand_avg{:,cnd,chn,nmethod,2}, grand_avg{:,cnd,chn,nmethod,1});
            stat{cnd,chn,nmethod}.label   = {[lst_cnd{cnd} ' ' lst_chn{chn} ' ' lst_mth{nmethod}]};
            
        end
    end
end

close(h_wait) ;

for cnd = 1:length(lst_cnd)
    for chn = 1:length(lst_chn)
        for nmethod = 1:length(lst_mth)
            [min_p(cnd,chn,nmethod),p_val{cnd,chn,nmethod}] = h_pValSort(stat{cnd,chn,nmethod});
        end
    end
end

for cnd = 1:length(lst_cnd)
    for chn = 1:length(lst_chn)
        for nmethod = 1:length(lst_mth)
            stat{cnd,chn,nmethod} = rmfield(stat{cnd,chn,nmethod},'cfg');
        end
    end
end

close all;

all_min_p = unique(squeeze(min_p));

for chn = 1:length(lst_chn)
    
    figure;
    i = 0 ;

    for cnd = 1:length(lst_cnd)
        for nmethod = 1:length(lst_mth)
            
            i = i + 1;
            
            stat{cnd,chn,nmethod}.mask  = stat{cnd,chn,nmethod}.prob < 0.2;
            
            subplot(4,4,i)
            cfg                         = [];
            cfg.parameter               = 'stat'; cfg.maskparameter           = 'mask';
            cfg.maskstyle               = 'outline';
            cfg.zlim                    = [-5 5];
            ft_singleplotTFR(cfg,stat{cnd,chn,nmethod});
            xlabel('Phase (Hz)'); ylabel('Amplitude (Hz)');
            
        end
    end
end