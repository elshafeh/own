clear ; clc ; close all ; dleiftrip_addpath ;

load('../data/yctot/SayWhatFinalFFT.mat'); %../data/yctot/SayWhatGaet5mmExtWav.mat % ../data/yctot/SayWhatGaetExtWav ../data/yctot/SayWhatFinalExtWav.mat

load('../data/yctot/serenIAF_BslCorrectMinMax.mat');

for sb = 1:14
    for cnd = 1:5
        cfg                         = [];
        cfg.baseline                = [-0.6 -0.2];
        cfg.baselinetype            = 'relchange';
        allsuj_GA_bsl{sb,cnd}       = ft_freqbaseline(cfg,allsuj{sb,cnd});
    end
end

clc;

cw      = {'bsl','early','late','post'}; % cond_windows

for indx_t  = 1 ;
    
    ncnd = 3;
    
    cnd_band = {'loA1','loA2','hiA1','hiA2'};
    
    cbl = [-4 -2; -2 0; 0 2;2 4];
    
    figure;
    ix_fig  = 0 ;
    
    for boc = 1:length(cnd_band) % band of choice
        
        slid_win_size   = 0.1;
        slid_win_step   = 0.1;
        tim_win         = -0.6:slid_win_step:2;
        
        for chn = 1:6
            
            ix_fig = ix_fig + 1;
            
            subplot(6,4,ix_fig);
            
            for tm = 1:length(tim_win)
                
                Y   = [];  S = [];
                F1  = []; F2 = [];
                
                for cnd = 1:ncnd
                    
                    for sb = 1:14
                        
                        if chn < 3
                            IAF = bigassmatrix_freq(5,chn,sb,indx_t,2);
                        else
                            IAF = bigassmatrix_freq(5,chn,sb,indx_t,1);
                        end
                        
                        fq_lm1 = find(round(allsuj_GA_bsl{sb,cnd}.freq) == round(IAF+cbl(boc,1)));
                        fq_lm2 = find(round(allsuj_GA_bsl{sb,cnd}.freq) == round(IAF+cbl(boc,2)));
                        
                        lm1 = find(round(allsuj_GA_bsl{sb,cnd}.time,2)==round(tim_win(tm),2));
                        lm2 = lm1 + (slid_win_size/0.05) ;
                        
                        Y   =   [Y; mean(nanmean(allsuj_GA_bsl{sb,cnd}.powspctrm(chn,fq_lm1:fq_lm2,lm1:lm2)))];
                        F1  =   [F1;cnd];
                        
                        jud = [Y F1];
                        
                    end
                    
                    anovaData(cnd,tm) = nanmean(jud(jud(:,2)==cnd,1));
                    anovaDataSTD(cnd,tm) = nanstd(jud(jud(:,2)==cnd,1));
                    anovaDataSEM(cnd,tm) = anovaDataSTD(cnd,tm) ./ sqrt(14);
                    
                end
            end
            
            clrmap = 'brg';
            
            for ii = 1:3
                hold on
                plot_mean_std(anovaData(ii,:),anovaDataSEM(ii,:),clrmap(ii),tim_win);
                xlim([-0.6 2]);
                ylim([-0.5 1]);
            end
            
        end
    end
end