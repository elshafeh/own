clear;

fname_in                            = '../results/gavg/n10_gavg_mtmconvol_10t40Hz_comb.mat';
load(fname_in);

chan_list{1}                        = {'MLO21','MLO22','MLO31','MLO32','MLO41','MLO42','MLO51','MRO21','MRO22','MRO23','MRO51','MRO52','MRO53'};
chan_list{2}                        = {'MLC13','MLC14','MLC15','MLC16','MLC17','MLC21','MLC22','MLC23','MLC24','MLC25','MLC31', ... 
    'MLC41','MLC42','MLC52','MLC53','MLC54','MLC55','MLC62','MLF55','MLF64','MLF65','MLP11', ... 
    'MLP22','MLP23','MLP34','MLP35','MLP44','MLP45','MLP57'};

cfg                                 = [];
cfg.baseline                        = [-0.4 -0.2];
cfg.baselinetype                    = 'relchange';
gavg_bsl                            = ft_freqbaseline(cfg,gavg);

list_width                          = 0.5;
list_time                           = 0:list_width:5.5;

figure;
i                                   = 0;
ncol                                = 3;
nrow                                = 4;

for nt = 1:length(list_time)
    
    cfg                             = [];
    cfg.layout                      = 'CTF275.lay'; % 'CTF275_helmet.mat';
    cfg.marker                      = 'off';
    cfg.comment                     = 'no';
    cfg.colormap                    = brewermap(256, '*RdBu');
    
    cfg.zlim                        = 'maxabs';
    
    cfg.xlim                        = [list_time(nt) list_time(nt)+list_width];
    cfg.ylim                        = [16 30];
    
    lgnd_time                       = [num2str(cfg.xlim(1)) '-' num2str(cfg.xlim(2)) 's'];
    
%     cfg.zlim                        = [-0.3 0.2];
    
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
cfg.xlim                            = [-0.2 6];

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
    cfg.baseline                    = [-0.4 -0.2];
    cfg.baselinetype                = 'relchange';
    tmp                             = ft_freqbaseline(cfg,all_data{ns,1});
    
    cfg                             = [];
    cfg.latency                     = [-0.5 6];
    tmp                             = ft_selectdata(cfg,tmp);
    
    data_slct{ns,1}                 = h_freq2avg(tmp,[13 17],'avg_over_freq');
    data_slct{ns,2}                 = h_freq2avg(tmp,[22 27],'avg_over_freq');
    
end

figure;
i                                   = 0;
ncol                                = 2;
nrow                                = 2;

cfg                                 = [];
cfg.plot_single                     = 'no';
cfg.xlim                            = [data_slct{1}.time(1) data_slct{1}.time(end)];
cfg.hline                           = 0;

for nchan = 1:2
    for nfreq = 1:2
        i                           = i +1;
        subplot(nrow,ncol,i);
        cfg.label                   = chan_list{nchan};
        cfg.vline                   = [0 1.5 3 4.5];
        
        if nchan == 1
            cfg.ylim                = [-0.4 1];
        else
            cfg.ylim                = [-0.6 0.1];
        end
        
        h_plot_erf(cfg,data_slct(:,nfreq));
        
        title(num2str(nchan));
        
    end
end