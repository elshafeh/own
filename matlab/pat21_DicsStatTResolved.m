clear ; clc ; dleiftrip_addpath ;

suj_list = [1:4 8:17];

ext_freq    = {'59t79Hz','79t99Hz','98t118Hz'};
ext_time    = {'p0p100','p100p200','p200p300','p300p400','p400p500','p500p600','p600p700','p700p800','p800p900','p900p1000','p1000p1100'};
ext_bsl     = 'm200m100';

% ext_freq    = {'60t80Hz','80t100Hz','100t120Hz'};
% ext_time    = {'p0p100','p100p200','p200p300','p300p400','p400p500','p500p600'};

[cnd_freq,cnd_time] = prepare_cnd_freq_time(ext_freq,ext_time);

load ../data/template/source_struct_template_MNIpos.mat; template_source = source ; clear source ;

for sb = 1:length(suj_list)
    
    suj = ['yc' num2str(suj_list(sb))];
    
    for conditions = 1:2
        source_avg{sb,conditions}.pow    = zeros(length(template_source.pos),length(cnd_freq),length(cnd_time));
        source_avg{sb,conditions}.pos    = template_source.pos;
        source_avg{sb,conditions}.dim    = template_source.dim;
        source_avg{sb,conditions}.freq   = cnd_freq;
        source_avg{sb,conditions}.time   = cnd_time;
        source_avg{sb,conditions}.dimord = 'pos_freq_time';
    end
    
    for nfreq = 1:length(ext_freq)
        for ntime = 1:length(ext_time)
            
            src_carr{1} =[]; src_carr{2} =[];
            
            for npart = 1:3
                
                ext_lock    = 'CnD';
                
                ext_source  = '.MinusEvokedHanning.source.mat';
                fname = dir(['../data/source/' suj '.pt' num2str(npart) '.' ext_lock '.' ext_bsl '.' ext_freq{nfreq} ext_source]);
                fprintf('Loading %50s\n',fname.name);load(['../data/source/' fname.name]);
                
                src_carr{1} = [src_carr{1} source]; clear source ;
                
                ext_lock    = 'CnD';
                fname = dir(['../data/source/' suj '.pt' num2str(npart) '.' ext_lock '.' ext_time{ntime} '.' ext_freq{nfreq} ext_source]);
                fprintf('Loading %50s\n',fname.name);load(['../data/source/' fname.name]);
                
                src_carr{2} = [src_carr{2} source]; clear source ;
                
            end
            
            for conditions = 1:2
                source_avg{sb,conditions}.pow(:,nfreq,ntime) = nanmean(src_carr{conditions},2);
            end
            
        end
    end
end

clearvars -except source_avg ;

cfg                     =   [];
cfg.dim                 =   source_avg{1,1}.dim;cfg.method              =   'montecarlo';cfg.statistic           =   'depsamplesT';cfg.parameter           =   'pow';
cfg.correctm            =   'cluster';cfg.clusterstatistic    =   'maxsum';
cfg.numrandomization    =   1000;cfg.alpha               =   0.025;
cfg.tail                =   0;cfg.clustertail         =   0;
cfg.design(1,:)         =   [1:14 1:14];
cfg.design(2,:)         =   [ones(1,14) ones(1,14)*2];
cfg.uvar                =   1;cfg.ivar                =   2;

cfg.clusteralpha        =   0.005;             % First Threshold

stat                    =   ft_sourcestatistics(cfg,source_avg{:,2},source_avg{:,1}) ;
stat.cfg                =   [];
[min_p,p_val]           =   h_pValSort(stat);

clearvars -except stat min_p source_avg p_val;

p_lim                       = 0.05;

%Plot region
indxH               = h_createIndexfieldtrip;
atlas               = ft_read_atlas('../fieldtrip-20151124/template/atlas/aal/ROI_MNI_V4.nii');

load ../data/yctot/index/final_frontal_rois.mat
indx_arsenal      = indx_arsenal(indx_arsenal(:,2) < 9,:);
list_arsenal      = list_arsenal(1:8);
indx_arsenal(:,2) = indx_arsenal(:,2) + 116;
indxH = [indxH;indx_arsenal];
atlas.tissuelabel = [atlas.tissuelabel list_arsenal];

new_list    = {};
stat.mask   = stat.prob < 0.05 ;

for region          = [1:20 23:26 31:36 57:64 69:70 79:90 117:124]
    
    %     figure;
    data            = [];
    data.time       = stat.time;
    data.freq       = stat.freq;
    data.label      = atlas.tissuelabel(region);
    
    if length(data.freq)>1
        
        data.powspctrm  = stat.stat .* stat.mask;
        data.powspctrm  = nanmean(data.powspctrm(indxH(indxH(:,2) == region,1),:,:),1);
        data.dimord     = 'chan_freq_time';
        cfg             = [];
        cfg.xlim        = [data.time(1) data.time(end)];
        cfg.zlim        = [-0.05 0.05];
        figure;
        ft_singleplotTFR(cfg,data);
        
    else
        
        avg         = stat.stat .* stat.mask;
        avg         = squeeze(nanmean(avg(indxH(indxH(:,2) == region,1),:,:),1));
        
        plot(data.time,avg,'LineWidth',5);
        xlim([data.time(1) data.time(end)])
        ylim([-6 6]);
        title(atlas.tissuelabel(region));
        
    end
    
    new_list{end+1} = atlas.tissuelabel(region);
    
end

% vox_list                    = FindSigClusters(stat,p_lim); clc ;
%
% stat.mask                   = stat.prob < p_lim;
%
% source                      = [];
% source.pos                  = stat.pos;
% source.dim                  = stat.dim;
% source.pow                  = stat.stat .* stat.mask;
%
% for iside = 1:3
%     lst_side = {'left','right','both'};
%     lst_view = [-95 1;95,11;0 50];
%
%     cfg                     =   [];
%     cfg.method              =   'surface'; cfg.funparameter        =   'pow';
%     cfg.funcolorlim         =   [-3 3]; cfg.opacitylim          =   [-3 3];
%     cfg.opacitymap          =   'rampup';
%     cfg.colorbar            =   'off'; cfg.camlight            =   'no';
%     cfg.projthresh          =   0.2;
%     cfg.projmethod          =   'nearest';
%     cfg.surffile            =   ['surface_white_' lst_side{iside} '.mat'];
%     cfg.surfinflated        =   ['surface_inflated_' lst_side{iside} '_caret.mat'];
%     ft_sourceplot(cfg, source); view(lst_view(iside,1),lst_view(iside,2))
% end