clear ; close all;

suj_list                                        = [1:4 8:17];
atlas                                           = ft_read_atlas('/Users/heshamelshafei/Documents/GitHub/fieldtrip/template/atlas/aal/ROI_MNI_V4.nii');
roi_label                                       = atlas.tissuelabel([1 2 19 20 43:70 79:90]);

slct_axs                                        = [1:2:length(roi_label) 2:2:length(roi_label)];
roi_label                                       = roi_label(slct_axs);

for nroi = 1:length(roi_label)
    tmp                                         = roi_label{nroi};
    idx                                         = strfind(tmp,'_');
    if ~isempty(idx)
        tmp(idx)                                = ' ';
    end
    roi_label{nroi}                             = tmp; clear tmp;
end

keep slct_axs suj_list roi_label

for ns = 1:length(suj_list)
    
    for ndata = 1:2
        
        for nfeat = 1:2
            
            list_data                           = {'meg','eeg'};
            list_feat                           = {'inf.unf','left.right'};
            
            for nfreq = 1:30
                
                fname                           = ['../data/lcmv_mtm_res/yc' num2str(suj_list(ns)) '/yc' num2str(suj_list(ns)) '.CnD.com90roi.' ...
                    list_data{ndata} '.' list_feat{nfeat} '.' num2str(nfreq) 'Hz.aucbychan.mat'];
                
                fprintf('loading %s\n',fname);
                load(fname);
                
                tmp(:,nfreq,:)                  = scores(slct_axs,:); clear scores;
                
            end
            
            time_width                          = 0.03;
            freq_width                          = 1;
            
            time_list                           = -1:time_width:2.5;
            freq_list                           = 1:freq_width:nfreq;
            
            %             lm1                                 = find(round(time_list,2) == round(0.08,2));
            %             lm2                                 = find(round(time_list,2) == round(0.41,2));
            
            lm1                                 = find(round(time_list,2) == round(1.22,2));
            lm2                                 = find(round(time_list,2) == round(1.61,2));
            
            tmp                                 = tmp(:,:,lm1:lm2);
            tmp                                 = mean(tmp,3);
            
            feat_carrier(nfeat,:,:)             = tmp; clear tmp;
            
        end
        
        freq                                    = [];
        freq.powspctrm                          = feat_carrier; clear feat_carrier;
        freq.dimord                             = 'chan_freq_time';
        freq.time                               = freq_list;
        freq.freq                               = 1:length(roi_label);
        freq.label                              = {'INF VS UNF','LEFT VS RIGHT'};
        
        alldata{ns,ndata}                       = freq; clear freq;
        
    end
end

keep alldata roi_label list_data

for nd = 1:2
    gavg{nd}                                    = ft_freqgrandaverage([],alldata{:,nd});
end

keep alldata roi_label gavg list_data

i                                               = 0;

for ndata   = 1:2
    for nfeat = 1:2
        
        
        cfg                                     = [];
        cfg.colormap                            = brewermap(256, '*Spectral');
        cfg.comment                             = 'no';
        
        cfg.zlim                                = [0.5 0.53];
        cfg.channel                             = nfeat;
        cfg.marker                              = 'off';
        
        i                                       = i + 1;
        nrow                                    = 2;
        ncol                                    = 2;
        subplot(nrow,ncol,i);
        ft_singleplotTFR(cfg,gavg{ndata});
        
        title([gavg{ndata}.label{nfeat} ' ' upper(list_data{ndata})]);
        set(gca,'FontSize',12,'FontName', 'Calibri');
        yticks(1:length(roi_label));
        yticklabels(roi_label)
        
    end
end