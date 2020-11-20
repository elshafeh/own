clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

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
    
    list_freq                     	= 2:30;
    
    list_lock                    	= {'first.dwn70' 'target.dwn70'}; %{'0back' '1back' '2back'}; % 'all.dwn70' 
    
    pow                           	= [];
    
    for nfreq = 1:length(list_freq)
        for nlock = 1:length(list_lock)
            
            %             fname               	= ['J:/nback/sens_level_auc/cond/sub' num2str(suj_list(nsuj)) '.decoding.' list_lock{nlock} '.agaisnt.all.' ...
            %                 num2str(list_freq(nfreq)) 'Hz.lockedon.target.dwn70.bsl.excl.auc.mat'];
            
            fname               	= ['J:/nback/sens_level_auc/cond/sub' num2str(suj_list(nsuj)) '.decoding.1Bv2B.' ...
                num2str(list_freq(nfreq)) 'Hz.lockedon.' list_lock{nlock} '.bsl.excl.auc.mat'];
            
            fprintf('loading %s\n',fname);
            load(fname);
            pow(nlock,nfreq,:)  	= scores; clear scores;
        end
    end
    
    list_peak                       = [allpeaks(nsuj,1) allpeaks(nsuj,2)];
    list_width                      = [1 2];
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
    
    %     i                               = i + 1;
    %     alldata{nsuj,i}                 = alldata{nsuj,2};
    %
    %     pow                             = alldata{nsuj,2}.powspctrm;
    %
    %     rnd_vct                         = 0.495:0.0001:0.505;
    %
    %     for nc = 1:size(pow,1)
    %         for nf = 1:size(pow,2)
    %             for nt = 1:size(pow,3)
    %                 pow(nc,nf,nt)       = rnd_vct(randi(length(rnd_vct)));
    %             end
    %         end
    %     end
    %
    %     alldata{nsuj,i}.powspctrm       = pow;
    
    keep alldata nsuj suj_list allpeaks
    
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

nbcon                       = size(alldata,2);

design                      = zeros(2,nbcon*nbsuj);
design(1,1:nbsuj)           = 1;
design(1,nbsuj+1:2*nbsuj)   = 2;
design(1,nbsuj*2+1:3*nbsuj) = 3;
design(2,:) = repmat(1:nbsuj,1,nbcon);

cfg.design                  = design;
cfg.ivar                    = 1; % condition
cfg.uvar                    = 2; % subject number

stat                        = ft_freqstatistics(cfg, alldata{:,1}, alldata{:,2}, alldata{:,3});
% stat                        = ft_freqstatistics(cfg, alldata{:,1}, alldata{:,2});

[min_p,p_val]               = h_pValSort(stat);


subplot(2,3,1)
cfg                      	= [];
cfg.colormap              	= brewermap(256, 'Reds');
cfg.parameter             	= 'stat';
cfg.maskparameter         	= 'mask';
cfg.maskstyle             	= 'opacity';%'opacity';
cfg.maskalpha            	= 0.1;
% cfg.zlim                    = [0 20];
ft_singleplotTFR(cfg,stat);
title('condition anova');

subplot(2,3,2)
mn_freq                     = stat.stat .* stat.mask;
mn_freq                     = squeeze(mean(mn_freq,3));
plot(stat.freq,mn_freq,'k');
xlim(stat.freq([1 end]));
% ylim([0 20]);
% yticks([0 20]);

flist                       = [4 8 11 20];

for nfreq = 1:length(flist)
    
    fnd_freq_indata       	= find(alldata{1,1}.freq == flist(nfreq));
    fnd_freq_instat       	= find(stat.freq == flist(nfreq));
    
    fnd_mask                = squeeze(double(stat.mask(:,fnd_freq_instat,:)))';
    
    fnd_time                = stat.time .* fnd_mask;
    fnd_time                = fnd_time(fnd_time~=0);
    
    fnd_time_in_data        = [];
    
    for nt = 1:length(fnd_time)
        fnd_time_in_data(nt)        = find(round(alldata{1,1}.time,2) == round(fnd_time(nt),2));
    end
    
    data_plot               = [];
    
    for nsub = 1:size(alldata,1)
        for ncond = 1:size(alldata,2)
            data_plot(nsub,ncond)       = nanmean(alldata{nsub,ncond}.powspctrm(1,fnd_freq_indata,fnd_time_in_data));
        end
    end
    
    [h1,p1]                           	= ttest(data_plot(:,1),data_plot(:,2));
    [h2,p2]                           	= ttest(data_plot(:,1),data_plot(:,3));
    [h3,p3]                           	= ttest(data_plot(:,2),data_plot(:,3));
    
    mean_data                           = nanmean(data_plot,1);
    bounds                              = nanstd(data_plot, [], 1);
    bounds_sem                          = bounds ./ sqrt(size(data_plot,1));
    
    list_plot                   = [3 4 5 6];
    
    subplot(2,3,list_plot(nfreq));
    errorbar(mean_data,bounds_sem,'-ks');
    
    xlim([0 4]);
    xticks([1 2 3]);
    xticklabels({'0Back','1Back','2Back'});
    title([num2str(flist(nfreq)) 'Hz 0v1= ' num2str(round(p1,5)) ' 0v2= ' num2str(round(p2,5)) ' 1v2= ' num2str(round(p3,5))]);
    
    ylim([0.48 0.8]);
    yticks([0.48 0.8]);
    
end