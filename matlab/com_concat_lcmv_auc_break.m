clear ;

suj_list                        = [1 2 17]; % [1:4 8:17];
atlas                           = ft_read_atlas('/Users/heshamelshafei/Documents/GitHub/fieldtrip/template/atlas/aal/ROI_MNI_V4.nii');

for ns = 1:length(suj_list)
    
    fname                       = ['/Volumes/heshamshung/alpha_compare/decode/meeg_dec/yc' num2str(suj_list(ns)) '.meeg.dec.bychan.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    x_axs                       = [1:2:90 2:2:90];
    scores                      = scores(x_axs,:);
    
    roi_label                   = atlas.tissuelabel(x_axs);
    
    freq                        = [];
    freq.time                   = time_axis;
    freq.freq                   = 1:90;
    freq.label                  = {'MEG VS EEG'};
    freq.dimord                 = 'chan_freq_time';
    freq.powspctrm(1,:,:)       = scores; clear scores;
    
    alldata{ns,1}               = freq; clear freq;
    
end

keep alldata roi_label

gavg                            = ft_freqgrandaverage([],alldata{:});

cfg                             = [];
cfg.colormap                    = brewermap(256, '*Spectral');
cfg.comment                     = 'no';

cfg.zlim                        = [0.5 0.65];
cfg.xlim                        = [0 2];
cfg.marker                      = 'off';

ft_singleplotTFR(cfg,gavg);

xticks([0 0.4 0.8 1.2 1.6 2])
list_name                       = {'CUE','0.4','0.8','TAR','1.6','2'};
xticklabels(list_name);

for nroi = 1:length(roi_label)
    
    tmp                         = roi_label{nroi};
    idx                         = strfind(tmp,'_');
    if ~isempty(idx)
        tmp(idx)                = ' ';
    end
    roi_label{nroi}             = tmp;
end

yticks([1:90]);
yticklabels(roi_label);
title(gavg.label);
set(gca,'FontSize',12,'FontName', 'Calibri');