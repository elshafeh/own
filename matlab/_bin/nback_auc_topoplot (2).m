clear ;

suj_list             = dir('../data/decode/topo/sub*.grating.auc.topo.mat');

for ns = 1:length(suj_list)
    
    suj_name            = strsplit(suj_list(ns).name,'.');
    suj_name            = strsplit(suj_name{1},'sub');
    suj_name            = suj_name{2};
    
    %     fname               = ['../data/prepro/vis/data' suj_name '.mat'];
    %     fprintf('\nloading %s\n',fname);
    %     load(fname);
    
    %     cfg                 = [];
    %     cfg.channel         = data.label;
    %     data                = ft_selectdata(cfg,data);
    %     grad                = data.grad; clear data;
    
    fname               = ['../data/decode/grating/data' suj_name '.grating.dwsmple.mat'];
    fprintf('\nloading %s\n',fname);
    load(fname);
    
    fname               = [suj_list(ns).folder filesep suj_list(ns).name];
    fprintf('loading %s\n',fname);
    load(fname);
    
    %     data.grad           = grad;
    %     data.time           = data.time(1);
    %     data.trial          = data.trial(1);
    %     data.trial{1}       = scores;
    %     data.trialinfo      = 1;
    %     data_repair         = megrepair(data);
    %     load(['../data/prepro/vis/grad' suj_name '.mat']);
    
    avg                 = [];
    avg.label           = data.label;
    avg.dimord          = 'chan_time';
    avg.time            = data.time{1};
    avg.avg             = scores;
    
    alldata{ns}         = avg; 
    
    keep alldata ns suj_list;
    
end

cfg                     =[];
cfg.layout              = 'neuromag306planar.lay';
cfg.colormap            = brewermap(256, '*Spectral');
cfg.linewidth           = 3;
cfg.linecolor           = 'k';
subplot(2,2,1)
ft_singleplotER(cfg,ft_timelockgrandaverage([],alldata{:}));
vline(0,'--k');
title('All Sensors Averaged');
set(gca,'FontSize',16);

subplot(2,2,[2 4])
cfg.xlim                = [0.08 0.14];
cfg.marker              = 'off';
cfg.comment             = 'no';
ft_topoplotER(cfg,ft_timelockgrandaverage([],alldata{:}));
set(gca,'FontSize',16);

subplot(2,2,3)
cfg                     = rmfield(cfg,'xlim');
cfg.linecolor           = 'r';
cfg.channel             = {'MEG1923', 'MEG1922', 'MEG2032', 'MEG2033', 'MEG2042', 'MEG2043', 'MEG2113', 'MEG2112', 'MEG2312', 'MEG2333', 'MEG2343', 'MEG2342'};
ft_singleplotER(cfg,ft_timelockgrandaverage([],alldata{:}));
title('Ociipital Sensors');
vline(0,'--k');
set(gca,'FontSize',16);