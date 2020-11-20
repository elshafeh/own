clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

suj_list                          	= [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    list_nback                      = [1 2];
    list_cond                       = {'1back','2Back'};
    
    for ncond = 1:length(list_nback)
        
        list_lock                   = {'target.dwn70'}; % 
        avg_data                    = [];
        i                           = 0;
        
        for nlock = 1:length(list_lock)
            
            file_list             	= dir(['J:/nback/sens_level_auc/cond/sub' num2str(suj_list(nsuj)) '.decoding.' list_cond{ncond} ...
                '.agaisnt.all.lockedon.' list_lock{nlock} '.bsl.excl.auc.mat']);
            
            tmp                     = [];
            
            for nf = 1:length(file_list)
                fname               = [file_list(nf).folder filesep file_list(nf).name];
                fprintf('loading %s\n',fname);
                load(fname);
                tmp                 = [tmp;scores]; clear scores;
            end
            
            avg_data(nlock,:)       = mean(tmp,1); clear tmp;
            
        end
        
        avg                       	= [];
        avg.time               		= time_axis;
        avg.label                   = list_lock;
        avg.avg                   	= avg_data; clear avg_data;
        avg.dimord              	= 'chan_time';
        
        alldata{nsuj,ncond}      	= avg; clear avg pow;
        
    end
end

keep alldata list_*

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
cfg.z_limit                 = [0.46 0.7];
cfg.time_limit              = stat.time([1 end]);
cfg.color                   = {'-g' '-b'};
cfg.linewidth               = 10;
subplot(nrow,ncol,1);
h_plotSingleERFstat_selectChannel_nobox(cfg,stat,alldata);
vline(0,'-k');
hline(0.5,'-k');
xticks([0:0.2:1]);