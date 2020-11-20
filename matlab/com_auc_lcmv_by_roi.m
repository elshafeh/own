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
        
        list_feat                   = {'INF VS UNF','LEFT VS RIGHT'};
        scores                      = tmp; clear tmp;
        
        %         if ns == 1 && ndata == 1
        %             fname                   = ['../data/decode/auc/yc' num2str(suj_list(ns)) '.CnD.com90roi.' list_data{ndata} '.mat'];
        %             fprintf('loading %s\n',fname);
        %             load(fname);
        %             template_data           = data; clear data;
        %         end
        %         lm1                         = find(round(template_data.time{1},2) == round(-0.2,2));
        %         lm2                         = find(round(template_data.time{1},2) == round(2,2));
        %
        %         time_axes                   = template_data.time{1}(lm1+1:lm2);
        
        nb_roi                      = size(scores,2);
        
        freq                        = [];
        freq.time                   = time_axis;
        freq.freq                   = 1:nb_roi;
        freq.label                  = {'INF VS UNF','LEFT VS RIGHT','LEFT VS UNF','RIGHT VS UNF'};
        freq.dimord                 = 'chan_freq_time';
        
        x_axs                       = [1:2:nb_roi 2:2:nb_roi];
        freq.powspctrm              = scores(:,x_axs,:);
        
        alldata{ns,ndata}           = freq;
        
        keep alldata ns suj_list list_* template_data nb_roi;
        
        fprintf('\n');
        
    end
end

for ndata = 1:2
    gavg{ndata}                         = ft_freqgrandaverage([],alldata{:,ndata});
end

i                                       = 0;

for ndata = 1:2
    for nf = 1:length(gavg{ndata}.label)
        
        cfg                             = [];
        cfg.colormap                    = brewermap(256, '*Spectral');
        cfg.comment                     = 'no';
        
        cfg.zlim                        = [0.5 0.54];
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
        
        yticks([1 nb_roi/2 nb_roi]);
        hline(nb_roi/2,'-k');
        c                               = colorbar;
        c.Ticks                         = cfg.zlim;
        
        title([gavg{ndata}.label{nf} ' ' upper(list_data{ndata})]);
        set(gca,'FontSize',20,'FontName', 'Calibri');
        
        
    end
end