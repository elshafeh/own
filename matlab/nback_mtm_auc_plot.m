clear ;

suj_list                                = dir('~/Dropbox/project_me/data/nback/decode/auc/data*.3stacked.dwsmple.freqbreak.auc.mat');
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
    
    time_window                         = 0.8;
    list_avg                         	= [0.2 2.2 4.2];
    
    for nt = 1:length(list_avg)
        
        avg                            	= [];
        avg.dimord                    	= 'chan_time';
        avg.label                     	= {'0 versus 1 Back','0 versus 2 Back','1 versus 2 Back'};
        avg.time                      	= freq_list;
        
        lm1                            	= find(round(time_list,2) == list_avg(nt));
        lm2                           	= find(round(time_list,2) == list_avg(nt)+time_window);
        avg.avg                     	= squeeze(nanmean(freq.powspctrm(:,:,lm1:lm2),3));
        
        alldata{i,nt+1}               	= avg; clear avg;
        
    end
    
end

keep alldata

figure;
gavg                                    = ft_freqgrandaverage([],alldata{:,1});
i                                       = 0;

for nc = 2:length(gavg.label)
    
    nrow                                = 2;
    ncol                                = 1;
    
    i                                   = i + 1;
    subplot(nrow,ncol,i)
    
    cfg                                 = [];
    cfg.channel                         = gavg.label{nc};
    cfg.marker                          = 'off';
    cfg.comment                         = 'no';
    cfg.colormap                        = brewermap(256, '*RdBu');
    cfg.colorbar                        = 'yes';
    cfg.xlim                            = [0 5.1];
    cfg.ylim                            = [3 30];
    zlist                               = [0.7 0.6 0.6];
    cfg.zlim                            = [0.5 zlist(nc)];
    ft_singleplotTFR(cfg, gavg);
    title(gavg.label{nc});
    
    for nv = [2 4]
        vline(nv,'--k');
    end
    
    c                                   = colorbar;
    c.Ticks                             = cfg.zlim ;
    xticks([0 1 2 3 4 5 6])
    yticks([10:10:50])
    
    if nc == 3
        xlabel('Time (s)')
    end
    
    ylabel('Frequency (Hz)')
    set(gca,'FontSize',20,'FontName', 'Calibri');
    
end

figure;
hold on;
i                                           =0;

nrow                                        = 1;
ncol                                        = 1;

for nt = 2%:size(alldata,2)
         
    i                                   = i + 1;
    subplot(nrow,ncol,i)
    hold on;
    
    for nc = 2:length(gavg.label)
        
        cfg                                 = [];
        
        list_color                          = 'bgm';
        
        cfg.color                           = list_color(nc);
        cfg.label                           = nc;
        cfg.color                           = cfg.color;
        cfg.plot_single                     = 'no';
        zlist                               = [0.5 0.62] ;%0.52 0.62; 0.52 0.62];
        cfg.ylim                            = zlist;%(nc,:);
        cfg.xlim                            = [5 40];
        
        h_plot_erf(cfg,alldata(:,2:end));
        
        xticks([5:5:50]);
        xlabel('Freq Hz');
        yticks(cfg.ylim);
        set(gca,'FontSize',20,'FontName', 'Calibri');
        grid on;
        
    end
    
    legend({'0 v 2 Back','','1 v 2 Back',''});
    
end