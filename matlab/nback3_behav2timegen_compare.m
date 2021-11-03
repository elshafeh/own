clear; clc;

suj_list                        = [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    list_behav                  = {'fast' 'slow'};
    ext_decode                  = 'stim'; % stim* first target
    
    for nbehav = 1:2
        
        file_list               = dir(['~/Dropbox/project_me/data/nback/behav_timegen/sub' num2str(suj_list(nsuj)) '.' list_behav{nbehav} ...
            '.decoding.' ext_decode '*.nodemean.auc.timegen.mat']);
        
        pow                     = [];
        
        for nfile = 1:length(file_list)
            
            fname_in            = [file_list(nfile).folder filesep file_list(nfile).name];
            fprintf('loading %s\n',fname_in);
            load(fname_in);
            
            pow(nfile,:,:)      = scores; clear scores;
            
        end
        
        freq                    = [];
        freq.freq               = time_axis;
        freq.time               = time_axis;
        freq.dimord             = 'chan_freq_time';
        freq.label              = {['decoding ' ext_decode]};
        freq.powspctrm          = mean(pow,1);
        
        alldata{nsuj,nbehav}    = freq; clear freq;
        
    end
    
end

keep alldata

%%

nsuj                          	= size(alldata,1);
[design,neighbours]            	= h_create_design_neighbours(nsuj,alldata{1,1},'gfp','t'); clc;

cfg                             = [];
cfg.clusterstatistic            = 'maxsum';cfg.method = 'montecarlo';
cfg.correctm                    = 'cluster';cfg.statistic = 'depsamplesT';
cfg.uvar                        = 1;cfg.ivar = 2;
cfg.tail                        = 0;cfg.clustertail  = 0;

cfg.latency                     = [0 2];
cfg.frequency                   = cfg.latency;

cfg.clusteralpha                = 0.05; % !!
cfg.alpha                       = 0.025;

cfg.numrandomization            = 1000;
cfg.design                      = design;

stat                            = ft_freqstatistics(cfg, alldata{:,1}, alldata{:,2});
[min_p, p_val]                  = h_pValSort(stat);

%%

nrow                         	= 1;
ncol                          	= 1;
i                              	= 0;

plimit                          = 0.05;
stat.mask                       = stat.prob < plimit;

for nchan = 1:length(stat.label)
    
    
    cfg                         = [];
    cfg.colormap                = brewermap(256, '*RdBu');
    cfg.channel                 = nchan;
    cfg.parameter               = 'stat';
    cfg.maskparameter           = 'mask';
    cfg.maskstyle               = 'opacity';
    cfg.maskalpha               = 0.3;
    cfg.zlim                    = [-3 3];
    cfg.colorbar                ='no';
    cfg.figure                  = 0;
    
    i = i+1;
    subplot(nrow,ncol,i);
    ft_singleplotTFR(cfg,stat);
    
    ylabel({stat.label{nchan}, ['p = ' num2str(round(min_p,3))]});    
    title('Fast versus Slow');
    
    set(gca,'FontSize',14,'FontName', 'Calibri');
        
end