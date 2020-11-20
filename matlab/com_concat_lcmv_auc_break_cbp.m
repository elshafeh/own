clear ;

global ft_default
ft_default.spmversion = 'spm12';

suj_list                        = [1:4 8:17];


for ns = 1:length(suj_list)
    
    atlas                       = ft_read_atlas('/Users/heshamelshafei/Documents/GitHub/fieldtrip/template/atlas/aal/ROI_MNI_V4.nii');
    
    zoom_axs                    = [1 2 19 20 49:54 79:82];
    roi_label                   = atlas.tissuelabel(zoom_axs);
    
    for nroi = 1:length(roi_label)
        tmp                     = roi_label{nroi};
        idx                     = strfind(tmp,'_');
        if ~isempty(idx)
            tmp(idx)            = ' ';
        end
        roi_label{nroi}         = tmp; clear tmp;
    end
    
    fname                       = ['../data/decode/meeg_dec/yc' num2str(suj_list(ns)) '.meeg.dec.bychan.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    scores                      = scores(zoom_axs,:);
    
    nb_roi                      = size(scores,1);
    
    x_axs                       = 1:nb_roi;
    %     x_axs                       = [1:2:nb_roi 2:2:nb_roi];
    
    scores                      = scores(x_axs,:);
    
    roi_label                   = roi_label(x_axs);
    
    avg                         = [];
    avg.time                    = time_axis;
    avg.label                   = roi_label;
    avg.dimord                  = 'chan_time';
    avg.avg                     = scores; clear scores;
    
    alldata{ns,1}               = avg;
    
    avg.avg(:)                  = 0.5;
    alldata{ns,2}               = avg;
    
    
end

keep alldata

nbsuj                           = size(alldata,1);
[design,neighbours]             = h_create_design_neighbours(nbsuj,alldata{1,1},'gfp','t');

cfg                             = [];
cfg.latency                     = [0.5 1.2]; %[-0.2 2];
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
stat                            = ft_timelockstatistics(cfg,alldata{:,1},alldata{:,2});
[min_p,p_val]                   = h_pValSort(stat);


stat.mask                       = stat.prob < 0.05;

list_sig                        = {};
i                               = 0;

for nchan = 1:length(stat.label)
    
    tmp                         = stat.mask(nchan,:) .* stat.prob(nchan,:);
    ix                          = unique(tmp);
    ix                          = ix(ix~=0);
    
    if ~isempty(ix)
        
        i                       =i +1;
        subplot(3,3,i);
        
        tmp                     = stat.mask(nchan,:) .* stat.stat(nchan,:);
        
        plot(stat.time,tmp,'k','LineWidth',2);
        xlim([stat.time([1 end])]);
        
        list_sig{i}             = upper(stat.label{nchan});
        
        title(upper(stat.label{nchan}));
        set(gca,'FontSize',20,'FontName', 'Calibri');
        
        vline(0,'--k');
        vline(1.2,'--k');
        
    end
end

% legend(list_sig); clear list_sig;