clear ; close all;

load('../results/gavg/n10_mtmconvol_10t40Hz_comb.AverageToPlot.mat');

chan_list{1}                        = {'MLO21','MLO22','MLO31','MLO32','MLO41','MLO42','MLO51','MRO21','MRO22','MRO23','MRO51','MRO52','MRO53'};

chan_list{2}                        = {'MLC13','MLC14','MLC15','MLC16','MLC17','MLC21','MLC22','MLC23','MLC24','MLC25','MLC31', ... 
    'MLC41','MLC42','MLC52','MLC53','MLC54','MLC55','MLC62','MLF55','MLF64','MLF65','MLP11', ... 
    'MLP22','MLP23','MLP34','MLP35','MLP44','MLP45','MLP57'};

chan_name                           = {'occipital','centroparietal'};

alldata                             = squeeze(alldata(:,:,1));

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
        cfg.ylim                    = [-0.6 1.2];
    else
        cfg.ylim                    = [-0.8 0.1];
    end
    
    h_plot_erf(cfg,alldata(:,2));
    legend(list_cond{1},list_cond{2});
    
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
    lh = legend(list_cond{3},list_cond{4});
    
    title(chan_name{nchan});
    
end