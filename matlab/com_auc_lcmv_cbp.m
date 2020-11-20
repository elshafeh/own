clear ; close all;

global ft_default
ft_default.spmversion = 'spm12';

suj_list                            = [1:4 8:17];

for ns = 1:length(suj_list)
    for ndata = 1:2
        for nfeat = 1:4
            
            list_data                   = {'meg','eeg'};
            list_feat                   = {'inf.unf','left.right','left.inf','right.inf'};
            
            fname                       = ['../data/decode/auc/yc' num2str(suj_list(ns)) '.CnD.com90roi.' list_data{ndata} '.slct.bp7t15Hz.' list_feat{nfeat} '.aucbychan.mat'];
            fprintf('loading %s\n',fname);
            load(fname);
            
            atlas                       = ft_read_atlas('/Users/heshamelshafei/Documents/GitHub/fieldtrip/template/atlas/aal/ROI_MNI_V4.nii');
            roi_label                   = atlas.tissuelabel([1 2 19 20 43:70 79:90]);
            
            nb_roi                      = size(scores,1);
            x_axs                       = [1:2:nb_roi 2:2:nb_roi];
            roi_label                   = roi_label(x_axs);
            scores                      = scores(x_axs,:);
            
            for nroi = 1:length(roi_label)
                tmp                             = roi_label{nroi};
                idx                             = strfind(tmp,'_');
                if ~isempty(idx)
                    tmp(idx)                    = ' ';
                end
                roi_label{nroi}                 = tmp;
            end
            
            avg                         = [];
            avg.avg                     = scores; clear scores;
            avg.label                   = roi_label;
            avg.dimord                  = 'chan_time';
            avg.time                    = time_axis;
            
            alldata{ns,nfeat,ndata}     = avg; clear avg;
            
        end
    end
end

keep alldata list_feat

nbsuj                           = size(alldata,1);
[design,neighbours]             = h_create_design_neighbours(nbsuj,alldata{1,1},'gfp','t');

cfg                             = [];

cfg.latency                     = [1.2 2];

cfg.statistic                   = 'ft_statfun_depsamplesT';
cfg.method                      = 'montecarlo';
cfg.correctm                    = 'cluster';
cfg.clusteralpha                = 0.05;
cfg.clusterstatistic            = 'maxsum';
cfg.minnbchan                   = 0;
cfg.tail                        = 0;
cfg.clustertail                 = 0;
cfg.alpha                       = 0.025;
cfg.numrandomization            = 1000;
cfg.uvar                        = 1;
cfg.ivar                        = 2;

cfg.neighbours                  = neighbours;
cfg.design                      = design;

for nfeat = 1:size(alldata,2)
    stat{nfeat}                 = ft_timelockstatistics(cfg,alldata{:,nfeat,1},alldata{:,nfeat,2});
end

for nfeat = 1:length(stat)
    [min_p(nfeat),p_val{nfeat}]                         = h_pValSort(stat{nfeat});
end

keep alldata list_feat min_p p_val stat

for nfeat = 1:length(stat)
    
    p_limit                                             = 0.05/3;
    
    if min_p(nfeat) < p_limit
        
        stat{nfeat}.mask                                = stat{nfeat}.prob < p_limit;
        
        subplot(2,2,nfeat)
        hold on;
        
        list_sig                                        = {};
        
        for nchan = 1:length(stat{nfeat}.label)
            
            tmp                                         = stat{nfeat}.mask(nchan,:) .* stat{nfeat}.prob(nchan,:);
            ix                                          = unique(tmp);
            ix                                          = ix(ix~=0);
            
            if ~isempty(ix)
                
                tmp                                     = stat{nfeat}.mask(nchan,:) .* stat{nfeat}.stat(nchan,:);
                
                plot(stat{nfeat}.time,tmp,'LineWidth',2);
                xlim([stat{nfeat}.time([1 end])]);
%                 ylim([0 7]);
                
                list_sig{end+1}                         = upper(stat{nfeat}.label{nchan});
                
                title([upper(list_feat{nfeat})]);
                set(gca,'FontSize',20,'FontName', 'Calibri');
                
            end
            
            
        end
        
        legend(list_sig); clear list_sig;
        
    end
end