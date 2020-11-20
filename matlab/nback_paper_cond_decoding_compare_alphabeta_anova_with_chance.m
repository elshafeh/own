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
      
    list_freq                     	= 5:30;
        
    list_lock                    	= {'1Bv2B'}; % 'all.dwn70' 'first.dwn70' 'target.dwn70'
    
    pow                           	= [];
    
    for nfreq = 1:length(list_freq)
        for nlock = 1:length(list_lock)
            
            %             fname               	= ['J:/nback/sens_level_auc/cond/sub' num2str(suj_list(nsuj)) '.multiclass.decoding.' ...
            %                 num2str(list_freq(nfreq)) 'Hz.lockedon.' list_lock{nlock} '.bsl.excl.auc.mat'];
            
            % '1Bv2B' '.0backagaisnt.all'
            
            fname               	= ['J:/nback/sens_level_auc/cond/sub' num2str(suj_list(nsuj)) '.decoding.' list_lock{nlock} '.' ...
                num2str(list_freq(nfreq)) 'Hz.lockedon.first.dwn70.bsl.excl.auc.mat'];
            
            fprintf('loading %s\n',fname);
            load(fname);
            pow(nlock,nfreq,:)  	= scores; clear scores;
        end
    end
    
    list_name                       = {'alpha peak ± 1Hz','beta peak ± 2Hz'};
    list_peak                       = [allpeaks(nsuj,1) allpeaks(nsuj,2)];
    list_width                      = [1 2];
    
    for nband = 1:length(list_peak)
        
        xi                          = find(round(list_freq) == round(list_peak(nband) - list_width(nband)));
        yi                          = find(round(list_freq) == round(list_peak(nband) + list_width(nband)));
        
        zi                          = pow(:,xi:yi,:); clear xi yi;
        
        avg                         = [];
        avg.label                   = list_lock; 
        avg.avg                     = squeeze(nanmean(zi,2));
        
        if size(avg.avg,1) > size(avg.avg,2)
            avg.avg = avg.avg';
        end
        
        avg.dimord                  = 'chan_time';
        avg.time                    = time_axis;
        
        alldata{nsuj,nband}         = avg; clear avg;
        
        
    end
    
    alldata{nsuj,3}                 = alldata{nsuj,2};
    
    rnd_vct                         = 0.495:0.0001:0.505;
    for nc = 1:size(alldata{nsuj,3}.avg,1)
        for nt = 1:size(alldata{nsuj,3}.avg,2)
            alldata{nsuj,3}.avg(nc,nt)    	= rnd_vct(randi(length(rnd_vct)));
        end
    end
    
    keep alldata list_name nsuj suj_list allpeaks
    
end

nbsuj                       = size(alldata,1);
nbcon                       = size(alldata,2);

[~,neighbours]              = h_create_design_neighbours(nbsuj,alldata{1,1},'gfp','t');

cfg                         = [];
cfg.method                  = 'ft_statistics_montecarlo';
cfg.statistic               = 'ft_statfun_depsamplesFmultivariate';
cfg.correctm                = 'cluster';
cfg.clusteralpha            = 0.05;
cfg.clusterstatistic        = 'maxsize'; %'maxsum', 'maxsize', 'wcm'
cfg.clusterthreshold        = 'nonparametric_common';
cfg.tail                     = 1; % For a F-statistic, it only make sense to calculate the right tail
cfg.clustertail             = cfg.tail;
cfg.alpha                   = 0.05;
cfg.computeprob             = 'yes';
cfg.numrandomization        = 1000;
cfg.neighbours              = neighbours;
cfg.latency                 = [-0.1 1];

design                      = zeros(2,nbcon*nbsuj);
design(1,1:nbsuj)           = 1;
design(1,nbsuj+1:2*nbsuj)   = 2;
design(1,nbsuj*2+1:3*nbsuj) = 3;

design(2,:)                 = repmat(1:nbsuj,1,nbcon);

cfg.design                  = design;
cfg.ivar                    = 1; % condition
cfg.uvar                    = 2; % subject number

stat                        = ft_timelockstatistics(cfg, alldata{:,1}, alldata{:,2}, alldata{:,3});

figure;
nrow                     	= 2;
ncol                     	= 2;

cfg                         = [];
cfg.channel                 = 1;
cfg.p_threshold             = 0.05;
cfg.z_limit                 = [0.47 0.6];
cfg.time_limit              = stat.time([1 end]);
cfg.color                   = 'brg';
cfg.linewidth               = 15;
subplot(nrow,ncol,1);
h_plotSingleERFstat_selectChannel_nobox(cfg,stat,alldata);
vline(0,'-k');
hline(0.5,'-k');
xticks([0:0.4:2]);

subplot(nrow,ncol,2);
hold on;
for ncond = 1:size(alldata,2)
    plot(0,ncond,['-' cfg.color(ncond)],'LineWidth',6)
end

legend({'alpha' 'beta' 'chance'});