clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

suj_list                         	= [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    list_nback                   	= [0 1 2];
    list_cond                       = {'0back','1back','2Back'};
    
    list_cond                       = list_cond(list_nback+1);
    list_freq                       = 1:30;
    
    for nback = 1:length(list_nback)
        
        list_lock                   = {'target'};
        pow                         = [];
        
        for nlock = 1:length(list_lock)
            for nfreq = 1:length(list_freq)
                
                file_list         	= dir(['J:/temp/nback/data/stim_per_cond_mtm/sub' num2str(suj_list(nsuj)) '.sess*.' ...
                    num2str(list_nback(nback)) 'back.' num2str(list_freq(nfreq)) 'Hz.' list_lock{nlock} '.auc.mat']);
                
                tmp              	= [];
                
                for nfreq = 1:length(file_list)
                    fname         	= [file_list(nfreq).folder filesep file_list(nfreq).name];
                    fprintf('loading %s\n',fname);
                    load(fname);
                    tmp           	= [tmp;scores]; clear scores;
                end
                
                pow(nlock,nfreq,:) 	= nanmean(tmp,1); clear tmp;
                
            end
        end
        
        pow(isnan(pow))                         = 0;
        
        freq                                    = [];
        freq.time                               =  -1.5:0.02:2;
        freq.label                              = list_lock;
        freq.freq                               = list_freq;
        freq.powspctrm                          = pow;
        freq.dimord                             = 'chan_freq_time';
        
        if size(freq.powspctrm,1) ~= 2
            error('');
        end
        
        alldata{nsuj,nback}                     = freq; clear freq pow;
        
    end
end

keep alldata list_*;

nbsuj                       = size(alldata,1);
[~,neighbours]              = h_create_design_neighbours(nbsuj,alldata{1,1},'gfp','t');

cfg                         = [];
cfg.method                  = 'ft_statistics_montecarlo';
cfg.statistic               = 'ft_statfun_depsamplesFmultivariate';
cfg.correctm                = 'cluster';
cfg.clusteralpha            = 0.05;
cfg.clusterstatistic        = 'maxsum';
cfg.clusterthreshold        = 'nonparametric_common';
cfg.tail                     = 1; % For a F-statistic, it only make sense to calculate the right tail
cfg.clustertail             = cfg.tail;
cfg.alpha                   = 0.05;
cfg.computeprob             = 'yes';
cfg.numrandomization        = 1000;
cfg.neighbours              = neighbours;
cfg.latency                 = [0 1.5];
cfg.frequency               = [3 30];

design                      = zeros(2,3*nbsuj);
design(1,1:nbsuj)           = 1;
design(1,nbsuj+1:2*nbsuj)   = 2;
design(1,nbsuj*2+1:3*nbsuj) = 3;
design(2,:) = repmat(1:nbsuj,1,3);
cfg.design                  = design;
cfg.ivar                    = 1; % condition
cfg.uvar                    = 2; % subject number

stat                        = ft_freqstatistics(cfg, alldata{:,1}, alldata{:,2}, alldata{:,3});
[min_p,p_val]               = h_pValSort(stat);


subplot(2,3,1)
cfg                      	= [];
cfg.colormap              	= brewermap(256, 'Reds');
cfg.parameter             	= 'stat';
cfg.maskparameter         	= 'mask';
cfg.maskstyle             	= 'opacity';%'opacity';
cfg.maskalpha            	= 0.1;
cfg.zlim                    = [0 20];
ft_singleplotTFR(cfg,stat);
title('stim category anova');

subplot(2,3,2)
mn_freq                     = stat.stat .* stat.mask;
mn_freq                     = squeeze(mean(mn_freq,3));
plot(stat.freq,mn_freq,'k');
xlim(stat.freq([1 end]));
ylim([0 10]);
yticks([0 10]);
vline([5 7],'--r');

flist                       = [5 7];

for nfreq = 1:length(flist)
    
    fnd_freq_indata       	= find(alldata{1,1}.freq == flist(nfreq));
    fnd_freq_instat       	= find(stat.freq == flist(nfreq));
    
    fnd_mask                = squeeze(double(stat.mask(:,fnd_freq_instat,:)))';
    
    fnd_time                = stat.time .* fnd_mask;
    fnd_time                = fnd_time(fnd_time~=0);
    
    for nt = 1:length(fnd_time)
        fnd_time(nt)        = find(alldata{1,1}.time == fnd_time(nt));
    end
    
    data_plot               = [];
    
    for nsub = 1:size(alldata,1)
        for ncond = 1:size(alldata,2)
            data_plot(nsub,ncond)       = nanmean(alldata{nsub,ncond}.powspctrm(1,fnd_freq_indata,fnd_time));
        end
    end
    
    [h1,p1]                           	= ttest(data_plot(:,1),data_plot(:,2));
    [h2,p2]                           	= ttest(data_plot(:,1),data_plot(:,3));
    [h3,p3]                           	= ttest(data_plot(:,2),data_plot(:,3));
    
    mean_data                   = nanmean(data_plot,1);
    bounds                      = nanstd(data_plot, [], 1);
    bounds_sem                  = bounds ./ sqrt(size(data_plot,1));
    
    list_plot                   = [3 4];
    
    subplot(2,3,list_plot(nfreq));
    errorbar(mean_data,bounds_sem,'-ks');
    
    xlim([0 4]);
    xticks([1 2 3]);
    xticklabels({'0Back','1Back','2Back'});
    title(['0v1= ' num2str(round(p1,5)) ' 0v2= ' num2str(round(p2,5)) ' 1v2= ' num2str(round(p3,5))]);
    
    ylim([0.48 0.8]);
    yticks([0.48 0.8]);
    
end