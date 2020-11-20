clear ;

suj_list                                = dir('../data/sub*');

for ns = 1:length(suj_list)
    
    subjectName                         = suj_list(ns).name;
    fname                               = ['../data/' subjectName '/tf/' subjectName '.firstcuelock.mtmconvol.comb.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    list_window                         = [0 1.5 3 4.5]; 
    
    cfg                                 = [];
    cfg.latency                         = [-0.4 -0.2];
    cfg.avgovertime                     = 'yes';
    bsl                                 = ft_selectdata(cfg,freq_comb);
    
    for nt   = 1:length(list_window)
        
        ix1                             = list_window(nt) + 0.4;
        time_window                     = 1;
        ix2                             = ix1+time_window;
        
        cfg                             = [];
        cfg.latency                     = [ix1 ix2];
        cfg.avgovertime                 = 'yes';
        tmp                             = ft_selectdata(cfg,freq_comb);
        
        alldata{ns,nt}                  = [];
        alldata{ns,nt}.label            = tmp.label;
        alldata{ns,nt}.freq             = tmp.freq;
        alldata{ns,nt}.powspctrm        = tmp.powspctrm - bsl.powspctrm;
        alldata{ns,nt}.dimord           = 'chan_freq';
        
    end
end

clearvars -except alldata

i                   = 0;
list_chan           = {'M*O*'};

nrow                = 1+length(list_chan);
ncol                = size(alldata,2);

for nt  = 1:size(alldata,2)
    
    i               = i + 1;
    subplot(nrow,ncol,i)
    
    cfg             = [];
    cfg.layout      = 'CTF275_helmet.mat';
    cfg.marker      = 'off';
    cfg.comment     = 'no';
    cfg.colormap    = brewermap(256, '*RdYlBu');
    cfg.zlim        = 'maxabs';
    ft_topoplotER(cfg, ft_freqgrandaverage([],alldata{:,nt}));
    
end

for nc  = 1:length(list_chan)
    for nt   = 1:size(alldata,2)
        
        i               = i + 1;
        subplot(nrow,ncol,i)
        
        cfg             = [];
        
        cfg.plotsingle  = 'no';
        cfg.channel     = list_chan{nc};
        cfg.xlim        = [1 30];
        
        h_plot_fft(cfg,alldata(:,nt));
        title(list_chan{nc});
        
    end
end