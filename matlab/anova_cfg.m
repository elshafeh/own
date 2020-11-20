% compute anova
nbsuj                       = size(alldata,1);
[~,neighbours]              = h_create_design_neighbours(nbsuj,alldata{1,1},'ctf','t');

cfg                         = [];
cfg.method                  = 'ft_statistics_montecarlo';
cfg.statistic               = 'ft_statfun_depsamplesFmultivariate';
cfg.correctm                = 'cluster';
cfg.clusteralpha            = 0.05;
cfg.clusterstatistic        = 'maxsum';
cfg.clusterthreshold        = 'nonparametric_common';
cfg.tail                 	= 1; % For a F-statistic, it only make sense to calculate the right tail
cfg.clustertail             = cfg.tail;
cfg.alpha                   = 0.05;
cfg.computeprob             = 'yes';
cfg.numrandomization        = 5000;
cfg.neighbours              = neighbours;

cfg.minnbchan               = 4;

if size(alldata,2) == 4
    design(1,1:nbsuj)     	= 1;
    design(1,nbsuj+1:2*nbsuj)   = 2;
    design(1,nbsuj*2+1:3*nbsuj) = 3;
    design(1,nbsuj*3+1:4*nbsuj) = 4;
    design(2,:)              	= repmat(1:nbsuj,1,4);
else
    design(1,1:nbsuj)    	= 1;
    design(1,nbsuj+1:2*nbsuj)   = 2;
    design(1,nbsuj*2+1:3*nbsuj) = 3;
    design(1,nbsuj*3+1:4*nbsuj) = 4;
    design(1,nbsuj*4+1:5*nbsuj) = 5;
    design(2,:)              	= repmat(1:nbsuj,1,5);
end

cfg.design                  = design;
cfg.ivar                    = 1; % condition
cfg.uvar                    = 2; % subject number
if size(alldata,2) == 4
    stat                  	= ft_timelockstatistics(cfg, alldata{:,1}, alldata{:,2}, alldata{:,3}, alldata{:,4});
else
    stat                 	= ft_timelockstatistics(cfg, alldata{:,1}, alldata{:,2}, alldata{:,3}, alldata{:,4}, alldata{:,5});
end