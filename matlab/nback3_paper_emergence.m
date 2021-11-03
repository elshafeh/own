clear;clc;

suj_list                        = [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    ext_stim                    = 'norep';
    baseline_correct            = 'average'; % none average time freq
    baseline_period             = [-0.4 -0.2];
    
    dir_data                    = '~/Dropbox/project_me/data/nback/tf/behav2tf/';
    file_list                   = dir([dir_data 'sub' num2str(suj_list(nsuj)) '.*back.' ext_stim '.correct.adaptive.mtm.mat']);
    pow                         = [];
    
    for nfile = 1:length(file_list)
        fname_in                = [file_list(nfile).folder filesep file_list(nfile).name];
        fprintf('loading %s\n',fname_in);
        load(fname_in);
        pow(nfile,:,:,:)        = freq_comb.powspctrm;
        
    end
    
    freq_comb.powspctrm	= squeeze(mean(pow,1)); clear pow;
    
    % baseline correction
    t1                          = nearest(freq_comb.time,baseline_period(1));
    t2                          = nearest(freq_comb.time,baseline_period(2));
    
    bsl                         = nanmean(freq_comb.powspctrm(:,:,t1:t2),3);
    
    bsl                         = repmat(bsl,[1 1 length(freq_comb.time)]);
    
    alldata{nsuj,1}             = freq_comb;
    alldata{nsuj,2}             = alldata{nsuj,1};
    alldata{nsuj,2}.powspctrm   = bsl; clear bsl;
    
    
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
cfg.frequency                   = [5 50];
cfg.latency                     = [0 2];
cfg.clusterstatistic            = 'maxsum';
cfg.minnbchan                   = 4;
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

suj_list                        = [1:33 35:36 38:44 46:51];
list_channel                    = {};

for nsuj = 1:length(suj_list)
    
    dir_data                    = '~/Dropbox/project_me/data/nback/peak/';
    fname_in                    = [dir_data 'sub' num2str(suj_list(nsuj)) '.alphabeta.peak.package.0back.equalhemi.mat'];
    fprintf('loading %s\n',fname_in);
    load(fname_in);
    list_channel                = [list_channel;max_chan];
    
end

list_channel                    = unique(list_channel); clc;

%%

close all ; 

plimit                          = 0.025;
nrow                            = 2;
ncol                            = 2;
i                               = 0;

colormap                        = '*BrBG';
zlimit                          = [-4 4];

if min_p < plimit
    
    cfg                         = [];
    cfg.layout                  = 'neuromag306cmb.lay';
    cfg.zlim                    = zlimit;
    cfg.colormap                = brewermap(256,colormap);
    cfg.plimit                  = plimit;
    cfg.sign                    = [-1 1];
    cfg.test_name               = 'Activity - Baseline';
    cfg.fontsize                = 16;
    
    h_plotstat_3d(cfg,stat);
    
end

%%

clc;

find_chan                       = [];
for nchan = 1:length(list_channel)
    find_chan(nchan)            = find(strcmp(stat.label,list_channel{nchan}));
end

statplot                        = [];
statplot.time                   = stat.time;
statplot.freq                   = stat.freq;
statplot.powspctrm           	= mean(stat.stat(find_chan,:,:),1);
statplot.mask                  	= mean(stat.mask(find_chan,:,:),1);
statplot.mask                   = statplot.mask ~= 0;
statplot.label                  = {'avg'};

cfg                             = [];
cfg.colormap                    = brewermap(256,colormap);
cfg.zlim                        = zlimit;
cfg.comment                     = 'no';
cfg.colorbar                    = 'yes';
cfg.maskparameter               = 'mask';
cfg.maskstyle                   = 'opacity';
cfg.colorbar                    = 'no';
cfg.figure                      = subplot(2,2,1);
cfg.maskalpha                   = 0.5;
ft_singleplotTFR(cfg,statplot);
title('');
set(gca,'FontSize',14,'FontName', 'Calibri','FontWeight','normal');

statplot.powspctrm(:)           = 0;
cfg.figure                      = subplot(2,2,2);
cfg.maskstyle                   = 'outline';
ft_singleplotTFR(cfg,statplot);
title('');
set(gca,'FontSize',14,'FontName', 'Calibri','FontWeight','normal');