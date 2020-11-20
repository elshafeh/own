clear ; clc ; dleiftrip_addpath ; close all ;

% load ../data/yctot/stat/tresolved_dics_60to140_m100p1100_0point05.mat;
load ../data/yctot/stat/tresolved_dics_60to140_m100p1100_0point005.mat
% load ../data/yctot/stat/tresolved_dics_60to140_m100p1100_0point01.mat

load ../data/yctot/index/final_frontal_rois.mat

[min_p,p_val]           =   h_pValSort(stat);

% Check Frontal
for region          = 1:length(list_arsenal)
    subplot(6,3,region)
    if length(stat.freq)>1
        
        data            = [];
        data.time       = stat.time;
        data.freq       = stat.freq;
        data.label      = list_arsenal(region);
        data.powspctrm  = stat.stat .* stat.mask;
        data.powspctrm  = nanmean(data.powspctrm(indx_arsenal(indx_arsenal(:,2) == region,1),:,:),1);
        data.dimord     = 'chan_freq_time';
        cfg             = [];
        cfg.zlim        = [-0.1 0.1];
        ft_singleplotTFR(cfg,data);
        
    else
        
        data            = [];
        data.time       = stat.time;
        data.avg        = stat.stat .* stat.mask;
        data.avg        = squeeze(nanmean(data.avg(indx_arsenal(indx_arsenal(:,2) == region,1),:,:),1));
        plot(data.time,data.avg);
        title(list_arsenal(region));
        xlim([data.time(1) data.time(end)])
        
    end
end

indxH               = h_createIndexfieldtrip;
atlas               = ft_read_atlas('../fieldtrip-20151124/template/atlas/aal/ROI_MNI_V4.nii');

figure;

% frequency dimension
for region          = 79:82;
    data            = [];
    data.time       = stat.time;
    data.freq       = stat.freq;
    data.label      = atlas.tissuelabel(region);
    data.powspctrm  = stat.stat .* stat.mask;
    data.powspctrm  = nanmean(data.powspctrm(indxH(indxH(:,2) == region,1),:,:),1);
    data.dimord     = 'chan_freq_time';
    cfg             = [];
    cfg.zlim        = [-3 3];
    subplot(2,2,region-78)
    ft_singleplotTFR(cfg,data);
end