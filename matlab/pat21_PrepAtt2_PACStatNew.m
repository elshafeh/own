clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

for sb = 1:21
    
    suj         = ['yc' num2str(sb)];
    lst_cnd     = {'NLCnD','NRCnD','LCnD','RCnD'};
    
    lst_mth     = {'ozkurt','tort'};
    lst_chn     = {'audR'};
    lst_tme     = {'m1000m200','p200p1000'};
    
    
    for cnd = 1:length(lst_cnd)
        for chn = 1:length(lst_chn)
            for nmethod = 1:length(lst_mth)
                for ntime = 1:length(lst_tme)
                    
                    fname   = ['../data/new_rama_data/' suj '.' lst_cnd{cnd} '.NewRama3Cov.' lst_tme{ntime} '.' lst_chn{chn} '.' lst_mth{nmethod} '.AppendTrialPAC.mat'];
                    
                    fprintf('Loading %30s\n',fname);
                    load(fname);
                    
                    grand_avg{sb,cnd,chn,nmethod,ntime}.powspctrm(1,:,:)    = seymour_pac.mpac;
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
            stat{cnd,chn,nmethod}.label   = {[lst_chn{chn} '.' lst_mth{nmethod} '.' lst_cnd{cnd}]};
            
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


close all;

figure; 
i = 0 ;
for nmethod = 1:length(lst_mth)
    for cnd = 1:length(lst_cnd)
        for chn = 1:length(lst_chn)
            
            i = i + 1;
            
            stat{cnd,chn,nmethod}.mask  = stat{cnd,chn,nmethod}.prob < 0.1;
            
            subplot(2,4,i)
            cfg                         = [];
            cfg.parameter               = 'stat';
            cfg.maskparameter           = 'mask';
            cfg.maskstyle               = 'outline';
            cfg.zlim                    = [-2 2];
            ft_singleplotTFR(cfg,stat{cnd,chn,nmethod});
            title([stat{cnd,chn,nmethod}.label num2str(min_p(cnd,chn,nmethod))]);
            xlabel('Phase (Hz)'); ylabel('Amplitude (Hz)');
            
        end
    end
end
