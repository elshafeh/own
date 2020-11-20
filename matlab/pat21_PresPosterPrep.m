% poster and presentation prep

dleiftrip_addpath ;
clear ; clc ;
close all ;

load ../data/yctot/gavg/CnD5t18.mat ;
clear allsuj
load ../data/yctot/stat/Sensor4Corr.mat ;

cnd_s       = 1 ;
stat2plot   = h_plotStat(stat{cnd_s},0.05);

cfg                     = [];
cfg.xlim                = 0.2:0.2:1;
cfg.ylim                = [7 15];
cfg.zlim                = [-0.15 0.15];
cfg.layout              = 'CTF275.lay';
cfg.comment             = 'no';
cfg.colorbar            = 'no';
cfg.marker              = 'off';
ft_topoplotTFR(cfg,frqGA);

cfg                        = [];
cfg.latency                = [0.7 1];
cfg.frequency              = [11 15];
cfg.avgoverfreq            = 'yes';
cfg.avgovertime               = 'yes';
statslct                   = ft_selectdata(cfg,stat2plot); 

cfg                     = [];
cfg.xlim                = [0.7 1];
cfg.ylim                = [11 15];
cfg.zlim                = [-0.15 0.15];
cfg.layout              = 'CTF275.lay';
cfg.highlight           = 'on';
cfg.highlightchannel    =  find(statslct.powspctrm~=0);
cfg.highlightsymbol     = '.';
cfg.highlightcolor      = [0 0 0];
cfg.highlightsize       = 15;
cfg.comment             = 'no';
cfg.colorbar            = 'no';
subplot(2,2,1:2)
ft_topoplotTFR(cfg,frqGA);

lst_corr = {'MRO14', 'MRO24', 'MRP43', 'MRP54', 'MRP55', 'MRT15', 'MRT16', 'MRT25', 'MRT26', 'MRT27', 'MRT37';};

cfg             = [];
cfg.layout      = 'CTF275.lay';
cfg.xlim        = [0.7 1];
cfg.ylim        = [7 15];
cfg.zlim        = [-4.5 4.5];
cfg.channel     = lst_corr;
cfg.colorbar    = 'no';
subplot(2,2,3)
ft_singleplotTFR(cfg,stat2plot);
xlim([0.7 1]);
title('');

% cfg                     = [];
% cfg.layout              = 'CTF275.lay';
% cfg.xlim                = [0.7 1];
% cfg.ylim                = [7 15];
% cfg.zlim                = [-0.15 0.15];
% cfg.highlight           = 'on';
% cfg.highlightchannel    =  ix_chn;
% cfg.highlightsymbol     = '.';
% cfg.highlightcolor      = [0 0 0];
% cfg.highlightsize       = 15;
% cfg.comment             = 'no';
% cfg.marker              = 'off';
% ft_topoplotTFR(cfg,frqGA)
% load ../data/yctot/stat/Sensor4Corr.mat
%
% cnd_s = 1;
%
% stat2plot = h_plotStat(stat{s},0.05);
%
% cfg         = [];
% cfg.layout  = 'CTF275.lay';
% cfg.xlim    = 0.7:0.1:1.1;
% cfg.zlim    =
% ft_topoplotTFR(cfg,stat2plot)
%
% load ../data/yctot/PaperIAF_Freq.mat
%
% t = 3 ;
%
% cnd_time = {'bsl','early','late','post'};
%
% visAlpha1 =   bigassmatrix_freq(:,1,t,2);
% visAlpha2 =   bigassmatrix_freq(:,2,t,2);
% audAlpha1 =   bigassmatrix_freq(:,3,t,1);
% audAlpha2 =   bigassmatrix_freq(:,4,t,1);
% audAlpha3 =   bigassmatrix_freq(:,5,t,1);
% audAlpha4 =   bigassmatrix_freq(:,6,t,1);
% motAlpha1 =   bigassmatrix_freq(:,7,t,1);
% motAlpha2 =   bigassmatrix_freq(:,8,t,1);
% motAlpha3 =   bigassmatrix_freq(:,9,t,1);
% motAlpha4 =   bigassmatrix_freq(:,10,t,1);
%
% mean_viz =   mean(cat(2,visAlpha1,visAlpha2),2);
% mean_aud =   mean(cat(2,audAlpha1,audAlpha2,audAlpha3,audAlpha4),2);
%
% median_viz =   median(cat(2,visAlpha1,visAlpha2),2);
% median_aud =   median(cat(2,audAlpha1,audAlpha2,audAlpha3,audAlpha4),2);
%
% p_mean_va   = permutation_test([mean_viz mean_aud],1000);
% p_median_va = permutation_test([median_viz median_aud],1000);
%
% meanofmeans_v = median(mean_viz);
% meanofmeans_a = median(mean_aud);
%
% figure;
%
% boxplot([mean_viz mean_aud],'Labels',{'mean visual Alpha','mean auditory Alpha'});
% title([cnd_time{t} ' , p = ' num2str(round(p_mean_va,4))])
% ylim([6 16])
%
% saveFigure(gcf,'/Users/heshamelshafei/Google Drive/MyDrive/PhD/Publications/Papers/alpha2017/Figures/iaf_boxplot.svg');
%
% close all
%
% load ../data/yctot/gavg/CnD5t18.mat ;
%
% cfg=[];
% cfg.baseline = [-0.6 -0.2];
% cfg.baselinetype = 'relchange';
% frqGA = ft_freqbaseline(cfg,frqGA);
%
% clear allsuj
%
% load ../data/yctot/stat/Sensor4Corr.mat ;
%
% cnd_s = 1 ;
%
% [min_p(cnd_s),p_val{cnd_s}]         = h_pValSort(stat{cnd_s});
%
% stat2plot = h_plotStat(stat{cnd_s},0.05,'no');
%
% t1 = find(round(stat2plot.time,2) == round(0.9,2)) ;
% t2 = find(round(stat2plot.time,2) == round(1,2)) ;
% f1 = find(round(stat2plot.freq) == 11) ;
% f2 = find(round(stat2plot.freq) == 15) ;
%
% chn     = stat2plot.powspctrm(:,f1:f2,t1:t2);
% chn     = mean(mean(chn,3),2);
% ix_chn  = find(chn ~= 0);
%
% cfg                     = [];
% cfg.layout              = 'CTF275.lay';
% cfg.xlim                = [0.9 1];
% cfg.ylim                = [11 15];
% cfg.zlim                = [-0.15 0.15];
% cfg.highlight           = 'on';
% cfg.highlightchannel    =  ix_chn;
% cfg.highlightsymbol     = '.';
% cfg.highlightcolor      = [0 0 0];
% cfg.highlightsize       = 15;
% cfg.comment             = 'no';
% cfg.marker              = 'off';
% ft_topoplotTFR(cfg,frqGA)
%
% figure ;
%
% for a = 1:length(stat2plot.freq)
%
%     subplot(3,3,a)
%
%     cfg             = [];
%     cfg.layout      = 'CTF275.lay';
%     cfg.xlim        = [0.9 1];
%     cfg.ylim        = [stat2plot.freq(a) stat2plot.freq(a)];
%     cfg.zlim        = [-1.5 1.5];
%     cfg.comment     = 'no';
%     ft_topoplotTFR(cfg,stat2plot);
%
%     title([num2str(stat2plot.freq(a)) 'Hz']);
%
% end
%
% figure ;
%
% for a = 1:length(stat2plot.time)
%
%     subplot(3,2,a)
%
%     cfg             = [];
%     cfg.layout      = 'CTF275.lay';
%     cfg.xlim        = [stat2plot.time(a) stat2plot.time(a)];
%     cfg.zlim        = [-1.5 1.5];
%     cfg.comment     = 'no';
%     ft_topoplotTFR(cfg,stat2plot);
%
%     title([num2str(round(stat2plot.time(a)*1000)) 'ms']);
%
% end
%
% load ../data/yctot/PaperExtWav.mat
%
% for sb = 1:14
%
%     for cnd = 1:3
%
%         tmp = allsuj{sb,cnd}(:,:,:) ;
%
%         bt1 = find(round(template.time,2) == -0.6);
%         bt2 = find(round(template.time,2) == -0.4);
%
%         bsl = mean(tmp(:,:,bt1:bt2),3);
%         bsl = repmat(bsl,1,1,size(tmp,3));
%
%         tmp = (tmp-bsl)./ bsl ;
%
%         t1 = find(round(template.time,2) == -0.2);
%         t2 = find(round(template.time,2) == 2);
%
%         f1 = find(round(template.freq) == 7);
%         f2 = find(round(template.freq) == 15);
%
%         new_suj(sb,:,:,:,cnd) = tmp(:,f1:f2,t1:t2);
%
%         new_template.freq  = round(template.freq(f1:f2));
%         new_template.time  = template.time(t1:t2);
%         new_template.label = template.label;
%
%     end
%
% end
%
% clearvars -except new_suj new_template
%
% for chan = 1:6
%
%     avg = squeeze(mean(new_suj(:,chan,:,:,:),1));
%     avg = squeeze(mean(avg,1));
%
%     subplot(2,3,chan)
%
%     cnd_list = {'RCue','LCue','NCue'};
%
%     for cnd = 1:3
%         hold on
%         plot(new_template.time,avg(:,cnd))
%         ylim([-0.45 0.45])
%         xlim([-0.2 2])
%         ax = gca;
%         ax.XAxisLocation = 'origin';
%         ax.YAxisLocation = 'origin';
%         vline(1.2,'k--','');
%         vline(0.6,'k--','');
%         vline(1,'k--','');
%     end
%
%     title(new_template.label{chan})
%     legend(cnd_list)
%
% end
%
% saveFigure(gcf,'/Users/heshamelshafei/Google Drive/MyDrive/PhD/Publications/Papers/alpha2017/Figures/virtual_m200p2000s_avg7t15_scal4p5.svg');
%
% load ../data/yctot/gavg/CnD5t18.mat
% load ../data/yctot/stat/ActvBaseline4Neigh7t15Hz200t2000ms.mat
%
% freq            = frqGA ; clear frqGA ;
%
% [min_p , p_val] = h_pValSort(stat) ;
% stat2plot       = h_plotStat(stat,0.05,'no');
%
% time_list       = [0.2 0.6 1.4];
%
% i = 0 ;
%
% for f = 1%[9 13]
%     for t = 1%1:3
%
%         t_list = {'early','late','post'};
%
%         ix_f1 = find(round(stat2plot.freq) == round(f-1));
%         ix_f2 = find(round(stat2plot.freq) == round(f+1));
%
%         ix_t1 = find(round(stat2plot.time,2) == round(time_list(t),2));
%         ix_t2 = find(round(stat2plot.time,2) == round(time_list(t)+0.4,2));
%
%         ix_chn = [];
%
%         substat     = abs(stat2plot.powspctrm(:,ix_f1:ix_f2,ix_t1:ix_t2));
%
%         for hoho = 1:size(substat,1)
%             hihi  = squeeze(substat(hoho,:,:));
%             [x,y] = find(hihi == 0);
%             if length(x) < 20
%                 ix_chn = [ix_chn hoho];
%             end
%         end
%
%                 substat     = squeeze(mean(substat,2));
%                 substat     = mean(substat,2);
%                 ix_chn      = find(substat > 0.5);
%
%
%         i = i +1 ;
%
%                 subplot(2,3,i)
%
%         cfg                     = [];
%         cfg.layout              = 'CTF275.lay' ;
%         cfg.xlim                = [time_list(t) time_list(t)+0.4];
%         cfg.ylim                = [f-1 f+1] ;
%         cfg.zlim                = [-0.2 0.2] ;
%         cfg.highlight           = 'on';
%         cfg.highlightchannel    =  ix_chn;
%         cfg.highlightsymbol     = '.';
%         cfg.highlightcolor      = [0 0 0];
%         cfg.highlightsize       = 15;
%         cfg.comment             = 'no';
%         cfg.marker              = 'off';
%         cfg.colorbar            = 'yes';
%
%         ft_topoplotTFR(cfg,freq) ;
%
%
%
%     end
%
% end
%
% saveFigure(gcf,'/Users/heshamelshafei/Google Drive/MyDrive/PhD/Publications/Papers/alpha2017/Figures/colorbar.svg');
%
% lst{1}= {'MLC13', 'MLC14', 'MLC15', 'MLC16', 'MLC17', 'MLC22', 'MLC23', ...
%     'MLC24', 'MLC25', 'MLC31', 'MLC32', 'MLC41', 'MLC42', 'MLF46', 'MLF55', ...
%     'MLF56', 'MLF64', 'MLF65', 'MLF66', 'MLF67', 'MLP12', 'MLP23', 'MLP33', ...
%     'MLP34', 'MLP35', 'MLP44', 'MLP45', 'MLP56', 'MLP57', 'MLT11', 'MLT12', ...
%     'MLT13', 'MLT14', 'MLT15', 'MLT22', 'MLT23', 'MLT24', 'MLT32', 'MLT33', 'MLT34'};
%
%
% lst{2} = {'MLO11', 'MLO12', 'MLO13', 'MLO14', 'MLO21', 'MLO22', 'MLO23', ...
%     'MLO24', 'MLO31', 'MLO32', 'MLO33', 'MLO34', 'MLO41', ...
%     'MLO42', 'MLO43', 'MLO44', 'MLO51', 'MLO52', 'MLO53', ...
%     'MLP51', 'MLP52', 'MLP53', 'MRO11', 'MRO12', 'MRO13', ...
%     'MRO21', 'MRO22', 'MRO23', 'MRO24', 'MRO31', 'MRO32', ...
%     'MRO33', 'MRO41', 'MRO42', 'MRO43', 'MRO52', 'MRP51', ...
%     'MRP52', 'MRP53', 'MZO01', 'MZO02'};
%
% for a = 1:2
%
%     subplot(2,1,a)
%
%         cfg                     = [];
%         cfg.layout              = 'CTF275.lay' ;
%         cfg.xlim                = [-0.2 2];
%         cfg.ylim                = [7 15];
%         cfg.zlim                = [-0.2 0.2] ;
%         cfg.channel             = lst{a};
%         ft_singleplotTFR(cfg,freq);
%
%     h_Statcontour(stat,freq,h_indx_tf_labels(lst{a}))
%     hline(9,'k-','')
%     hline(13,'k-','')
%     vline(1.2,'k--','');
%     vline(0,'k--','');
%     xlim([-0.2 2]);
%     ylim([7 15]);
%     zlim([-0.2 0.2]);
%
% end
%
% saveFigure(gcf,'/Users/heshamelshafei/Google Drive/MyDrive/PhD/Publications/Papers/alpha2017/Figures/sens_m02p02.svg')
%
%
% sensor plot
%
% clear ; clc ;
%
% load ../data/yctot/tmp/4NeighBaselineStatm400m200.mat
%
% clear to_plot_stat ;
%
% statplot = h_plotStat(stat,0.05,'p','no');
%
% cfg             = [];
% cfg.layout      = 'CTF275.lay';
% cfg.xlim        = [0.2 0.6];
% cfg.ylim        = [12 14];
% cfg.zlim        = [-3 3];
% ft_topoplotTFR(cfg,statplot);
%
% list_lo = {'MLF56', 'MLF67', 'MLT12', 'MLT13', 'MLT14', 'MLT22', 'MLT23', 'MLT24', 'MLT33', 'MLT34', 'MLT42', 'MLT43'};
% list_hi = {'MLO11', 'MLO21', 'MLO22', 'MLO31', 'MLO41', 'MLO42', 'MRO11', 'MRO21', 'MRO22', 'MRO31', 'MRO41', 'MRO42'};
%
% load ../data/yctot/old/CnDtotandGavg.mat
%
% for sb = 1:14
%     cfg=[];
%     cfg.baseline=[-0.6 -0.2];
%     cfg.baselinetype='relchange';
%     allsuj{sb} = ft_freqbaseline(cfg,allsuj{1,1});
% end
%
% SensFreqGavg = ft_freqgrandaverage([],allsuj_GA_bsl{:});
%
% cfg             = [];
% cfg.layout      = 'CTF275.lay';
% cfg.xlim        = [-0.7 1.2];
% cfg.ylim        = [7 15];
% cfg.zlim        = [-0.15 0.15];
% cfg.channel     =  h_indx_tf_labels(list_lo);
% cfg.colorbar    = 'no';
% ft_singleplotTFR(cfg,SensFreqGavg);
% vline(0,'--k');
% hline(9,'--k');
% title('');
%
% sourCe plot
%
% load ../data/yctot/stat/sourceBasline_gavg_0.025p.mat
% load ../data/yctot/stat/source5mmBaselineStatFixed.mat
%
% load ../data/yctot/stat/sourceBasline_gavg.mat
%
% for cf = 1:2
%
%     for ct = 1:3
%
%         [min_p(cf,ct),p_val{cf,ct}] = h_pValSort(stat{cf,ct}); clc ;
%         vox_list{cf,ct} = FindSigClusters(stat{cf,ct},0.06); clc ;
%
%                 stat_int                = h_interpolate(stat{cf,ct});
%                 stat_int.mask           = stat_int.prob < 0.05;
%                 stat_int.stat           = stat_int.stat .* stat_int.mask;
%                 cfg                     = [];
%                 cfg.method              = 'slice';
%                 cfg.funparameter        = 'stat';
%                 cfg.maskparameter       = 'mask';
%                 cfg.nslices             = 1;
%                 cfg.slicerange          = [70 80];
%                 cfg.funcolorlim         = [-4 4];
%                 cfg.opacitymap          = 0.5;
%                 ft_sourceplot(cfg,stat_int);clc;
%
%     end
%
% end
%
% load ../data/yctot/stat/SensorCorrAgainstZeroSummary400t1200ms7t15Hz4Neigh.mat
%
% nw_stat     = stat{1} ;
% stat        = nw_stat ; clear nw_stat
%
% stat2plot = h_plotStat(stat,0.05,'no');
%
% [min_p,p_val] = h_pValSort(stat);
%
% for a = 1:length(stat.freq)
%
%     subplot(3,3,a)
%
%     cfg             = [];
%     cfg.layout      = 'CTF275.lay';
%     cfg.ylim        = [stat.freq(a) stat.freq(a)];
%     cfg.zlim        = [-2 2];
%     cfg.comment     = 'no';
%     ft_topoplotTFR(cfg,stat2plot);
%
%     title([num2str(stat.freq(a)) 'Hz']);
%
% end
%
% stat.mask   = stat.prob < 0.05 ;
% chn       = stat.mask .* stat.prob ;
% chn       = find(chn~=0);
% chn = stat.label(chn);
%
% load ../data/yctot/old/CnDtotandGavg.mat
%
% for sb = 1:14
%     cfg=[];
%     cfg.baseline=[-0.6 -0.2];
%     cfg.baselinetype='relchange';
%     allsuj_GA{sb} = ft_freqbaseline(cfg,allsuj_GA{sb});
% end
%
% SensFreqGavg    = ft_freqgrandaverage([],allsuj_GA{:});
%
% cfg                     = [];
% cfg.layout              = 'CTF275.lay';
% cfg.xlim                = [0.6 1];
% cfg.ylim                = [12 14];
% cfg.zlim                = [-0.15 0.15];
% cfg.highlight           = 'on';
% cfg.highlightchannel    =  chn;
% cfg.highlightsymbol     = '.';
% cfg.highlightcolor      = [1 0 0];
% cfg.highlightsize       = 25;
% cfg.comment = 'no';
% ft_topoplotTFR(cfg,SensFreqGavg);
%
%
% stat2plot = h_plotStat2(stat,p_val(1,1),p_val(1,3));
%
% stat2plot.powspctrm(stat2plot.powspctrm < 0) = 0 ;
%
% for p = 1:3
%
%     [x,y,z] = h_find3d(round(p_val(p),4),round(stat.prob,4));
%     x       = unique(x);
%     y       = unique(y);
%     z       = unique(z);
%
% end
%
% substat = squeeze(mean(stat2plot.powspctrm(:,ix_f1:ix_f2,ix_t1:ix_t2),2));
% substat = mean(substat,2);