function stat = h_anova(cfg_in,alldata)

nbsuj                       = size(alldata,1);

if strcmp(alldata{1}.label{1}(1:3),'MEG')
    [~,neighbours]       	= h_create_design_neighbours(nbsuj,alldata{1,1},'elekta','t');
else
    [~,neighbours]       	= h_create_design_neighbours(nbsuj,alldata{1,1},'gfp','t');
end

cfg                         = [];
cfg.method                  = 'ft_statistics_montecarlo';
cfg.statistic               = 'ft_statfun_depsamplesFmultivariate';
cfg.correctm                = 'cluster';
cfg.clusteralpha            = 0.05;
cfg.clusterstatistic        = 'maxsum'; %'maxsum', 'maxsize', 'wcm'
cfg.clusterthreshold        = 'nonparametric_common';
cfg.tail                 	= 1; % For a F-statistic, it only make sense to calculate the right tail
cfg.clustertail             = cfg.tail;
cfg.alpha                   = 0.05;
cfg.computeprob             = 'yes';
cfg.numrandomization        = 1000;
cfg.neighbours              = neighbours;

if isfield(cfg_in,'latency')
    cfg.latency           	= cfg_in.latency;
end
if isfield(cfg_in,'frequency')
    cfg.frequency        	= cfg_in.frequency;
end
if isfield(cfg_in,'minnbchan')
    cfg.minnbchan        	= cfg_in.minnbchan;
end

design                      = zeros(2,3*nbsuj);
design(1,1:nbsuj)           = 1;
design(1,nbsuj+1:2*nbsuj)   = 2;
design(1,nbsuj*2+1:3*nbsuj) = 3;
design(2,:) = repmat(1:nbsuj,1,3);
cfg.design                  = design;
cfg.ivar                    = 1; % condition
cfg.uvar                    = 2; % subject number

if strcmp(alldata{1,1}.dimord,'chan_time')
    stat                  	= ft_timelockstatistics(cfg, alldata{:,1}, alldata{:,2}, alldata{:,3});
else
    stat                  	= ft_freqstatistics(cfg, alldata{:,1}, alldata{:,2}, alldata{:,3});
end