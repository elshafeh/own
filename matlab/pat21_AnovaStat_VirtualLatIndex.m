clear ; clc ; close all ; dleiftrip_addpath ;

load ../data/yctot/RevFinalAdapt.mat

clearvars -except new_allsuj ; allsuj = new_allsuj ; clear new_allsuj ;

for sb = 1:14
    
    for cnd = 1:5
        
        lspctr = allsuj{sb,cnd}.powspctrm(:,[1 3 5 7],:,:);
        
        rspctr = allsuj{sb,cnd}.powspctrm(:,[2 4 6 8],:,:);
        
        latindx  = (rspctr-lspctr) ./ ((rspctr+lspctr)/2);
        
        spak    = 10 .* log(lspctr./rspctr);
        
        allsuj{sb,cnd}.powspctrm = latindx;
        
        allsuj{sb,cnd}.label = {'occ_sup','occ_mid','heschl','stg'};
        
        clear lspctr rspctr latindx spak
        
    end
    
    
    
end

for sb = 1:14
    for cnd = 1:5
        cfg                         = [];
        cfg.baseline                = [-0.6 -0.2];
        cfg.baselinetype            = 'relchange';
        allsuj_GA_bsl{sb,cnd}       = ft_freqbaseline(cfg,allsuj{sb,cnd});
    end
end

clearvars -except allsuj allsuj_GA_bsl ; clc ;

% allsuj_GA_bsl = allsuj;

cw          = {'bsl','early','late','post','entire','anticip'}; % cond_windows
cnd_band    =  {'loA1','loA2','hiA1','hiA2'};
cbl         = [-4 -2; -2 0;0 2 ; 2 4]; % ;[-4 -2; -2 0; 0 2;2 4];

ncnd        = 3;

for indx_t = 1:length(cw)
    
    figure;
    
    for boc = 1:length(cnd_band) % band of choice
        
        fprintf('Computing anova..\n');
        
        slid_win_size   = 0.1;
        slid_win_step   = 0.1;
        tim_win         = -0.6:slid_win_step:2;
        
        for chn = 1:length(allsuj_GA_bsl{1,1}.label)
            
            splot_order = 1:4:16;
            
            subplot(4,4,splot_order(chn)+boc-1);
            
            for tm = 1:length(tim_win)
                
                Y   = [];  S = [];
                F1  = []; F2 = [];
                
                for cnd = 1:ncnd
                    
                    for sb = 1:14
                        
                        fq_lm1 = find(round(allsuj_GA_bsl{sb,cnd}.freq) == round(9+cbl(boc,1)));
                        fq_lm2 = find(round(allsuj_GA_bsl{sb,cnd}.freq) == round(9+cbl(boc,2)));
                        
                        lm1 = find(round(allsuj_GA_bsl{sb,cnd}.time,2)==round(tim_win(tm),2));
                        lm2 = lm1 + (slid_win_size/0.05) ;
                        
                        if chn < 3
                            ixix = indx_t + (6*(2-1));
                        else
                            ixix = indx_t + (6*(1-1));
                        end
                        
                        Y   =   [Y; mean(nanmean(allsuj_GA_bsl{sb,cnd}.powspctrm(ixix,chn,fq_lm1:fq_lm2,lm1:lm2)))];
                        
                        S   =   [S;sb];
                        F1  =   [F1;cnd];
                        F2  =   [F2;1];
                        
                        jud = [Y F1];
                        
                    end
                    
                    anovaData(cnd,tm) = nanmean(jud(jud(:,2)==cnd,1));
                    
                end
                
                res                         =   PrepAtt2_rm_anova(Y,S,F1,F2,{'Cue','Freq'});
                anovaResults(1,tm)          =   res{2,6};
                
                clear res
                
            end
            
            lim_y1 = min(min(anovaData))-0.1;
            lim_y2 = max(max(anovaData))+0.1;
            
            for ni = 1:length(anovaResults)
                
                if ~isnan(anovaResults(1,ni)) && anovaResults(1,ni) < 0.05
                    indx_rect = tim_win(ni);
                    rectangle('Position',[indx_rect lim_y1 slid_win_size abs(lim_y1)+abs(lim_y2)],'FaceColor',[0.7 0.7 0.7]);
                end
                
                hold on;
                clrmap = 'brg';
                
                for cnd = 1:ncnd
                    plot_x = tim_win;
                    plot_y = anovaData(cnd,:);
                    plot(plot_x,plot_y,clrmap(cnd)); ylim([lim_y1 lim_y2]); xlim([-0.6 2]);
                end
                
                title([cnd_band{boc} ',' cw{indx_t}  ': ' allsuj_GA_bsl{sb,cnd}.label{chn}])
                vline(0,'--k');
                vline(1.2,'--k');
                hline(0,'-k');
                
            end
            
        end
        
    end
    
    
    fprintf('..may the p be with you\n');
    
end