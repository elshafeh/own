clear; clc;

suj_list                          	= [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
        
    list_band                      	= {'alpha.pre' 'beta.pre'};
    list_bin                      	= {'b1' 'b2'};
    
    ext_decode                    	= 'stim';
    
    for nband = 1:length(list_band)
        for nbin = 1:length(list_bin)
            
            list_stim             	= [1 2 3 4 5 6 7 8 9]; % [1:10];
            pow                   	= [];
            
            for nstim = 1:length(list_stim)
                
                fname_in          	= ['~/Dropbox/project_me/data/nback/timegen/sub' num2str(suj_list(nsuj)) '.' list_band{nband} ...
                '.' list_bin{nbin} '.decoding.stim' num2str(list_stim(nstim)) '.nodemean.withback.downsample.auc.timegen.mat'];
                fprintf('loading %s\n',fname_in);
                load(fname_in);
                
                pow(nstim,:,:)    	= scores; clear scores;
                
            end
                        
            freq                    = [];
            freq.freq               = time_axis;
            freq.time               = time_axis;
            freq.dimord             = 'chan_freq_time';
            freq.label              = {['decoding ' ext_decode]};
            freq.powspctrm          = mean(pow,1);
            alldata{nsuj,nband,nbin}    = freq; clear freq;
            
        end 
    end
end

keep alldata list_*

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

for nband = 1:size(alldata,2)
    
    allstat{nband}          	= ft_freqstatistics(cfg, alldata{:,nband,1}, alldata{:,nband,2});
    [min_p(nband), pval{nband}]       	= h_pValSort(allstat{nband});
    
end

%%

nrow                            = 2;
ncol                            = 2;
nchan                           = 1;
i                               = 0;

for nband = 1:length(allstat)
    
    plimit                      = 0.05;
    
    
    stat                        = allstat{nband};
    stat.mask                   = stat.prob < plimit;
    
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
    
    ylabel({stat.label{nchan}, ['p = ' num2str(round(min_p(nband),3))]});
    title([list_band{nband} ' low versus high']);
    
    set(gca,'FontSize',16,'FontName', 'Calibri');
    
    
end