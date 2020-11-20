clear ; clc ; dleiftrip_addpath ;

for a = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(a))];
    
    ext1        =   'CnD.SomaGammaNoAVGCoVm800p2000msfreq1t120Hz.all.wav.pow.4t120Hz.m3000p3000.mat';
    fname_in    =   ['../data/tfr/' suj '.'  ext1];
    
    fprintf('\nLoading %50s \n',fname_in);
    load(fname_in)
    
    if isfield(freq,'hidden_trialinfo')
        freq    = rmfield(freq,'hidden_trialinfo');
    end
    
    nw_pow = [];
    nw_lab = {};
    
    for i = 1:2:length(freq.label)
        nw_pow          = [nw_pow; mean(freq.powspctrm(i:i+1,:,:),1)];
        nw_lab{end+1}   = freq.label{i};
    end
    
    freq.powspctrm                          = nw_pow ; clear nw_pow ;
    freq.label                              = nw_lab ; clear nw_lab ;
    
    %     twin                                    = 0.2;
    %     tlist                                   = -3:twin:3;
    %     pow                                     = [];
    %
    %     for t = 1:length(tlist)
    %         x1  = find(round(freq.time,3) == round(tlist(t),3)); x2 = find(round(freq.time,3) == round(tlist(t)+twin,3));
    %         tmp = squeeze(mean(freq.powspctrm(:,:,x1:x2),3));
    %         pow = cat(3,pow,tmp);
    %         clear tmp ;
    %     end
    %
    %     freq.time                               = tlist;
    %     freq.powspctrm                          =pow; clear pow;
    
    cfg                                     = [];
    cfg.latency                             = [-0.2 2];
    allsuj_activation{a}                    = ft_selectdata(cfg, freq);
    
    cfg                                     = [];
    cfg.latency                             = [-0.2 -0.1];
    cfg.avgovertime                         = 'yes';
    allsuj_baselineAvg{a}                   = ft_selectdata(cfg, freq);
    allsuj_baselineRep{a}                   = allsuj_activation{a};
    allsuj_baselineRep{a}.powspctrm         = repmat(allsuj_baselineAvg{a}.powspctrm,1,1,size(allsuj_activation{a}.powspctrm,3));
    
    clear  allsuj_baselineAvg
    
end

clearvars -except allsuj_* gavg_suj

[design,neighbours]     = h_create_design_neighbours(length(allsuj_activation),allsuj_activation{1,1},'virt','t');

cfg                     = [];
cfg.clusterstatistic    = 'maxsum';
cfg.method              = 'montecarlo';
cfg.statistic           = 'depsamplesT';
% cfg.correctm            = 'cluster';
cfg.correctm            = 'fdr';
cfg.clusteralpha        = 0.05;
cfg.alpha               = 0.025;
cfg.minnbchan           = 0;
cfg.tail                = 0;
cfg.clustertail         = 0;
cfg.numrandomization    = 1000;
cfg.design              = design;
cfg.neighbours          = neighbours;
cfg.uvar                = 1;
cfg.ivar                = 2;
cfg.frequency           = [50 120];

stat                    = ft_freqstatistics(cfg, allsuj_activation{:}, allsuj_baselineRep{:});
stat                    = rmfield(stat,'cfg');
[min_p,p_val]           = h_pValSort(stat);
p_lim                   = 0.05;
stat2plot               = h_plotStat(stat,0.000000000000000000000000001,p_lim);
stat2plot.powspctrm     = squeeze(stat2plot.powspctrm);

% stat2plot.powspctrm(stat2plot.powspctrm>0) = 0;

group{1} = [31 32 75 76]; % auditory
group{2} = [3 4 39:44]; % visual
group{3} = 51:54; % motor;

for g = 1:length(group)
    
    figure;
    hold on;
    
    for chn = group{g}
        
        pow2plot = squeeze(mean(stat2plot.powspctrm(chn,:,:),2));
        plot(stat2plot.time,pow2plot,'LineWidth',4);
        xlim([stat2plot.time(1) stat2plot.time(end)]);
        ylim([-3 3]);
        hline(0,'-k');
        vline(0,'--k');
        vline(0.6,'--k');
        vline(1.2,'--k');
    end
    legend(stat2plot.label(group{g}))
    
end


% for g = 1:length(group)
%     figure;
%     i = 0 ;
%     for chn = group{g}
%         i = i + 1;
%         
%         if size(stat2plot.powspctrm,3) > 1
%             
%             cfg             =[];
%             cfg.channel     = chn;
%             cfg.zlim        = [-5 5];
%             subplot(length(group{g})/2,2,i);
%             ft_singleplotTFR(cfg,stat2plot);clc;
%             title(stat2plot.label{chn})
%             vline(0,'--k');
%             vline(0.6,'--k');
%             vline(1.2,'--k');
% 
%             %             vline(1.2,'--k');
%             %         else
%             %             plot(stat2plot.time,squeeze(stat2plot.powspctrm(chn,:)),'LineWidth',4);
%             %             xlim([stat2plot.time(1) stat2plot.time(end)]);
%             %             ylim([-5 5]);
%             
%         end
%         
%     end
% end


% stat2plot.powspctrm(stat2plot.powspctrm>0) = 0;
%
% clearvars -except allsuj_* gavg_suj stat stat2plot
%
% lst = dir('../images/soma.virtual/alpha/*png');
%
% for f = 1:length(stat2plot.freq)
%     avg_over_time_list{f}  ={};
%     avg_over_time_count(f)  =0;
% end
%
% for t = 1:length(stat2plot.time)
%     avg_over_freq_list{t}  ={};
%     avg_over_freq_count(t)  =0;
% end
%
% for chn = 1:length(lst)
%
%     chn_name = strsplit(lst(chn).name,'.png');
%     chn_name = chn_name{1};
%     ix       = find(strcmp(stat2plot.label,chn_name));
%     slct     = squeeze(stat2plot.powspctrm(ix,:,:));
%     pow      = mean(slct,2);
%     whr      = find(pow ==min(pow));
%     avg_over_time_list{whr}{end+1,1} = chn_name;
%     avg_over_time_count(whr) = avg_over_time_count(whr)+1;
%
%     pow      = slct(whr,:);
%     whn      = find(pow ==min(pow));
%
%     avg_over_freq_list{whn}{end+1} = chn_name;
%     avg_over_freq_count(whn) = avg_over_freq_count(whn) + 1;
%
% end
%
% clearvars -except allsuj_* gavg_suj stat stat2plot avg_over_*
%
% plot(round(stat2plot.freq),avg_over_time_count,'LineWidth',2);
% ylim([0 100]);
% ylabel('Region Count');
% xlabel('Peak Frequency Hz');
% vline(9,'--k');
% set(gca,'XAxisLocation','origin')
% set(gca,'fontsize',18)
% set(gca,'FontWeight','bold')
% figure;
% plot(stat2plot.time*1000,avg_over_freq_count,'LineWidth',2);
% ylabel('Region Count');
% xlabel('Peak Latency ms');
% set(gca,'XAxisLocation','origin')
% set(gca,'fontsize',18)
% set(gca,'FontWeight','bold')
%
% for p_lim               = 0.05
%     stat2plot             = h_plotStat(stat,0.000000000000000000000000001,p_lim);
%     stat2plot.powspctrm(stat2plot.powspctrm<0) = 0;
%
%     newstat               = stat2plot;
%     newstat.powspctrm     = squeeze(nanmean(newstat.powspctrm,3)); % avg over time ;
%
%     all_label = {};
%     figure;
%     hold on
%     for chn = 1:length(newstat.label)
%         ix = squeeze(newstat.powspctrm(chn,:));
%         if mean(mean(ix))~= 0
%             plot(newstat.freq,squeeze(newstat.powspctrm(chn,:)),'LineWidth',4);
%             xlim([newstat.freq(1) newstat.freq(end)]);
%             ylim([0 1]);
%             all_label{end+1} = newstat.label{chn};
%         end
%     end
%
%     legend(all_label)
%     title(['p = ' num2str(p_lim)]);
%
%     ix1 = find(round(stat2plot.freq) == 50);
%     ix2 = find(round(stat2plot.freq) == 70);
%
%     newstat               = stat2plot;
%     newstat.powspctrm     = squeeze(nanmean(newstat.powspctrm(:,ix1:ix2,:),2)); % avg over time ;
%
%     all_label = {};
%     chn = 1;
%     figure;
%     ix = squeeze(newstat.powspctrm(chn,:));
%     if mean(mean(ix))~= 0
%         plot(newstat.time,squeeze(newstat.powspctrm(chn,:)),'LineWidth',4);
%         xlim([newstat.time(1) newstat.time(end)]);
%         ylim([0 4]);
%         all_label{end+1} = newstat.label{chn};
%     end
%     legend(all_label)
%     title(['p = ' num2str(p_lim)]);
%
%     ix1 = find(round(stat2plot.freq) == 40);
%     ix2 = find(round(stat2plot.freq) == 80);
%
%     newstat               = stat2plot;
%     newstat.powspctrm     = squeeze(mean(newstat.powspctrm(:,ix1:ix2,:),2)); % avg over time ;
%
%     all_label = {};
%     chn = 2;
%     figure;
%     ix = squeeze(newstat.powspctrm(chn,:));
%     if mean(mean(ix))~= 0
%         plot(newstat.time,squeeze(newstat.powspctrm(chn,:)),'LineWidth',4);
%         xlim([newstat.time(1) newstat.time(end)]);
%         ylim([0 4]);
%         all_label{end+1} = newstat.label{chn};
%     end
%     legend(all_label)
%     title(['p = ' num2str(p_lim)]);
%
% end
%
% newstat             = stat2plot;
% newstat.powspctrm   = squeeze(mean(newstat.powspctrm,2)); % avg over freq ;
%
% all_label = {};
% figure;
% hold on
% for chn = 1:length(newstat.label)
%     ix = squeeze(newstat.powspctrm(chn,:));
%     if mean(mean(ix))~= 0
%         plot(newstat.time,squeeze(newstat.powspctrm(chn,:)),'LineWidth',4);
%         xlim([newstat.time(1) newstat.time(end)]);
%         ylim([0 1]);
%         all_label{end+1} = newstat.label{chn};
%     end
% end
% legend(all_label)
%
%
%
% figure;
% plot(stat2plot.time,squeeze(mean(stat2plot.powspctrm,2)),'LineWidth',4);
% xlim([stat2plot.time(1) stat2plot.time(end)]);
% ylim([0 2]);
% legend(stat2plot.label)
% for chn = 1:length(stat2plot.label)
%     ix = squeeze(stat2plot.powspctrm(chn,:));
%     if max(ix)~= 0
%         figure;
%         plot(stat2plot.freq,squeeze(stat2plot.powspctrm(chn,:)),'LineWidth',4);
%         xlim([stat2plot.freq(1) stat2plot.freq(end)]);
%         ylim([0 4]);
%         title(stat2plot.label{chn})
%
%         flg = find(ix == max(ix));
%         vline(stat2plot.freq(flg),'--k',[num2str(round(stat2plot.freq(flg))) 'Hz']);
%     end
% end
% new_stat2plot.label     = stat.label;
% new_stat2plot.dimord    = stat.dimord;
% new_stat2plot.freq      = stat.freq;
% new_stat2plot.time      = stat.time;
% new_mask                = (stat.stat < 0);
% new_stat2plot.powspctrm = stat.prob .* new_mask;
% new_stat2plot.powspctrm(new_stat2plot.powspctrm ==0)= NaN;
% gavg_act        = ft_freqgrandaverage([],allsuj_activation{:});
% gavg_bsl        = ft_freqgrandaverage([],allsuj_baselineRep{:});
% cfg             = [];
% cfg.operation   = '(x1-x2)./ x2';
% cfg.parameter   = 'powspctrm';
% gavg            = ft_math(cfg,gavg_act,gavg_bsl);
%
% cfg             = [];
% cfg.z           = [-4 4];
% ft_singleplotTFR(cfg,gavg)
% figure;
% for chn = 1:length(stat2plot)
%     subplot(4,2,chn)
%     plot(stat2plot{chn}.freq,squeeze(stat2plot{chn}.powspctrm),'LineWidth',4);
%     xlim([stat2plot{chn}.freq(1) stat2plot{chn}.freq(end)]);
%     ylim([-4 4]);
%     title(stat2plot{chn}.label)
% end