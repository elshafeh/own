clear;close all;

suj_list                            = [1:33 35:36 38:44 46:51];
alldata                         	= [];

for nsuj = 1:length(suj_list)
    
    list_cond                       = {'1back','2back'};
    
    for ncond = 1:length(list_cond)
        
        sub_carr                	= [];
        i                        	= 0;
        
        fname_list              	= dir(['J:/nback/stim_category/sub' num2str(suj_list(nsuj)) '.sess*.' ...
            list_cond{ncond} '.istarget.bsl.dwn70.excl.auc.mat']);
        
        for nfile = 1:length(fname_list)
            i                       = i+1;
            fprintf('loading %50s\n',[fname_list(nfile).folder filesep fname_list(nfile).name]);
            load([fname_list(nfile).folder filesep fname_list(nfile).name]);
            sub_carr(i,:)       	= scores; clear scores
        end
        
        avg                     	= [];
        avg.label               	= {'stim category'};
        avg.avg                     = squeeze(mean(sub_carr,1)); clear sub_carr;
        avg.dimord               	= 'chan_time';
        avg.time                   	= time_axis;
        alldata{nsuj,ncond}     	= avg; clear avg;
        
    end
end

keep alldata list_cond;

%%

cfg                        	= [];
cfg.statistic             	= 'ft_statfun_depsamplesT';
cfg.method                 	= 'montecarlo';
cfg.correctm               	= 'cluster';
cfg.clusteralpha          	= 0.05;
cfg.latency              	= [-0.1 1];
cfg.clusterstatistic     	= 'maxsum';
cfg.minnbchan             	= 0;
cfg.tail                  	= 0;
cfg.clustertail           	= 0;
cfg.alpha                  	= 0.025;
cfg.numrandomization       	= 1000;
cfg.uvar                   	= 1;
cfg.ivar                  	= 2;

nbsuj                     	= size(alldata,1);
[design,neighbours]        	= h_create_design_neighbours(nbsuj,alldata{1,1},'gfp','t');

cfg.design                 	= design;
cfg.neighbours            	= neighbours;

stat                      	= ft_timelockstatistics(cfg, alldata{:,1}, alldata{:,2});
[min_p,p_val]             	= h_pValSort(stat);

keep stat alldata min_p p_val

%%

stat.mask                   = stat.prob < 0.05;

figure;
nrow                     	= 2;
ncol                     	= 2;

cfg                         = [];
cfg.channel                 = 1;
cfg.p_threshold             = 0.05;
cfg.z_limit                 = [0.46 0.8];
cfg.time_limit              = stat.time([1 end]);
cfg.color                   = {'-g' '-b'};
cfg.linewidth               = 10;
subplot(nrow,ncol,1);
h_plotSingleERFstat_selectChannel_nobox(cfg,stat,alldata);
vline(0,'-k');
hline(0.5,'-k');
xticks([0:0.2:1]);