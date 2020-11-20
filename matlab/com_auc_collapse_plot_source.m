clear ; close all;

suj_list                        = [1:4 8:17];

for ns = 1:length(suj_list)
    for ndata = 1:2
        
        for nfeat = 1:2
            
            list_data           = {'meg','eeg'};
            list_feat           = {'inf.unf','left.right'};
            
            fname               = ['/Volumes/heshamshung/alpha_compare/decode/source/yc' num2str(suj_list(ns)) '.' list_data{ndata} '.' list_feat{nfeat} '.90source.auc.collapse.mat'];
            fprintf('loading %s\n',fname);
            load(fname);
            
            tmp(nfeat,:)        = scores; clear scores;
            
        end
        
        list_feat               = {'INF VS UNF','LEFT VS RIGHT'};
        scores                  = tmp; clear tmp;
        
        fname                   = ['/Volumes/heshamshung/alpha_compare/lcmv/yc' num2str(suj_list(ns)) '.CnD.com90roi.' list_data{ndata} '.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        
        lm1                     = find(round(data.time{1},2) == round(-0.1,2));
        lm2                     = find(round(data.time{1},2) == round(2,2));
        
        avg                     = [];
        avg.label               = list_feat;
        avg.dimord              = 'chan_time';
        avg.time                = data.time{1}(lm1+1:lm2);
        avg.avg                 = scores;
        
        alldata{ns,ndata}       = avg;
        
        keep alldata ns suj_list list_*;
        
        fprintf('\n');
        
    end
end


for nchan = 1:2
    
    subplot(2,1,nchan);
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
        cfg.ylim                = [0.47 0.75];
        
        h_plot_erf(cfg,alldata(:,ndata));
        
        xticks([0 0.4 0.8 1.2 1.6 2])
        list_name                   = {'Cue Onset','0.4','0.8','Target Onset','1.6','2'};
        xticklabels(list_name);
        
        yticks([0.5 0.7])
        
        xlabel('Time (s)')
        ylabel('AUC')
        
        %         legend({'MEG','','EEG',''})
        
        title(alldata{1,1}.label{nchan});
        set(gca,'FontSize',20,'FontName', 'Calibri');
        
    end
end