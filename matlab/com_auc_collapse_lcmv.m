clear ; close all;

suj_list                            = [1:4 8:17];

for ns = 1:length(suj_list)
    for ndata = 1:2
        
        for nfeat = 1:4
            
            list_data               = {'meg','eeg'};
            list_feat               = {'inf.unf','left.right','left.inf','right.inf'};
            
            fname                   = ['../data/decode/auc/yc' num2str(suj_list(ns)) '.CnD.com90roi.' list_data{ndata} '.slct.bp7t15Hz.' list_feat{nfeat} '.auc.mat'];
            fprintf('loading %s\n',fname);
            load(fname);
            
            tmp(nfeat,:)            = scores; clear scores;
            
        end
        
        list_feat                   = {'INF VS UNF','LEFT VS RIGHT','LEFT VS UNF','RIGHT VS UNF'};
        scores                      = tmp; clear tmp;
        
        avg                         = [];
        avg.label                   = list_feat;
        avg.dimord                  = 'chan_time';
        avg.time                    = time_axis; % template_data.time{1}(lm1+1:lm2);
        avg.avg                     = scores;
        
        alldata{ns,ndata}           = avg;
        
        keep alldata ns suj_list list_* template_data;
        
        fprintf('\n');
        
    end
end


for nchan = 1:length(alldata{1,1}.label)
    
    subplot(2,2,nchan);
    hold on;
    
    for ndata   = 1:2
        
        cfg                     = [];
        cfg.color               = 'br';
        cfg.label               = nchan;
        cfg.color               = cfg.color(ndata);
        cfg.plot_single         = 'no';
        
        cfg.vline               = [0 1.2];
        cfg.hline               = 0.5;
        
        cfg.xlim                = [-0.1 2];
        
        cfg.ylim                = [0.48 0.75];
        
        h_plot_erf(cfg,alldata(:,ndata));
        
        xticks([0 0.4 0.8 1.2 1.6 2])
        list_name                   = {'Cue Onset','0.4','0.8','Target Onset','1.6','2'};
        xticklabels(list_name);
        
        yticks(cfg.ylim)
        
        xlabel('Time (s)')
        ylabel('AUC')
        
        title(alldata{1,1}.label{nchan});
        set(gca,'FontSize',20,'FontName', 'Calibri');
        
    end
end