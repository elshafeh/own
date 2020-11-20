clear ; clc ;  dleiftrip_addpath ;

for sb = 1:14
    
    suj_list = [1:4 8:17];
    
    suj = ['yc' num2str(suj_list(sb))];
    
    fname = ['../data/' suj '/tfr/' suj '.CnD.Paper.TimeCourse.KeepTrial.wav.5t18Hz.m4p4.mat'];
    
    load ../data/yctot/rt/rt_cond_classified.mat
    
    fprintf('Loading %30s\n',fname);
    load(fname);
    
    cfg                         = [];
    cfg.baseline                = [-0.6 -0.2];
    cfg.baselinetype            = 'relchange';
    freq                        = ft_freqbaseline(cfg,freq);
    
    cfg                 = [];
    cfg.channel         = 1:10;
    cfg.latency         = [0.9 1.1];
    cfg.avgovertime     = 'yes';
    cfg.frequency       = [7 15];
    freq                = ft_selectdata(cfg,freq);
    freq.time           = 0.9;
    
    for cnd = 1:3
        
        cfg         = [];
        cfg.trials  = rt_indx{sb,cnd};
        data_sub    = ft_selectdata(cfg,freq);
        
        fprintf('Calculating Correlation\n');
        
        for f = 1:length(data_sub.freq)
            
            data = squeeze(mean(data_sub.powspctrm(:,:,f,:),4));
            
            [rho,p]     = corr(data,rt_classified{sb,cnd} , 'type', 'Spearman');
            
            rhoF        = .5.*log((1+rho)./(1-rho));
            
            allsuj{sb,cnd}.powspctrm(:,f,1)   = rhoF  ;
            
            clear x1 x2 x3 rho*
            
        end
        
        allsuj{sb,cnd}.dimord       = 'chan_freq_time';
        allsuj{sb,cnd}.freq         = data_sub.freq;
        allsuj{sb,cnd}.time         = data_sub.time;
        allsuj{sb,cnd}.label        = data_sub.label ;
        
        clear data_sub
        
    end
    
    clear freq
    
    fprintf('Done\n');
    
    clear big_data
    
end

clearvars -except allsuj*; create_design_neighbours ;

neighbours = [];

for n = 1:length(allsuj{1,1}.label)
    neighbours(n).label = allsuj{1,1}.label{n};
    neighbours(n).neighblabel = [];
end

subj=14;
design=zeros(2,3*subj);
for i=1:subj
    design(1,i)=i;
end
for i=1:subj
    design(1,subj+i)=i;
end
for i=1:subj
    design(1,subj*2+i)=i;
end
design(2,1:subj)=1;
design(2,subj+1:2*subj)=2;
design(2,subj*2+1:3*subj)=3;

cfg                   = [];
cfg.latency           = 0.9;
cfg.frequency         = [8 15] ;
cfg.method            = 'montecarlo';    
cfg.statistic         = 'ft_statfun_depsamplesFunivariate';   
cfg.correctm          = 'cluster';
cfg.clusteralpha      = 0.05;             % First Threshold
cfg.clusterstatistic  = 'maxsum';
cfg.minnbchan         = 0;
cfg.tail              = 0;
cfg.clustertail       = 0;
cfg.alpha             = 0.025;
cfg.numrandomization  = 1000;
cfg.neighbours        = neighbours;
cfg.uvar              = 1;
cfg.ivar              = 2;
cfg.design            = design;
cfg.clustercritval    = 0.05;

anova   = ft_freqstatistics(cfg, allsuj{:,1}, allsuj{:,2}, allsuj{:,3});

[min_p_anova,p_val_anova]         = h_pValSort(anova);
corr2plot_anova                   = h_plotStat(anova,0.051,'no');

Summary_anova = [];
hi      = 0 ;

for c = 1:length(corr2plot_anova.label)
    for f = 1:length(corr2plot_anova.freq)
        for t = 1:length(corr2plot_anova.time)
            
            if ~isnan(corr2plot_anova.powspctrm(c,f,t))
                if corr2plot_anova.powspctrm(c,f,t) ~= 0
                    hi = hi + 1;
                    
                    Summary_anova(hi).chan = corr2plot_anova.label{c} ;
                    Summary_anova(hi).freq = round(corr2plot_anova.freq(f)) ;
                    Summary_anova(hi).time = corr2plot_anova.time(t) ;
                    
                    if corr2plot_anova.powspctrm(c,f,t) < 0
                        Summary_anova(hi).dire = '-ve';
                    else
                        Summary_anova(hi).dire = '+ve';
                    end
                end
                
            end
        end
    end
end

clearvars -except allsuj Summary_anova anova ; create_design_neighbours ;

neighbours = [];

for n = 1:length(allsuj{1,1}.label)
    neighbours(n).label = allsuj{1,1}.label{n};
    neighbours(n).neighblabel = [];
end

cfg                   = [];
cfg.latency           = 0.9;
cfg.frequency         = [8 15] ;
cfg.channel           = 4;
cfg.method            = 'montecarlo';    
cfg.statistic         = 'depsamplesT';   
cfg.correctm          = 'cluster';
cfg.clusteralpha      = 0.05;             % First Threshold
cfg.clusterstatistic  = 'maxsum';
cfg.minnbchan         = 0;
cfg.tail              = 0;
cfg.clustertail       = 0;
cfg.alpha             = 0.025;
cfg.numrandomization  = 1000;
cfg.neighbours        = neighbours;
cfg.uvar              = 1;
cfg.ivar              = 2;
cfg.design            = design;
stat{1}               = ft_freqstatistics(cfg, allsuj{:,3}, allsuj{:,2}); % RL
stat{2}               = ft_freqstatistics(cfg, allsuj{:,3}, allsuj{:,1}); % RN
stat{3}               = ft_freqstatistics(cfg, allsuj{:,2}, allsuj{:,1}); % LN

clearvars -except stat allsuj

for cnd_s = 1:length(stat)
    
    [min_p(cnd_s),p_val{cnd_s}]         = h_pValSort(stat{cnd_s});
    corr2plot{cnd_s}                    = h_plotStat(stat{cnd_s},0.05,'no');
    
end

clearvars -except stat allsuj Summary_anova anova allsuj min_p p_val corr2plot

cnd_title = {'RmL','RmU','LmU'};

for cnd_s = 1:length(stat)
    
    Summary = [];
    hi      = 0 ;
    
    for c = 1:length(corr2plot{cnd_s}.label)
        for f = 1:length(corr2plot{cnd_s}.freq)
            for t = 1:length(corr2plot{cnd_s}.time)
                
                if ~isnan(corr2plot{cnd_s}.powspctrm(c,f,t))
                    if corr2plot{cnd_s}.powspctrm(c,f,t) ~= 0
                        hi = hi + 1;
                        
                        Summary(hi).chan = corr2plot{cnd_s}.label{c} ;
                        Summary(hi).freq = round(corr2plot{cnd_s}.freq(f)) ;
                        Summary(hi).time = corr2plot{cnd_s}.time(t) ;
                        
                        if corr2plot{cnd_s}.powspctrm(c,f,t) < 0
                            Summary(hi).dire = '-ve';
                        else
                            Summary(hi).dire = '+ve';
                        end
                    end
                    
                end
            end
        end
    end
    
    ClusterSummary{cnd_s} = Summary ;
    
end

clearvars -except stat allsuj min_p p_val ClusterSummary

for sb = 1:14
    for cnd = 1:3
        source_avg(sb,cnd,:,:,:) = allsuj{sb,cnd}.powspctrm;
    end
end

clearvars -except stat allsuj min_p p_val ClusterSummary source_avg

c = 4 ;

for f = 1:9 ;
    
    x = squeeze(source_avg(:,1,c,f,:));
    y = squeeze(source_avg(:,2,c,f,:));
    z = squeeze(source_avg(:,3,c,f,:));
    
    figure; 
    
    boxplot([x y z],'labels',{'NCue','LCue','RCue'});ylim([-0.2 0.2]);
    
end


% clearvars -except stat allsuj min_p p_val ClusterSummary source_avg ; clc ;
% 
% fOUT = '../txt/CorrAnova.txt' ;
% fid  = fopen(fOUT,'W+');
% 
% fprintf(fid,'%5s\t%5s\t%5s\t%5s\t%5s\n','SUB','COND','CHAN','FREQ','CORR');
% 
% clear res
% 
% for frq = 2:8
%     
%     ii = 0 ;
%     
%     for chn = [4 6 8 10]
%         
%         ii = ii + 1;
%         
%         Y   = [];  S = [];
%         F1  = []; F2 = [];
%         
%         for sb = 1:14
%             for cnd = 1:3
%                 
%                 Y = [Y; source_avg(sb,cnd,chn,frq,2)];
%                 S   =   [S;sb];
%                 F1  =   [F1;cnd];
%                 F2  =   [F2;1];
%                 
%                 %                 list_cnd = {'NCue','LCue','RCue'};
%                 %
%                 %                 fprintf(fid,'%5s\t%5s\t%5s\t%5s\t%.3f\t\n',['yc' num2str(sb)],list_cnd{cnd},allsuj{1,1}.label{chn},[num2str(round(allsuj{1,1}.freq(frq))) 'Hz'],...
%                 %                     source_avg(sb,cnd,chn,frq,2));
%                 
%             end
%         end
%         
%         n = PrepAtt2_rm_anova(Y,S,F1,F2,{'Cue','n'});
%         res(frq-1,ii) =   n{2,6};
%     end
%     
% end
% 
% fclose(fid);
% 
% clear ppo ;
% 
% % f  = 10   ; f  = find(round(allsuj{1,1}.freq)   == f);
% % t  = 0.9 ; t    = find(round(allsuj{1,1}.time,2) == t);
% % c  = 4;
% % 
% % x = squeeze(source_avg(:,1,c,f,t));
% % y = squeeze(source_avg(:,2,c,f,t));
% % z = squeeze(source_avg(:,3,c,f,t));
% % 
% % boxplot([x y z],'labels',{'NCue','LCue','RCue'});ylim([-0.2 0.2]);