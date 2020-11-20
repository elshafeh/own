clear ;

suj_list                    = [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    for nsess = [1 2]
        
        dirdata            	= 'J:/temp/nback/data/gamma/';
        fname_in          	= [dirdata 'sub' num2str(suj_list(nsuj)) '.sess' num2str(nsess) '.sensor.gamma.avg.mat'];
        fprintf('loading %s\n',fname_in);
        tic;load(fname_in);toc;
        tmp{nsess}         	= freq; clear freq;
        
    end
    
    freq                   	= ft_freqgrandaverage([],tmp{:});
    [freq_act,freq_bsl]   	= h_prepareBaseline(freq,[-0.2 -0.1],[5 100],[-0.1 2],'no');
    
    alldata{nsuj,1}       	= freq_act;
    alldata{nsuj,2}     	= freq_bsl; clear freq*

end

keep alldata

nb_suj                  	= size(alldata,1);
[design,neighbours]      	= h_create_design_neighbours(nb_suj,alldata{1,1},'elekta','t');

cfg                         = [];
% cfg.latency                 = [0 2];
% cfg.frequency               = [30 100];
cfg.statistic               = 'ft_statfun_depsamplesT';
cfg.method                  = 'montecarlo';
cfg.correctm                = 'cluster';
cfg.clusteralpha            = 0.05;
cfg.clusterstatistic        = 'maxsum';
cfg.minnbchan               = 4;
cfg.tail                    = 0;
cfg.clustertail             = 0;
cfg.alpha                   = 0.025;
cfg.numrandomization        = 1000;
cfg.uvar                    = 1;
cfg.ivar                    = 2;
cfg.neighbours              = neighbours;
cfg.design                  = design;
stat	                  	= ft_freqstatistics(cfg, alldata{:,1}, alldata{:,2});

[min_p,p_val]               = h_pValSort(stat);

stat2plot                   = h_plotStat(stat,10-20,0.2,'stat');

cfg                         = [];
cfg.layout                  = 'neuromag306cmb.lay';
cfg.comment                 = 'no';
cfg.marker                  = 'off';
cfg.colormap               	= brewermap(256, '*RdBu'); % PuBuGn % *RdYlBu
ft_topoplotER(cfg,stat2plot);

cfg                         = [];
cfg.layout                  = 'neuromag306cmb.lay';
cfg.colormap               	= brewermap(256, '*RdBu');
cfg.comment                 = 'no';
cfg.marker                  = 'off';
cfg.plimit                  = 0.2;
cfg.vline                   = [0];
cfg.sign                    = [1];
cfg.zlim                    = [-3 3];
h_plotstat_3d(cfg,stat);