clear;clc;

suj_list                          	= [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    list_behav                      = {'fast' 'slow'};
    
    fname_in                    	= ['~/Dropbox/project_me/data/nback/peak/sub' num2str(suj_list(nsuj)) '.alphabeta.peak.package.0back.mat'];
    fprintf('loading %s\n',fname_in);
    load(fname_in);
    
    for nback = 1:2
        
        for nbehav = 1:2
        
            dir_data              	= '~/Dropbox/project_me/data/nback/tf/behav2tf/';
            fname_in               	= [dir_data 'sub' num2str(suj_list(nsuj)) '.' num2str(nback) 'back.target'];
            fname_in             	= [fname_in '.' list_behav{nbehav} '.mtm.mat'];
            fprintf('loading %s\n',fname_in);
            load(fname_in);
            
            alldata{nsuj,nback,nbehav}    = freq_comb; clear freq_comb;
            
        end
    end
end

keep alldata test_band
%%
keep alldata test_band

nbsuj                         	= size(alldata,1);
[design,neighbours]             = h_create_design_neighbours(nbsuj,alldata{1,1},'elekta','t');

for nback = 1:size(alldata,2)
    
    cfg                       	= [];
    cfg.statistic            	= 'ft_statfun_depsamplesT';
    cfg.method                  = 'montecarlo';
    cfg.correctm                = 'cluster';
    cfg.clusteralpha            = 0.05;
    cfg.frequency               = [15 35];
    cfg.latency                 = [-0.5 0.5];
    cfg.clusterstatistic        = 'maxsum';
    cfg.minnbchan               = 2;
    cfg.tail                    = 0;
    cfg.clustertail             = 0;
    cfg.alpha                   = 0.025;
    cfg.numrandomization        = 1000;
    cfg.uvar                    = 1;
    cfg.ivar                    = 2;
    nbsuj                       = size(alldata,1);
    [design,neighbours]         = h_create_design_neighbours(nbsuj,alldata{1,1},'elekta','t');
    cfg.design                  = design;
    cfg.neighbours              = neighbours;
    
    stat{nback}               	= ft_freqstatistics(cfg,alldata{:,nback,1},alldata{:,nback,2});
    [min_p(nback),p_val{nback}] = h_pValSort(stat{nback});clc;
    
end

%%

close all;

plimit                        	= 0.25;
nrow                           	= 2;
ncol                          	= 2;
i                            	= 0;

for nback = 1:length(stat)
    if min_p(nback) < plimit
        
        cfg                     = [];
        cfg.layout             	= 'neuromag306cmb.lay';
        cfg.zlim                = [-3 3];
        cfg.colormap         	= brewermap(256,'*RdBu');
        cfg.plimit           	= plimit;
        cfg.vline               = 0;
        cfg.sign                = [-1 1];
        cfg.test_name           = 'fast - slow';
        h_plotstat_3d(cfg,stat{nback});
        
    end
    
end
        
