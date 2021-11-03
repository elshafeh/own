clear;clc;

suj_list                          	= [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    list_behav                      = {'fast' 'slow'};
    
    fname_in                    	= ['~/Dropbox/project_me/data/nback/peak/sub' num2str(suj_list(nsuj)) '.alphabeta.peak.package.0back.mat'];
    fprintf('loading %s\n',fname_in);
    load(fname_in);
    
    for nbehav = 1:2
        
        pow                             = [];
        
        for nback = 1:2
            dir_data              	= '~/Dropbox/project_me/data/nback/tf/behav2tf/';
            fname_in               	= [dir_data 'sub' num2str(suj_list(nsuj)) '.' num2str(nback) 'back.target'];
            fname_in             	= [fname_in '.' list_behav{nbehav} '.mtm.mat'];
            fprintf('loading %s\n',fname_in);
            load(fname_in);
            
            pow(nback,:,:,:)        = freq_comb.powspctrm;
            
            
        end
        
        alldata{nsuj,nbehav}       	= freq_comb;
        alldata{nsuj,nbehav}.powspctrm       	= squeeze(mean(pow,1)); clear freq_comb pow;
        
    end
end

keep alldata

%%

nbsuj                           = size(alldata,1);
[design,neighbours]             = h_create_design_neighbours(nbsuj,alldata{1,1},'elekta','t');


cfg                             = [];
cfg.statistic                   = 'ft_statfun_depsamplesT';
cfg.method                      = 'montecarlo';
cfg.correctm                    = 'cluster';
cfg.clusteralpha                = 0.05;
cfg.frequency                   = [1 40];
cfg.latency                     = [-0.5 0.5];
cfg.clusterstatistic            = 'maxsum';
cfg.minnbchan                   = 3;
cfg.tail                        = 0;
cfg.clustertail                 = 0;
cfg.alpha                       = 0.025;
cfg.numrandomization            = 1000;
cfg.uvar                        = 1;
cfg.ivar                        = 2;

cfg.design                      = design;
cfg.neighbours                  = neighbours;

stat                            = ft_freqstatistics(cfg,alldata{:,1},alldata{:,2});
[min_p,p_val]                   = h_pValSort(stat);clc;


%%

close all;

plimit                          = 0.1;

stat.mask                       = stat.prob < plimit;

stoplot                         = [];
stoplot.time                    = stat.time;
stoplot.freq                    = stat.freq;
stoplot.label                   = stat.label;
stoplot.dimord                  = 'chan_freq_time';
stoplot.powspctrm               = stat.stat .* stat.mask;

cfg                             = [];
cfg.layout                      = 'neuromag306cmb.lay';
cfg.marker                      = 'off';
cfg.comment                     = 'no';
cfg.colorbar                    = 'no';
cfg.colormap                    = brewermap(256,'*RdBu');
cfg.zlim                        = [-0.5 0.5];
cfg.newfigure                   = 0;
subplot(2,2,1)
ft_singleplotTFR(cfg,stoplot);
vline(0,'--k');
title('');

list_freq                       = [1 7; 10 14;19 30];


for nfreq = 1:3
   
    cfg                     	= [];
    cfg.layout                	= 'neuromag306cmb.lay';
    cfg.marker               	= 'off';
    cfg.comment               	= 'no';
    cfg.colorbar             	= 'no';
    cfg.colormap             	= brewermap(256,'*RdBu');
    cfg.zlim                    = [-2 2];
    cfg.ylim                    = list_freq(nfreq,:);
    cfg.newfigure             	= 0;
    
    subplot(2,2,1+nfreq);
    ft_topoplotTFR(cfg,stoplot);
    
end

%%

nrow                     	= 2;
ncol                       	= 2;
i                          	= 0;

if min_p < plimit
    
    cfg                     = [];
    cfg.layout             	= 'neuromag306cmb.lay';
    cfg.zlim                = [-1 1];
    cfg.colormap         	= brewermap(256,'*RdBu');
    cfg.plimit           	= plimit;
    cfg.vline               = 0;
    cfg.sign                = [-1 1];
    cfg.test_name           = 'fast - slow';
    h_plotstat_3d(cfg,stat);
    
end

