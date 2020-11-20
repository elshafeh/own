clear ; close all;

suj_list                            = [1:4 8:17];

for ns = 1:length(suj_list)
    for ndata = 1:2
        for nfeat = 1:4
            
            list_data               = {'meg','eeg'};
            list_feat               = {'inf.unf','left.right','left.inf','right.inf'};
            
            fname                   = ['../data/decode/auc/yc' num2str(suj_list(ns)) '.CnD.com90roi.' list_data{ndata} '.slct.bp7t15Hz.' list_feat{nfeat} '.aucbychan.mat'];
            fprintf('loading %s\n',fname);
            load(fname);
            
            tmp(nfeat,:,:)          = scores; clear scores;
            
        end
        
        atlas                      = ft_read_atlas('/Users/heshamelshafei/Documents/GitHub/fieldtrip/template/atlas/aal/ROI_MNI_V4.nii');
        roi_label                  = atlas.tissuelabel([1 2 19 20 43:70 79:90]);
        
        list_feat                   = {'INF VS UNF','LEFT VS RIGHT'};
        scores                      = tmp; clear tmp;
        
        %         lm1                         = find(round(time_axis,2) == round(0.1,2));
        %         lm2                         = find(round(time_axis,2) == round(0.4,2));
        
        %         lm1                         = find(round(time_axis,2) == round(0.6,2));
        %         lm2                         = find(round(time_axis,2) == round(1,2));
        
        lm1                         = find(round(time_axis,2) == round(1.2,2));
        lm2                         = find(round(time_axis,2) == round(1.6,2));
        
        nb_roi                      = size(scores,2);
        x_axs                       = [1:2:nb_roi 2:2:nb_roi];
        roi_label                   = roi_label(x_axs);
        
        scores                      = scores(:,x_axs,lm1:lm2);
        scores                      = mean(scores,3);
        
        avg                         = [];
        avg.avg                     = scores; clear scores;
        avg.label                   = {'INF VS UNF','LEFT VS RIGHT','LEFT VS UNF','RIGHT VS UNF'};
        avg.dimord                  = 'chan_time';
        
        avg.time                    = 1:nb_roi;
        
        alldata{ns,ndata}           = avg;
        
        keep alldata ns suj_list list_* template_data roi_label atlas;
        
        fprintf('\n');
        
    end
end

for ndata = 1:2
    gavg{ndata}                     = ft_timelockgrandaverage([],alldata{:,ndata});
end


for nroi = 1:length(roi_label)
    tmp                             = roi_label{nroi};
    idx                             = strfind(tmp,'_');
    if ~isempty(idx)
        tmp(idx)                    = ' ';
    end
    roi_label{nroi}                 = tmp;
end

for nchan = 1:4
    
    subplot(2,2,nchan);
    hold on;
    
    for ndata   = 1:2
        
        cfg                     = [];
        cfg.color               = 'br';
        cfg.label               = nchan;
        cfg.color               = cfg.color(ndata);
        cfg.plot_single         = 'no';
        
        %         cfg.vline               = [0 1.2];
        %         cfg.hline               = 0.5;
        
        cfg.xlim                = [1 length(roi_label)];
        %         cfg.ylim                = [0.5 0.6];
        
        h_plot_erf(cfg,alldata(:,ndata));
        
        xticks([1:length(roi_label)])
        xticklabels(roi_label);
        xtickangle(90);
        
        xlabel('ROI')
        ylabel('AUC')
        
        title(alldata{1,1}.label{nchan});
        set(gca,'FontSize',12,'FontName', 'Calibri');
        
    end
end