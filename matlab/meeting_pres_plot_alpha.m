clear;

% fname_in                            = '../results/stat/n10_tfEmergence_mtmconvol_1t20Hz_comb.mat';
% load(fname_in);

fname_in                            = '../results/gavg/n10_gavg_mtmconvol_1t20Hz_comb.mat';
load(fname_in);

chan_list{1}                        = {'MLO11','MLO12','MLO13','MLO14','MLO21','MLO22','MLO23','MLO24','MLO31','MLO32', ... 
    'MLO34','MLO43','MLO44','MLP51','MLP52','MLP53','MLT27','MLT57', ...
    'MRO11','MRO12','MRO13','MRO14','MRO21','MRO22','MRO23','MRO24','MRP51','MRP52','MRP53','MRT27','MRT47','MZO01'};

chan_list{2}                        = {'MLC15','MLC16','MLC17','MLC23','MLC24','MLC25','MLC31','MLC41','MLC42','MLC53','MLC54', ...
    'MLC55','MLF66','MLF67','MLP22','MLP23','MLP32','MLP33','MLP34','MLP35','MLP42','MLP43','MLP44','MLP45','MLP55','MLP56','MLP57','MLT15','MLT16'};

freq_list                           = [8 11];

cfg                                 = [];
cfg.frequency                       = [5 15];
gavg                                = ft_selectdata(cfg,gavg);

cfg                                 = [];
cfg.baseline                        = [-0.6 -0.4];
cfg.baselinetype                    = 'relchange';
gavg_bsl                            = ft_freqbaseline(cfg,gavg);

% list_width                          = 0.5;
% list_time                           = [0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5 5.5];

list_width                          = 1.5;
list_time                           = [0 1.5 3 4.5];


figure;
i                                   = 0;
ncol                                = 2;
nrow                                = 2;

for nt = 1:length(list_time)
    
    cfg                             = [];
    cfg.layout                      = 'CTF275.lay'; % 'CTF275_helmet.mat';
    cfg.marker                      = 'off';
    cfg.comment                     = 'no';
    cfg.colormap                    = brewermap(256, '*RdBu');
    
    cfg.zlim                        = 'maxabs';
    
    cfg.xlim                        = [list_time(nt) list_time(nt)+list_width];
    cfg.ylim                        = freq_list;
    
    lgnd_time                       = [num2str(cfg.xlim(1)) '-' num2str(cfg.xlim(2)) 's'];
    
    i                               = i +1;
    subplot(nrow,ncol,i);
    ft_topoplotER(cfg, gavg_bsl);
    title(lgnd_time);
    
end

figure;
i                                   = 0;
ncol                                = 1;
nrow                                = 2;

cfg                                 = [];
cfg.layout                          = 'CTF275_helmet.mat';
cfg.marker                          = 'off';
cfg.colormap                        = brewermap(256, '*RdBu');
cfg.zlim                            = 'maxabs';
cfg.xlim                            = [-0.5 6];

% cfg.ylim                            = [9 10];

for nchan = 1:2
    
    i                               = i +1;
    subplot(nrow,ncol,i);
    
    cfg.channel                     = chan_list{nchan};
    ft_singleplotTFR(cfg, gavg_bsl);
    title(num2str(nchan));
    
    for nv = [0 1.5 3 4.5]
        vline(nv,'--k');
    end
    
end

for ns = 1:size(all_data,1)
    
    cfg                             = [];
    cfg.baseline                    = [-0.6 -0.2];
    cfg.baselinetype                = 'relchange';
    tmp                             = ft_freqbaseline(cfg,all_data{ns,1});
    
    cfg                             = [];
    cfg.latency                     = [-0.5 6];
    tmp                             = ft_selectdata(cfg,tmp);
    
    data_slct{ns,1}                 = h_freq2avg(tmp,freq_list,'avg_over_freq');
    
end

figure;
i                                   = 0;
ncol                                = 1;
nrow                                = 2;

cfg                                 = [];
cfg.plot_single                     = 'no';
cfg.xlim                            = [data_slct{1}.time(1) data_slct{1}.time(end)];
cfg.hline                           = 0;

for nchan = 1:2
    
    i                               = i +1;
    subplot(nrow,ncol,i);
    cfg.label                       = chan_list{nchan};
    cfg.ylim                        = [-0.6 0.6];
    cfg.vline                       = [0 1.5 3 4.5];
    
    h_plot_erf(cfg,data_slct(:,1));
    
    title(num2str(nchan));
    
end