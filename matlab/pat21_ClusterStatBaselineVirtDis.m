clear ; clc ; dleiftrip_addpath ;

for a = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(a))];
    
    ext         =   'AudFrontal.VirtTimeCourse.all.wav.50t100Hz.m2000p1000.mat';
    lst         =   {'DIS','fDIS'};
    
    for d = 1:2
        fname_in    = ['../data/tfr/' suj '.'  lst{d} '.' ext];
        fprintf('\nLoading %50s \n',fname_in);
        load(fname_in)
        
        if isfield(freq,'hidden_trialinfo');
            freq = rmfield(freq,'hidden_trialinfo');
        end
        
        %         nw_chn  = [3 3;4 4;5 5; 6 6];
        %         nw_lst  = freq.label(3:6) ;
        %         nw_chn  = [3 5;4 6];
        %         nw_lst  = {'audL','audR'};
        %
        %         for l = 1:length(nw_lst)
        %             cfg             = [];
        %             cfg.channel     = nw_chn(l,:);
        %             cfg.avgoverchan = 'yes';
        %             nwfrq{l}        = ft_selectdata(cfg,freq);
        %             nwfrq{l}.label  = nw_lst(l);
        %         end
        %         cfg             = [];
        %         cfg.parameter   = 'powspctrm';
        %         cfg.appenddim   = 'chan';
        %         allsuj_GA{a,d}  = ft_appendfreq(cfg,nwfrq{:}); clear nwfrq
        %         cfg                 = [];
        %         cfg.baseline        = [-0.2 -0.1];
        %         cfg.baselinetype    = 'absolute';
        %         allsuj_GA{a,d}      = ft_freqbaseline(cfg,allsuj_GA{a,d});
        
        allsuj_GA{a,d}                = freq ;
        
        clear freq;
    end
end

clearvars -except allsuj_*

[design,neighbours] = h_create_design_neighbours(length(allsuj_GA),'eeg','t');
clear neighbours ;

for n = 1:length(allsuj_GA{1,1}.label)
    neighbours(n).label = allsuj_GA{1,1}.label{n};
    neighbours(n).neighblabel = {};
end

cfg                     = [];
cfg.clusterstatistic    = 'maxsum';cfg.method              = 'montecarlo';
cfg.statistic           = 'depsamplesT';cfg.correctm            = 'cluster';
cfg.clusteralpha        = 0.05;cfg.alpha               = 0.025;
cfg.minnbchan           = 0;cfg.tail                = 0;
cfg.clustertail         = 0;cfg.numrandomization    = 1000;
cfg.design              = design;cfg.neighbours          = neighbours;
cfg.uvar                = 1;cfg.ivar                = 2;
cfg.frequency           = [50 90] ;
cfg.latency             = [0.1 0.5] ;

for chn = 1:length(allsuj_GA{1,1}.label)
    cfg.channel                         = chn ;
    stat{chn}                           = ft_freqstatistics(cfg, allsuj_GA{:,1}, allsuj_GA{:,2});
    [min_p(chn),p_val{chn}]             = h_pValSort(stat{chn});
end

stat2plot               = h_plotStat(stat,0.5);

i = 0 ;
for chn = 1:length(stat2plot.label)
    i = i + 1;
    subplot(5,4,i)
    cfg             = [];
    cfg.channel     = chn;
    cfg.zlim        = [-4 4];
    ft_singleplotTFR(cfg,stat2plot);clc;
end

% f0      =   stat2plot.freq(1);
% f1      =   stat2plot.freq(end);
% t0      =   -0.2;
% t1      =   0.6;
%
% zlim ='maxabs';
%
% d_gavg{1}       = ft_freqgrandaverage([],allsuj_GA{:,1});
% d_gavg{2}       = ft_freqgrandaverage([],allsuj_GA{:,2});
%
% cfg             = [];
% cfg.parameter   = 'powspctrm';
% cfg.operation   = 'subtract';
% gavg = ft_math(cfg,d_gavg{1},d_gavg{2});
%
% for al = 0.5
%     figure;
%     tf_masked(gavg,stat,f0, f1,t0,t1,'audR',al,0.05,zlim);
%     set(gca,'fontsize',18)
%     set(gca,'FontWeight','bold')
%     vline(0,'--k')
%     vline(0.3,'--k')
%     title('');
% end