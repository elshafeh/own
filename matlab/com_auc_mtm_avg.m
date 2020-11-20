clear ; close all;

suj_list                                    = [1:4 8:17];

for ns = 1:length(suj_list)
    
    list_data                               = {'meg','eeg'};
    
    for ndata = 1:length(list_data)
        
        list_feat                           = {'inf.unf','left.right','left.inf','right.inf'};
        
        for nfeat = 1:length(list_feat)
            
            
            for nfreq = 1:19
                
                if strcmp(list_data{ndata},'eeg')
                    
                    fname                  	= ['../data/mtm/yc' num2str(suj_list(ns)) '/yc' num2str(suj_list(ns)) '.CnD.' list_data{ndata} '.' list_feat{nfeat} '.' num2str(nfreq) 'Hz.auc.mat'];
                    fprintf('loading %s\n',fname);
                    load(fname);
                    
                    tmp(nfeat,nfreq,:)    	= scores; clear scores;
                    
                else
                    
                    for np = 1:3
                        fname            	= ['../data/mtm/yc' num2str(suj_list(ns)) '/yc' num2str(suj_list(ns)) '.pt' num2str(np) '.CnD.' list_data{ndata} '.' list_feat{nfeat} '.' num2str(nfreq) 'Hz.auc.mat'];
                        fprintf('loading %s\n',fname);
                        load(fname);
                        sc_carr(np,:,:)   	= scores ; clear scores;
                    end
                    
                    tmp(nfeat,nfreq,:)   	= mean(sc_carr,1); clear sc_carr;
                    
                end
                
            end
            
        end
        
        scores                              = tmp; clear tmp;
        
        time_width                          = 0.03;
        freq_width                          = 1;
        
        time_list                           = -1:time_width:2.5;
        freq_list                           = 1:freq_width:nfreq;
        
        list_zoom                           = [0.08 0.41; 0.59 1.01; 1.19 1.61];
        
        for nt = 1:3
            
            lm1                             = find(round(time_list,2) == round(list_zoom(nt,1),2));
            lm2                             = find(round(time_list,2) == round(list_zoom(nt,2),2));
            
            tmp                             = scores(:,:,lm1:lm2);
            tmp                             = mean(tmp,3);
            
            avg                             = [];
            avg.avg                         = tmp; clear tmp;
            avg.label                       = {'INF VS UNF','LEFT VS RIGHT','LEFT VS UNF','RIGHT VS UNF'};
            avg.dimord                      = 'chan_time';
            avg.time                        = freq_list;
            
            alldata{ns,ndata,nt}            = avg; clear avg;
            
        end
        
    end
end

keep alldata list_data

i                                           = 0;

for nt = 1:3
    for nchan = 1:4
        
        i                                   = i + 1;
        subplot(3,4,i);
        hold on;
        
        for ndata   = 1:2
            
            cfg                     = [];
            cfg.color               = 'br';
            cfg.label               = nchan;
            cfg.color               = cfg.color(ndata);
            cfg.plot_single         = 'no';
            
            zlist                   = [0.6 0.55 0.55];
            
            cfg.xlim                = [2 19];
            cfg.ylim                = [0.49 zlist(nt)];
            
            h_plot_erf(cfg,alldata(:,ndata,nt));
            
            yticks([cfg.ylim])
            
            xlabel('Frequency (Hz)')
            ylabel('AUC')
            
            title(alldata{1,1}.label{nchan});
            set(gca,'FontSize',20,'FontName', 'Calibri');
            
        end
    end
end