clear ;

suj_list                        = [1:4 8:17];
atlas                           = ft_read_atlas('/Users/heshamelshafei/Documents/GitHub/fieldtrip/template/atlas/aal/ROI_MNI_V4.nii');


for ns = 1:length(suj_list)
    
    fname                       = ['/Volumes/heshamshung/alpha_compare/decode/meeg_dec/yc' num2str(suj_list(ns)) '.meeg.dec.bychan.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    x_axs                       = [1:2:90 2:2:90];
    scores                      = scores(x_axs,:);
    
    roi_label                   = atlas.tissuelabel(x_axs);
    
    for nroi = 1:length(roi_label)
        
        tmp                     = roi_label{nroi};
        idx                     = strfind(tmp,'_');
        if ~isempty(idx)
            tmp(idx)            = ' ';
        end
        roi_label{nroi}         = tmp;
    end
    
    lm1                         = find(round(time_axis,2) == round(0.1,2));
    lm2                         = find(round(time_axis,2) == round(0.4,2));
    
    tmp                         = [mean(scores(:,lm1:lm2),2)]';
    avg                         = [];
    avg.avg                     = tmp;
    avg.time                    = 1:length(tmp); clear tmp;
    avg.label                   = {'POST CUE'};
    avg.dimord                  = 'chan_time';
    alldata{ns,1}               = avg; clear avg;
    
    lm1                         = find(round(time_axis,2) == round(1.2,2));
    lm2                         = find(round(time_axis,2) == round(1.5,2));
    
    tmp                         = [mean(scores(:,lm1:lm2),2)]';
    avg                         = [];
    avg.avg                     = tmp;
    avg.time                    = 1:length(tmp); clear tmp;
    avg.label                   = {'POST TARGET'};
    avg.dimord                  = 'chan_time';
    alldata{ns,2}               = avg; clear avg;
    
end

keep alldata roi_label

for n = 1:2
    
    gavg                        = ft_timelockgrandaverage([],alldata{:,n});
    
    cfg                         = [];
    cfg.color                   = 'k';
    cfg.plot_single             = 'no';
    
    cfg.xlim                    = [1 90];
    cfg.ylim                    = [0.52 0.64];
    cfg.hline                   = mean(gavg.avg);
    
    
    subplot(2,1,n)
    h_plot_erf(cfg,alldata(:,n));
    
    xticks([1:90])
    xticklabels(roi_label);
    xtickangle(90);
    %     xlabel('ROI')
    
    ylabel('AUC')
    
    
    title(alldata{1,n}.label);
    set(gca,'FontSize',12,'FontName', 'Calibri');
    
end