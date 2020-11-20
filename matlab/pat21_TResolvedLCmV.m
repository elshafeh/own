clear ; clc ; dleiftrip_addpath ;

suj_list = [1:4 8:17];

ext_time = {'p500p600ms','p600p700ms','p700p799ms','p800p900ms','p900p1000ms','p1000p1100ms'};

ext_bsl  = 'm150m49ms';

cnd_time    = 0.5:0.1:1;

load ../data/template/source_struct_template_MNIpos.mat; template_source = source ; clear source ;

for sb = 1:length(suj_list)
    
    suj = ['yc' num2str(suj_list(sb))];
    
    for conditions = 1:2
        source_avg{sb,conditions}.pow    = zeros(length(template_source.pos),length(cnd_time));
        source_avg{sb,conditions}.pos    = template_source.pos;
        source_avg{sb,conditions}.dim    = template_source.dim;
        source_avg{sb,conditions}.time   = cnd_time;
    end
    
    for ntime = 1:length(ext_time)
        
        src_carr{1} =[]; src_carr{2} =[];
        
        for npart = 1:3
            
            ext_lock    = 'CnD';
            
            fname = dir(['../data/source/' suj '.pt' num2str(npart) '.' ext_lock '.' ext_bsl '.lcmvSource.mat']);
            fprintf('Loading %50s\n',fname.name);load(['../data/source/' fname.name]);
            
            src_carr{1} = [src_carr{1} source]; clear source ;
            
            fname = dir(['../data/source/' suj '.pt' num2str(npart) '.' ext_lock '.' ext_time{ntime} '.lcmvSource.mat']);
            fprintf('Loading %50s\n',fname.name);load(['../data/source/' fname.name]);
            
            src_carr{2} = [src_carr{2} source]; clear source ;
            
        end
        
        for conditions = 1:2
            source_avg{sb,conditions}.pow(:,ntime) = nanmean(src_carr{conditions},2);
        end
        
    end
end

clearvars -except source_avg ;

cfg                     =   [];
cfg.dim                 =   source_avg{1,1}.dim;
cfg.method              =   'montecarlo';
cfg.statistic           =   'depsamplesT';
cfg.parameter           =   'pow';
cfg.correctm            =   'cluster';
cfg.clusterstatistic    =   'maxsum';
cfg.numrandomization    =   1000;
cfg.alpha               =   0.025;
cfg.tail                =   0;
cfg.clustertail         =   0;
cfg.design(1,:)         =   [1:14 1:14];
cfg.design(2,:)         =   [ones(1,14) ones(1,14)*2];
cfg.uvar                =   1;
cfg.ivar                =   2;
cfg.clusteralpha        =   0.05;             % First Threshold
stat                    =   ft_sourcestatistics(cfg,source_avg{:,2},source_avg{:,1}) ;
stat.cfg                =   [];
[min_p,p_val]           =   h_pValSort(stat);

t_lim = 0; z_lim = 5;stat.mask = stat.prob < 0.1;

% plot per window
for ntime           = length(stat.time):-1:1
    for iside = 1:2
        
        lst_side                = {'left','right','both'};
        lst_view                = [-95 1;95,11;0 50];
        lst_position            = {[50 400 500 250],[700 400 500 250],[500 50 500 250]};
        
        clear source ;
        source.pos              = stat.pos ;
        source.dim              = stat.dim ;
        tpower                  = stat.stat .* stat.mask;
        
        source.pow              = squeeze(tpower(:,ntime)) ; clear tpower;
        
        cfg                     =   [];
        cfg.method              =   'surface';
        cfg.funparameter        =   'pow';
        cfg.funcolorlim         =   [-z_lim z_lim];
        cfg.opacitylim          =   [-z_lim z_lim];
        cfg.opacitymap          =   'rampup';
        cfg.colorbar            =   'off';
        cfg.camlight            =   'no';
        cfg.projthresh          =   0.2;
        cfg.projmethod          =   'nearest';
        cfg.surffile            =   ['surface_white_' lst_side{iside} '.mat'];
        cfg.surfinflated        =   ['surface_inflated_' lst_side{iside} '_caret.mat'];
        ft_sourceplot(cfg, source);
        view(lst_view(iside,1),lst_view(iside,2))
        set(gcf,'position',lst_position{iside})
    end
end

% plot region
indxH               = h_createIndexfieldtrip;
atlas               = ft_read_atlas('../fieldtrip-20151124/template/atlas/aal/ROI_MNI_V4.nii');
% no frequency dimensions
for region          = 79:82;
    data            = [];
    data.time       = stat.time;
    data.avg        = stat.stat .* stat.mask;
    data.avg        = squeeze(nanmean(data.avg(indxH(indxH(:,2) == region,1),:,:),1));
    subplot(2,2,region-78)
    plot(data.time,data.avg);
    title(atlas.tissuelabel{region});
    xlim([data.time(1) data.time(end)])
end
