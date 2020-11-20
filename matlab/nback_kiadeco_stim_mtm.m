clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

addpath('../toolbox/sigstar-master/');

suj_list                            = [1:33 35:36 38:44 46:51];
allpeaks                            = [];

for nsuj = 1:length(suj_list)
    load(['J:/nback/peak/sub' num2str(suj_list(nsuj)) '.alphabeta.peak.package.mat']);
    allpeaks(nsuj,1)                = apeak; clear apeak;
    allpeaks(nsuj,2)                = bpeak; clear bpeak;
end

allpeaks(isnan(allpeaks(:,2)),2)  	= nanmean(allpeaks(:,2));

keep suj_list allpeaks

for nsuj = 1:length(suj_list)
    
    list_freq                     	= 5:30;
    
    list_lock                    	= {'1back' '2back'};
    pow                           	= [];
    
    for nfreq = 1:length(list_freq)
        for nlock = 1:length(list_lock)
            
            fname               	= ['J:/nback/kia/sub' num2str(suj_list(nsuj)) '.kiadecoding.firstortarget.' num2str(list_freq(nfreq)) 'Hz'];
            fname               	= [fname '.lockedon.' list_lock{nlock} '.nobsl.excl.auc.mat'];
            
            fprintf('loading %s\n',fname);
            load(fname);
            pow(nlock,nfreq,:)  	= scores; clear scores;
            
        end
    end
    i                               = 0;
    
    for nlock = 1:size(pow,1)
        
        freq                    	= [];
        freq.time               	= time_axis;
        freq.label                  = {'auc'};
        freq.freq               	= list_freq;
        freq.powspctrm            	= pow(nlock,:,:);
        freq.dimord               	= 'chan_freq_time';
        
        i                           = i + 1;
        alldata{nsuj,i}             = freq; clear freq;
        
        
    end
    
    keep alldata nsuj suj_list allpeaks
    
end

keep alldata

%%

cfg                                         = [];
cfg.statistic                               = 'ft_statfun_depsamplesT';
cfg.method                                  = 'montecarlo';
cfg.correctm                                = 'cluster';
cfg.clusteralpha                            = 0.05;
cfg.latency                                 = [0 1];
cfg.frequency                               = [5 30];
cfg.clusterstatistic                        = 'maxsum';
cfg.minnbchan                               = 0;
cfg.tail                                    = 0;
cfg.clustertail                             = 0;
cfg.alpha                                   = 0.025;
cfg.numrandomization                        = 1000;
cfg.uvar                                    = 1;
cfg.ivar                                    = 2;

nbsuj                                       = size(alldata,1);
[design,neighbours]                         = h_create_design_neighbours(nbsuj,alldata{1,1},'gfp','t');

cfg.design                                  = design;
cfg.neighbours                              = neighbours;

stat                                        = ft_freqstatistics(cfg, alldata{:,1}, alldata{:,2});
[min_p,p_val]                               = h_pValSort(stat);

%%

plimit                                      = 0.21;
stat.mask                                   = stat.prob < plimit;

cfg                                         = [];
cfg.colormap                                = brewermap(256, '*RdBu');
cfg.parameter                               = 'stat';
cfg.maskparameter                           = 'mask';
cfg.maskstyle                               = 'opacity';
cfg.maskalpha                               = 0.1;
cfg.zlim                                    = [-3 3];

subplot(2,2,1)
ft_singleplotTFR(cfg,stat);
title('1back v 2back');
ylabel(['p = ' num2str(round(min_p,2))]);
set(gca,'FontSize',14,'FontName', 'Calibri');

data_plot                                   = [];

for nsub = 1:size(alldata,1)
    for ncond = 1:size(alldata,2)
        
        t1                                  = find(round(alldata{nsub,ncond}.time,2) == round(stat.time(1),2));
        t2                                  = find(round(alldata{nsub,ncond}.time,2) == round(stat.time(end),2));
        
        f1                                  = find(round(alldata{nsub,ncond}.freq) == round(stat.freq(1)));
        f2                                  = find(round(alldata{nsub,ncond}.freq) == round(stat.freq(end)));
        
        vct_y                               = alldata{nsub,ncond}.powspctrm(:,f1:f2,t1:t2);
        vct_y                               = vct_y .* stat.mask;
        vct_y(vct_y == 0)                   = NaN;
        
        data_plot(nsub,ncond)               = nanmean(nanmean(vct_y));
        
        clear vct_y t1 t2 f1 f2
        
    end
end

mean_data                   = nanmean(data_plot,1);
bounds                      = nanstd(data_plot, [], 1);
bounds_sem                  = bounds ./ sqrt(size(data_plot,1));

subplot(2,2,2);
errorbar(mean_data,bounds_sem,'-ks');

xlim([0 3]);
xticks([1 2]);
xticklabels({'1back' '2back'});

ylim([0.4 0.6]);
yticks([0.4 0.6]);
hline(0.5,'--k');
set(gca,'FontSize',14,'FontName', 'Calibri');