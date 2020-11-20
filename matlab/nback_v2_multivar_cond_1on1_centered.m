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
    
    list_nback                   	= [1 2];
    list_cond                       = {'1back','2Back'};
    list_color                      = 'gb';

    test_band                       = 'beta';
    
    switch test_band
        case 'alpha'
            list_peak             	= allpeaks(nsuj,1);
            list_width          	= 1;
        case 'beta'
            list_peak           	= allpeaks(nsuj,2);
            list_width           	= 2;
    end
    
    list_freq                       = round([list_peak-list_width :1: list_peak+list_width]);
    
    for nback = 1:length(list_nback)
        
        list_lock                   = {'isfirst'};
        pow                         = [];
        
        for nlock = 1:length(list_lock)
            for nfreq = 1:length(list_freq)
                
                file_list         	= dir(['J:/nback/sens_level_auc/cond/sub' num2str(suj_list(nsuj)) '.decoding.' ...
                    num2str(list_nback(nback)) 'back.agaisnt.all.' num2str(list_freq(nfreq)) 'Hz.lockedon.target.dwn70.bsl.excl.auc.mat']);
                
                tmp              	= [];
                
                if isempty(file_list)
                    error('file not found!');
                end
                
                for nf = 1:length(file_list)
                    fname         	= [file_list(nf).folder filesep file_list(nf).name];
                    fprintf('loading %s\n',fname);
                    load(fname);
                    tmp           	= [tmp;scores]; clear scores;
                end
                
                pow(nlock,nfreq,:) 	= nanmean(tmp,1); clear tmp;
                
            end
        end
        
        avg                         = [];
        avg.label                   = {'auc'};
        avg.avg                     = [squeeze(mean(pow,2))]';
        avg.dimord                  = 'chan_time';
        avg.time                    = -1.5:0.02:2;
        
        alldata{nsuj,nback}         = avg; clear avg;
        
        fprintf('\n');
        
    end
end

keep alldata list_*;

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

plimit                      = 0.11;

stat.mask                   = stat.prob < plimit;

figure;
nrow                     	= 2;
ncol                     	= 2;

cfg                         = [];
cfg.channel                 = 1;
cfg.p_threshold             = plimit;
cfg.z_limit                 = [0.46 0.7];
cfg.time_limit              = stat.time([1 end]);
cfg.color                   = {'-g' '-b'};
cfg.linewidth               = 10;
subplot(nrow,ncol,1);
h_plotSingleERFstat_selectChannel_nobox(cfg,stat,alldata);
vline(0,'-k');
hline(0.5,'-k');
xticks([0:0.2:1]);