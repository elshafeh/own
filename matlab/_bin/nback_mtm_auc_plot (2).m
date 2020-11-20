clear ;

suj_list                                = dir('../data/decode_data/auc/data*.3stacked.dwsmple.freqbreak.auc.mat');
i                                       = 0;

for ns = 1:length(suj_list)
    
    fname                               = [suj_list(ns).folder filesep suj_list(ns).name];
    fprintf('Loading %s\n',fname);
    load(fname);
    time_width                          = 0.02;
    freq_width                          = 1;
    
    time_list                           = -1:time_width:6;
    freq_list                           = 1:freq_width:50;
    
    freq                                = [];
    freq.dimord                         = 'chan_freq_time';
    freq.label                          = {'0 versus 1 Back','0 versus 2 Back','1 versus 2 Back'};
    freq.freq                           = freq_list;
    freq.time                           = time_list;
    freq.powspctrm                      = scores ; clear scores;
    
    i                                   = i + 1;
    alldata{i,1}                        = freq;
    
    %     avg                                 = [];
    %     avg.dimord                          = 'chan_time';
    %     avg.label                           = {'0 versus 1 Back','0 versus 2 Back','1 versus 2 Back'};
    %     avg.time                            = time_list;
    %     avg.avg                             = squeeze(mean(freq.powspctrm,2));
    %     alldata{i,2}                        = avg;
    
    time_window                         = 1;
    list_avg                            = [0:time_window:5];
    
    for nt = 1:length(list_avg)
        
        avg                                 = [];
        avg.dimord                          = 'chan_time';
        avg.label                           = {'0 versus 1 Back','0 versus 2 Back','1 versus 2 Back'};
        avg.time                            = freq_list;
        
        lm1                                 = find(round(time_list,2) == list_avg(nt));
        lm2                                 = find(round(time_list,2) == list_avg(nt)+time_window);
        avg.avg                             = squeeze(nanmean(freq.powspctrm(:,:,lm1:lm2),3));
        
        alldata{i,nt+1}                     = avg; clear avg;
        
    end
    
end

keep alldata

figure;
gavg                                    = ft_freqgrandaverage([],alldata{:,1});
i                                       = 0;

for nc = 1:length(gavg.label)
    
    nrow                                = 3;
    ncol                                = 1;
    
    i                                   = i + 1;
    subplot(nrow,ncol,i)
    
    cfg                                 = [];
    cfg.channel                         = gavg.label{nc};
    cfg.marker                          = 'off';
    cfg.comment                         = 'no';
    cfg.colormap                        = brewermap(256, '*Spectral');
    cfg.colorbar                        = 'yes';
    cfg.xlim                            = [0 4.5];
    cfg.ylim                            = [2 50];
    zlist                               = [0.7 0.6 0.6];
    cfg.zlim                            = [0.5 zlist(nc)];
    ft_singleplotTFR(cfg, gavg);
    
    for nv = [2 4]
        vline(nv,'--k');
    end
    
    c                                   = colorbar;
    c.Ticks                             = cfg.zlim ;
    xticks([0 1 2 3 4 5 6])
    yticks([10:10:50])
    
    xlabel('Time (s)')
    ylabel('Frequency (Hz)')
    set(gca,'FontSize',20,'FontName', 'Calibri');
    
end

figure;
i                                       =0;

for nc = 2:length(gavg.label)
    
    nrow                                    = 2;
    ncol                                    = size(alldata,2)-1;
    
    for nt = 2:size(alldata,2)
        
        i                                   = i + 1;
        subplot(nrow,ncol,i)
        
        cfg                                 = [];
        cfg.color                           = 'k';
        cfg.label                           = nc;
        cfg.color                           = cfg.color;
        cfg.plot_single                     = 'no';
        
        zlist                               = [0.49 0.62] ;%0.52 0.62; 0.52 0.62];
        cfg.ylim                            = zlist;%(nc,:);
        cfg.xlim                            = [2 40];
        
        h_plot_erf(cfg,alldata(:,nt));
        
        yticks([10:10:50])
        xlabel('Frequency (Hz)')
        yticks(cfg.ylim)
        set(gca,'FontSize',20,'FontName', 'Calibri');
        
    end
    
end