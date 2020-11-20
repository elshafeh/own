clear ; clc ; dleiftrip_addpath ;

for sb = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))];
    
    ext1        =   'CnD.Rama3CoV.waveletPOW.1t139Hz.m3000p3000.AvgTrials.mat';
    fname_in    =   ['../data/all_data/' suj '.'  ext1];
    
    fprintf('\nLoading %50s \n',fname_in);
    load(fname_in)
    
    if isfield(freq,'hidden_trialinfo')
        freq    = rmfield(freq,'hidden_trialinfo');
    end
    
    %     load ../data/yctot/index/RamaAlphaFusion.mat ;
    
    cfg          = [];
    cfg.channel  = [1 2];% 6 7 8 9 10 11 12 13 14 15 16 17 20 23 24 26 44 45 52 53 54 55 56 74 75 76 77 82 83 92 93 97];
    freq         = ft_selectdata(cfg,freq);
    
    %     nw_pow = [];
    %     nw_lab = {};
    %     for i = 1:2:length(freq.label)
    %         nw_pow          = [nw_pow; mean(freq.powspctrm(i:i+1,:,:),1)];
    %         nw_lab{end+1}   = freq.label{i};
    %     end
    %     freq.powspctrm                          = nw_pow ; clear nw_pow ;
    %     freq.label                              = nw_lab ; clear nw_lab ;
    
    twin                                    = 0;
    tlist                                   = -3:twin:3;
    pow                                     = [];
    
    if twin ~=0
        for t = 1:length(tlist)
            x1  = find(round(freq.time,3) == round(tlist(t),3)); x2 = find(round(freq.time,3) == round(tlist(t)+twin,3));
            tmp = squeeze(mean(freq.powspctrm(:,:,x1:x2),3));
            pow = cat(3,pow,tmp);
            clear tmp ;
        end
        
        freq.time        =  tlist;
        freq.powspctrm   =  pow; clear pow;
    end
    
    lst_bsl          = [-0.6 -0.2; -0.4 -0.2; -0.2 -0.1];
    lst_frq          = [5 15; 16 48; 50 140];
    lst_act          = [-0.2 2; -0.2 2; -0.2 2];
    
    for ncond = 1:size(lst_bsl,1)
        [tmp_act{ncond},tmp_bsl{ncond}]   = h_prepareBaseline(freq,lst_bsl(ncond,:),lst_frq(ncond,:),lst_act(ncond,:),'non');
    end
    
    clearvars -except tmp* sb allsuj_*
    
    cfg                    = [];
    cfg.parameter          = 'powspctrm';
    allsuj_activation{sb}  = ft_appendfreq(cfg,tmp_act{:});
    allsuj_baselineRep{sb} = ft_appendfreq(cfg,tmp_bsl{:});
    clear tmp*;
    
end

clearvars -except allsuj_* gavg_suj

[design,neighbours]     = h_create_design_neighbours(length(allsuj_activation),allsuj_activation{1,1},'virt','t');

load ../data/yctot/index/RamaAlphaFusion.mat ;

cfg                     = [];
cfg.clusterstatistic    = 'maxsum';
cfg.method              = 'montecarlo';
cfg.statistic           = 'depsamplesT';
cfg.correctm            = 'fdr'; %cluster,fdr,bonferroni ;
cfg.clusteralpha        = 0.05;
cfg.alpha               = 0.025;

cfg.frequency           = [7 15];
cfg.latency             = [-0.2 1.2];

cfg.minnbchan           = 0;
cfg.tail                = 0;
cfg.clustertail         = 0;
cfg.numrandomization    = 1000;
cfg.design              = design;
cfg.neighbours          = neighbours;
cfg.uvar                = 1;
cfg.ivar                = 2;
stat                    = ft_freqstatistics(cfg, allsuj_activation{:}, allsuj_baselineRep{:});

stat                    = rmfield(stat,'cfg');
[min_p,p_val]           = h_pValSort(stat);

p_lim                   = 0.05;
stat2plot               = h_plotStat(stat,0.000000000000000000000000001,p_lim);

% ix1                    = find(round(stat2plot.freq)==20);
% ix2                    = find(round(stat2plot.freq)==40);
% close all;
% stat2plot.powspctrm(:,ix1:ix2,:) = 0;

for chn = 1:length(stat2plot.label)
    
    figure;
    
    cfg             = [];
    cfg.channel     = chn;
    %     cfg.xlim        = [0 2];
    %     cfg.ylim        = [5 15];
    cfg.zlim        = [-5 5];
    ft_singleplotTFR(cfg,stat2plot);clc;
    vline(1.2,'-k');
    vline(0,'-k');
    
end

% indx_aud                = 1:4;
% indx_occ                = [56:67 78:79];
% frq_list                = [8 12; 16 34; 50 76];

% for chn = 1:length(indx_aud)
%     subplot(2,2,chn)
%
%     cfg             = [];
%     cfg.channel     = chn;%['roi' num2str(indx_aud(chn))];
%     cfg.xlim        = [0 1.2];
%     cfg.ylim        = [5 100];
%     cfg.zlim        = [-4 4];
%     ft_singleplotTFR(cfg,stat2plot);clc;
%
%     title(final_rama_list{str2num(stat2plot.label{chn}(4:end)),2});
%
%     vline(1.2,'-k');
%     vline(0.6,'-k');
%
%     hline(8,'-k');
%     hline(12,'-k');
%     hline(16,'--k');
%     hline(34,'--k');
%     hline(50,'-k');
%     hline(76,'-k');
%
% end

% for f = 1:3
%     figure;
%     for chn = 1:length(indx_aud)
%         subplot(4,1,chn)
%
%         cfg             = [];
%         cfg.channel     = chn;%['roi' num2str(indx_aud(chn))];
%         cfg.xlim        = [0 2];
%         cfg.ylim        = frq_list(f,:);
%         cfg.zlim        = [-4 4];
%         ft_singleplotTFR(cfg,stat2plot);clc;
%
%         title(final_rama_list{str2num(stat2plot.label{chn}(4:end)),2});
%
%         vline(1.2,'-k');
%         vline(0.6,'-k');
%
%     end
% end

% figure;
% for chn = 1:length(indx_aud)
%     for f = 1:2
%         subplot(2,2,chn)
%
%         hold on;
%
%         i1              = find(round(stat2plot.freq) == frq_list(f,1));
%         i2              = find(round(stat2plot.freq) == frq_list(f,2));
%         i3              = chn;%find(strcmp(stat2plot.label,['roi' num2str(indx_aud(chn))]));
%         pow             = squeeze(mean(stat2plot.powspctrm(i3,i1:i2,:),2));
%
%         plot(stat2plot.time,pow,'LineWidth',2);
%         xlim([stat2plot.time(1) stat2plot.time(end)]);
%         ylim([-5 5]);
%         title(final_rama_list{str2num(stat2plot.label{chn}(4:end)),2});
%         vline(1.2,'-k');
%         vline(0.6,'-k');
%         hline(0,'-k');
%     end
%     legend({'alpha','beta','gamma'});
% end