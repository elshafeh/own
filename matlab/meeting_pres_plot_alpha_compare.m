clear ; close all;

load('../results/gavg/n10_mtmconvol_1t20Hz_comb.AverageToPlot.mat');

chan_list{1}                        = {'MLO11','MLO12','MLO13','MLO14','MLO21','MLO22','MLO23','MLO24','MLO31','MLO32', ... 
    'MLO34','MLO43','MLO44','MLP51','MLP52','MLP53','MLT27','MLT57', ...
    'MRO11','MRO12','MRO13','MRO14','MRO21','MRO22','MRO23','MRO24','MRP51','MRP52','MRP53','MRT27','MRT47','MZO01'};

chan_list{2}                        = {'MLC15','MLC16','MLC17','MLC23','MLC24','MLC25','MLC31','MLC41','MLC42','MLC53','MLC54', ...
    'MLC55','MLF66','MLF67','MLP22','MLP23','MLP32','MLP33','MLP34','MLP35','MLP42','MLP43','MLP44','MLP45','MLP55','MLP56','MLP57','MLT15','MLT16'};

chan_name                           = {'occiparietal','centroparietal'};

i                                   = 0;
ncol                                = 2;
nrow                                = 2;

cfg                                 = [];
cfg.plot_single                     = 'no';
cfg.xlim                            = [alldata{1}.time(1) alldata{1}.time(end)];
cfg.hline                           = 0;

for nchan = 1:2
    
    i                               = i +1;
    subplot(nrow,ncol,i);
    hold on;
    cfg.label                       = chan_list{nchan};
    cfg.vline                       = [0 1.5 3 4.5];
    cfg.color                       = 'b';
    h_plot_erf(cfg,alldata(:,1));
    cfg.color                       = 'r';
    
    if nchan == 1
        cfg.ylim                        = [-0.8 0.8];
    else
        cfg.ylim                    = [-0.8 0.2];
    end
    
    h_plot_erf(cfg,alldata(:,2));
    lh = legend(list_cond{1},'',list_cond{2});
    
    title(chan_name{nchan});
    
    i                               = i +1;
    subplot(nrow,ncol,i);
    hold on;
    cfg.label                       = chan_list{nchan};
    cfg.vline                       = [0 1.5 3 4.5];
    cfg.color                       = 'k';
    h_plot_erf(cfg,alldata(:,3));
    cfg.color                       = 'g';
    h_plot_erf(cfg,alldata(:,4));
    lh = legend(list_cond{3},'',list_cond{4});
    
    title(chan_name{nchan});
    
end