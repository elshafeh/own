clear ; clc ;  dleiftrip_addpath ;

for sb = 1:14
    
    suj_list = [1:4 8:17];
    
    suj = ['yc' num2str(suj_list(sb))];
    
    %     fname = ['../data/' suj '/tfr/' suj '.CnD.Motor.TimeCourse.KeepTrial.wav.5t18Hz.m4p4.mat'];
    
    fname = ['../data/' suj '/tfr/' suj '.CnD.postConn.TimeCourse.kt.wav.5t18Hz.m3p3.mat'];
    
    fprintf('Loading %30s\n',fname);
    load(fname);
    
    cfg             = [];
    cfg.channel     = [1:18];
    data_sub        = ft_selectdata(cfg,freq);
    
    %     data_sub = freq ;
    
    clear freq fname suj
    
    load ../data/yctot/rt/rt_CnD_adapt.mat
    
    frq_list = 7:15;
    tim_win  = 0.2;
    tm_list  = [-0.4 0.7:tim_win:0.9];
    
    fprintf('Calculating Correlation\n');
    
    for t = 1:length(tm_list)
        
        for f = 1:length(frq_list)
            
            x1 = find(round(data_sub.time,2) == round(tm_list(t),2)) ; 
            
            if t == 1
                x2 = find(round(data_sub.time,2) == round(tm_list(t)+0.2,2)) ;
            else
                x2 = find(round(data_sub.time,2) == round(tm_list(t)+tim_win,2)) ;
            end
            
            x3 = find(round(data_sub.freq) == round(frq_list(f)));
            
            data = nanmean(data_sub.powspctrm(:,:,x3,x1:x2),4);
            
            [rho,p]     = corr(data,rt_all{sb} , 'type', 'Spearman');
            
            rho_mask    = p < 0.05 ;
            
            rhoM        = rho .* rho_mask ;
            
            rhoF        = .5.*log((1+rho)./(1-rho));
            rhoMF       = .5.*log((1+rhoM)./(1-rhoM));
            
            if t == 1
                allsuj{sb,2}.powspctrm(:,f,t:length(tm_list)-1)  = repmat(rhoF,1,1,length(t:length(tm_list)-1)) ;
                allsuj{sb,4}.powspctrm(:,f,t:length(tm_list)-1)  = repmat(rhoMF,1,1,length(t:length(tm_list)-1)) ;
            else
                allsuj{sb,1}.powspctrm(:,f,t-1)                  = rhoF;
                allsuj{sb,3}.powspctrm(:,f,t-1)                  = rhoMF;
            end
            
            clear x1 x2 x3 data rho*
            
        end
        
    end
    
    for cnd = 1:4
        
        allsuj{sb,cnd}.dimord       = 'chan_freq_time';
        allsuj{sb,cnd}.freq         = frq_list;
        allsuj{sb,cnd}.time         = tm_list(2:end);
        allsuj{sb,cnd}.label        = data_sub.label ;
        
    end
    
    fprintf('Done\n');
    
    clear tmp data
    
end

clearvars -except allsuj*; 

ntest = 0;

for c = 1:length(allsuj{1,1}.label)
    for f = 1:length(allsuj{1,1}.freq)
        for t = 1:length(allsuj{1,1}.time)
            ntest = ntest + 1;
        end
    end
end

clearvars -except allsuj* ntest; 

Summary = [];
hi      = 0 ;
n       = 0 ;

for c = 1:length(allsuj{1,1}.label)
    for f = 1:length(allsuj{1,1}.freq)
        for t = 1:length(allsuj{1,1}.time)
            
            n = n + 1;
            
            x = [];
            y = [];
            
            for sb = 1:14
                x = [x; allsuj{sb,1}.powspctrm(c,f,t)];
                y = [y; allsuj{sb,2}.powspctrm(c,f,t)];
            end
            
            fprintf('Computing Test %4d out of %4d\n',n,ntest);
            
            p = permutation_test([x y],1000);
            
            if p < 0.05 && p ~= 0
                
                hi = hi + 1;
                Summary(hi).chan    = allsuj{sb,1}.label{c} ;
                Summary(hi).freq    = allsuj{sb,1}.freq(f) ;
                Summary(hi).time    = allsuj{sb,1}.time(t) ;
                Summary(hi).Actv    = median(x);
                Summary(hi).Bsl     = median(y);
                Summary(hi).dire    = median(x) - median(y) ;
                Summary(hi).p       = p ;
                
            end
            
        end
    end
end

clearvars -except Summary allsuj ntest ;

Summary = struct2table(Summary);

% create_design_neighbours ;
% 
% neighbours = [];
% 
% for n = 1:length(allsuj{1,1}.label)
%     neighbours(n).label = allsuj{1,1}.label{n};
%     neighbours(n).neighblabel = [];
% end
% 
% cfg                   = [];
% cfg.latency           = [0.7 1.1];
% cfg.frequency         = [8 15];
% cfg.method            = 'montecarlo';     % Calculation of the significance probability
% cfg.statistic         = 'depsamplesT';    % T test
% cfg.correctm          = 'cluster';        % MCP correction
% cfg.clusteralpha      = 0.05;             %%%% First Threshold %%%%
% cfg.clusterstatistic  = 'maxsum';
% cfg.minnbchan         = 0;
% cfg.tail              = 0;
% cfg.clustertail       = 0;
% cfg.alpha             = 0.025;
% cfg.numrandomization  = 1000;
% cfg.design            = design;
% cfg.neighbours        = neighbours;
% cfg.uvar              = 1;
% cfg.ivar              = 2;
% 
% stat{1}                 = ft_freqstatistics(cfg, allsuj{:,1}, allsuj{:,2});
% stat{2}                 = ft_freqstatistics(cfg, allsuj{:,3}, allsuj{:,4});
% 
% for cnd_s = 1:2   
%     [min_p(cnd_s),p_val{cnd_s}]         = h_pValSort(stat{cnd_s});
%     corr2plot{cnd_s}                    = h_plotStat(stat{cnd_s},0.11,'no');
% end
% 
% for cnd_s = 1:2
%     
%     Summary = [];
%     hi      = 0 ;
%     
%     for c = 1:length(corr2plot{cnd_s}.label)
%         for f = 1:length(corr2plot{cnd_s}.freq)
%             for t = 1:length(corr2plot{cnd_s}.time)
%                 
%                 if corr2plot{cnd_s}.powspctrm(c,f,t) ~= 0
%                     hi = hi + 1;
%                     Summary(hi).chan = corr2plot{cnd_s}.label{c} ;
%                     Summary(hi).freq = corr2plot{cnd_s}.freq(f) ;
%                     Summary(hi).time = corr2plot{cnd_s}.time(t) ;
%                     
%                     if corr2plot{cnd_s}.powspctrm(c,f,t) < 0
%                         Summary(hi).dire = '-ve';
%                     else
%                         Summary(hi).dire = '+ve';
%                     end
%                     
%                 end
%             end
%         end
%     end
%     
%     ClusterSummary{cnd_s} = Summary ;
%     
% end