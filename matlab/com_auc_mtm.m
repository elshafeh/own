clear ; close all;

suj_list                                    = [1:4 8:17];

for ns = 1:length(suj_list)
    
    list_data                               = {'meg','eeg'};
    
    for ndata = 1:length(list_data)
        
        list_feat                           = {'inf.unf','left.right','left.inf','right.inf'};
        
        for nfeat = 1:length(list_feat)
            
            
            for nfreq = 1:19
                
                if strcmp(list_data{ndata},'eeg')
                    
                    fname                       = ['../data/mtm/yc' num2str(suj_list(ns)) '/yc' num2str(suj_list(ns)) '.CnD.' list_data{ndata} '.' list_feat{nfeat} '.' num2str(nfreq) 'Hz.auc.mat'];
                    fprintf('loading %s\n',fname);
                    load(fname);
                    
                    tmp(nfeat,nfreq,:)          = scores; clear scores;
                    
                else
                    
                    for np = 1:3
                        fname                   = ['../data/mtm/yc' num2str(suj_list(ns)) '/yc' num2str(suj_list(ns)) '.pt' num2str(np) '.CnD.' list_data{ndata} '.' list_feat{nfeat} '.' num2str(nfreq) 'Hz.auc.mat'];
                        fprintf('loading %s\n',fname);
                        load(fname);
                        sc_carr(np,:,:)         = scores ; clear scores;
                    end
                    
                    tmp(nfeat,nfreq,:)          = mean(sc_carr,1); clear sc_carr;
                    
                end
                
            end
            
        end
        
        time_width                      = 0.03;
        freq_width                      = 1;
        
        time_list                       = -1:time_width:2.5;
        freq_list                       = 1:freq_width:nfreq;
        
        freq                            = [];
        freq.time                       = time_list;
        freq.freq                       = freq_list;
        freq.label                      = {'INF VS UNF','LEFT VS RIGHT','LEFT VS UNF','RIGHT VS UNF'};
        freq.dimord                     = 'chan_freq_time';
        freq.powspctrm                  = tmp;
        
        clear tmp;
        
        alldata{ns,ndata}               = freq; clear freq;
        
    end
end

keep alldata list_data

for ndata = 1:2
    gavg{ndata}                         = ft_freqgrandaverage([],alldata{:,ndata});
end

i                                       = 0;

for ndata = 1:2
    for nf = 1:length(gavg{ndata}.label)
        
        
        cfg                             = [];
        cfg.colormap                    = brewermap(256, '*Spectral');
        cfg.comment                     = 'no';
        
        cfg.zlim                        = [0.5 0.55];
        cfg.channel                     = nf;
        cfg.xlim                        = [-0.2 2];
        cfg.marker                      = 'off';
        
        i                               = i + 1;
        nrow                            = 2;
        ncol                            = 4;
        subplot(nrow,ncol,i);
        ft_singleplotTFR(cfg,gavg{ndata});
        
        xticks([0 0.4 0.8 1.2 1.6 2])
        list_name                       = {'CUE','0.4','0.8','TAR','1.6','2'};
        xticklabels(list_name);
        
        yticks(4:4:20);
        
        vline(0,'--k')
        vline(1.2,'--k')
        
        c                               = colorbar;
        c.Ticks                         = cfg.zlim;
        %         c.Label.String                  ='AUC';
        
        title([gavg{ndata}.label{nf} ' ' upper(list_data{ndata})]);
        set(gca,'FontSize',20,'FontName', 'Calibri');
        
        
    end
end