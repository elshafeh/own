clear ; clc;

load ../data/bil_goodsubjectlist.27feb20.mat

for ns = 1:length(suj_list)
    
    subjectName             = suj_list{ns};
    
    for nb = 1:5
        
        fname               = ['J:\temp\bil\tf\' subjectName '.cuelock.alphabin' num2str(nb) '.itc.comb.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        
        f1                  = find(phase_lock.freq == 3);
        f2                  = find(phase_lock.freq == 5);
        
        avg                 = [];
        avg.time            = phase_lock.time;
        avg.label           = phase_lock.label;
        avg.avg             = squeeze(mean(phase_lock.powspctrm(:,f1:f2,:),2));
        avg.dimord          = 'chan_time';
        
        alldata{ns,nb}      = avg; clear avg f1 f2 fname;
        
    end
end

keep alldata

nsuj                    	= size(alldata,1);
[design,neighbours]      	= h_create_design_neighbours(nsuj,alldata{1,1},'meg','t'); clc;

cfg                     	= [];
cfg.method              	= 'ft_statistics_montecarlo';
cfg.statistic            	= 'ft_statfun_depsamplesFmultivariate';
cfg.correctm              	= 'cluster';
cfg.clusteralpha           	= 0.05;
cfg.clusterstatistic      	= 'maxsum';
cfg.clusterthreshold      	= 'nonparametric_common';
cfg.tail                 	= 1; % For a F-statistic, it only make sense to calculate the right tail
cfg.clustertail         	= cfg.tail;
cfg.alpha               	= 0.05;
cfg.computeprob           	= 'yes';
cfg.numrandomization      	= 1000;
cfg.neighbours             	= neighbours;

cfg.minnbchan               = 3; % !!
cfg.alpha                   = 0.025;

cfg.numrandomization        = 1000;
cfg.design                  = design;

nbsuj                       = size(alldata,1);

design                      = zeros(2,5*nbsuj);
design(1,1:nbsuj)           = 1;
design(1,nbsuj+1:2*nbsuj)   = 2;
design(1,nbsuj*2+1:3*nbsuj) = 3;
design(1,nbsuj*3+1:4*nbsuj) = 4;
design(1,nbsuj*4+1:5*nbsuj) = 5;
design(2,:)                 = repmat(1:nbsuj,1,5);

cfg.design                  = design;
cfg.ivar                    = 1; % condition
cfg.uvar                    = 2; % subject number

stat                        = ft_timelockstatistics(cfg, alldata{:,1},alldata{:,2},alldata{:,3},alldata{:,4},alldata{:,5});

for ns = 1:size(alldata,1)
    for nb = 1:size(alldata,2)
        cfg             =[];
        cfg.latency     = stat.time([1 end]);
        cfg.channel     = stat.label;
        newdata{ns,nb}  = ft_selectdata(cfg,alldata{ns,nb}); clc;
    end
end

nrow                        = 2;
ncol                        = 2;
i                        	= 0;

stoplot                  	= [];
stoplot.time               	= stat.time;
stoplot.label             	= stat.label;
stoplot.dimord            	= 'chan_time';
stoplot.avg               	= squeeze(stat.stat .* stat.mask);

subplot(nrow,ncol,1)

cfg                         = [];
cfg.layout                  = 'CTF275_helmet.mat'; %'CTF275.lay';
cfg.marker                  = 'off';
cfg.comment                 = 'no';
cfg.colorbar                = 'no';
cfg.colormap                = brewermap(256, '*Reds');
cfg.ylim                    = 'zeromax';
ft_topoplotER(cfg,stoplot);

% plot(stoplot.time,nanmean(stoplot.avg,1),'-k','LineWidth',2);
% xticks([0 1.5 3 4.5]);
% xticklabels({'1st cue','1st gab','2nd cue','2nd gab'});
% vline([0 1.5 3 4.5],'--k');
% ylim(stat.time([1 end]))

list_chan                   = mean(stoplot.avg,2);
list_chan                   = find(list_chan ~= 0);

cfg                         = [];
cfg.channel                 = list_chan;
cfg.time_limit              = stat.time([1 end]);
cfg.color                   = 'bckmr';
cfg.z_limit               	= [0.1 0.5];
cfg.linewidth            	= 10;

subplot(nrow,ncol,3:4)
h_plotSingleERFstat_selectChannel_nobox(cfg,stat,newdata);
legend({'' 'lowest bin' '' 'second lowest' '' 'median' '' 'second highest' '' 'highest bin'});
xticks([0 1.5 3 4.5]);
xticklabels({'1st cue','1st gab','2nd cue','2nd gab'});
vline([0 1.5 3 4.5],'--k');

for ns = 1:size(newdata,1)
    for nb = 1:size(newdata,2)
        tmp                 = newdata{ns,nb}.avg .* squeeze(stat.mask);
        tmp(tmp == 0)       = NaN;
        tmp                 = nanmean(nanmean(tmp));
        data_plot(ns,nb,:)  = tmp; clear tmp;
    end
end

mean_data               	= nanmean(data_plot,1);
bounds                   	= nanstd(data_plot, [], 1);
bounds_sem              	= bounds ./ sqrt(size(data_plot,1));

subplot(nrow,ncol,2)
errorbar(mean_data,bounds_sem,'-ks');

xlim([0 6]);
ylim([0.2 0.4]);
xticks([1 2 3 4 5]);
xticklabels({'Lowest alpha' '' '' '' 'Highest alpha'});