clear;clc;dleiftrip_addpath;

cond = {'RCnD','LCnD','NCnD'};

suj_list = [1:4 8:17];

for a = 1:length(suj_list)
    
    suj = ['yc' num2str(suj_list(a))];
    
    for b = 1:length(cond)
        
        fname = ['../data/' suj '/tfr/' suj '.' cond{b} '.all.wav.5t18Hz.m4p4.mat'];
        fprintf('Loading %30s\n',fname);
        load(fname);
        
        cfg = [];
        cfg.baseline                = [-0.6 -0.2]; 
        cfg.baselinetype            = 'relchange';
        allsuj_GA{a,b}              = ft_freqbaseline(cfg,freq);
        
        clear freq cfg
        
    end
    
end

clearvars -except allsuj_GA ; clc ;

create_design_neighbours;

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
cfg.channel           = 'MEG';
cfg.latency           = [0.6 1.1];
cfg.frequency         = [7 15] ;
cfg.method            = 'montecarlo';     % Calculation of the significance probability
cfg.statistic         = 'ft_statfun_depsamplesFunivariate';    % T test
cfg.correctm          = 'cluster';        % MCP correction
cfg.clusteralpha      = 0.05;             % First Threshold
cfg.clusterstatistic  = 'maxsum';
cfg.minnbchan         = 4;
cfg.tail              = 0;
cfg.clustertail       = 0;
cfg.alpha             = 0.025;
cfg.numrandomization  = 1000;
cfg.neighbours        = neighbours;
cfg.clustercritval    = 0.05;
cfg.design            = design;
cfg.uvar              = 1;
cfg.ivar              = 2;
stat                  = ft_freqstatistics(cfg, allsuj_GA{:,1}, allsuj_GA{:,2},allsuj_GA{:,3});

[min_p,p_val] = h_pValSort(stat);

anova2plot_p = h_plotStat(stat,0.05,'no');

close all;

cfg                 = [];
cfg.layout          = 'CTF275.lay';
cfg.ylim            = [7 15];
cfg.zlim            = [-3 3];
cfg.xlim            = 0.6:0.1:1;
ft_topoplotTFR(cfg,anova2plot_p)

figure;
for f = 7:15
    
    subplot(3,3,f-6)
    
    cfg                 = [];
    cfg.layout          = 'CTF275.lay';
    cfg.ylim            = [f f];
    cfg.zlim            = [-3 3];
    cfg.comment         = 'no';
    ft_topoplotTFR(cfg,anova2plot_p)
    title([num2str(f) 'Hz']);
    
end

% for a = 1:2
%     for b = 1:length(frq_sub{a})
%         cfg = [];
%         cfg.layout = 'CTF275.lay' ;
%         cfg.zlim = [-2.5 2.5] ;
%         cfg.channel = chn_list{a,b};
%         figure;
%         ft_singleplotTFR(cfg,to_plot_stat);
%         vline(1.2,'k--','target');
%         title([frq_cnd{a} ' ' frq_sub{a}{b} '.png'])
%         saveFigure(gcf,['../plots/BaselineContrast/pres_prep/new_sens_' frq_cnd{a} '_' frq_sub{a}{b} '.png'])
%         close all;
%     end
% end