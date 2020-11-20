clear ; clc ; dleiftrip_addpath ;

suj_list = [1:4 8:17];

ext_freq    = {'60t80Hz','80t100Hz','100t120Hz'};
ext_time    = {'p200p300','p300p400','p400p500','p500p600','p599p699','p700p799'...
    ,'p799p899','p899p999','p1000p1100'};

ext_bsl     = 'm200m100';

[cnd_freq,cnd_time] = prepare_cnd_freq_time(ext_freq,ext_time);

load ../data/template/source_struct_template_MNIpos.mat; template_source = source ; clear source ;

for sb = 1:length(suj_list)
    
    suj = ['yc' num2str(suj_list(sb))];
    
    lst_cnd2compare = {'R','L','N'};
    
    for ncond = 1:length(lst_cnd2compare)
        
        source_avg{sb,ncond}.pow    = zeros(length(template_source.pos),length(cnd_freq),length(cnd_time));
        source_avg{sb,ncond}.pos    = template_source.pos;
        source_avg{sb,ncond}.dim    = template_source.dim;
        source_avg{sb,ncond}.freq   = cnd_freq;
        source_avg{sb,ncond}.time   = cnd_time;
        source_avg{sb,ncond}.dimord = 'pos_freq_time';
        
        for nfreq = 1:length(ext_freq)
            for ntime = 1:length(ext_time)
                
                src_carr{1} =[]; src_carr{2} =[];
                
                for npart = 1:3
                    
                    ext_lock    = [lst_cnd2compare{ncond} 'CnD'];
                    ext_source  = '.MinusSameEvokedHanning.source.mat';
                    
                    fname = dir(['../data/source/' suj '.pt' num2str(npart) '.' ext_lock '.' ext_bsl '.' ext_freq{nfreq} ext_source]);
                    fprintf('Loading %50s\n',fname.name);load(['../data/source/' fname.name]);
                    
                    src_carr{1} = [src_carr{1} source]; clear source ;
                    
                    ext_lock    = [lst_cnd2compare{ncond} 'CnD'];
                    fname = dir(['../data/source/' suj '.pt' num2str(npart) '.' ext_lock '.' ext_time{ntime} '.' ext_freq{nfreq} ext_source]);
                    fprintf('Loading %50s\n',fname.name);load(['../data/source/' fname.name]);
                    
                    src_carr{2} = [src_carr{2} source]; clear source ;
                    
                end
                
                bsl                                             = nanmean(src_carr{1},2);
                act                                             = nanmean(src_carr{2},2);
                pow                                             = (act-bsl)./bsl; clear bsl act src_carr;
                %                 pow                                             = (act-bsl); clear bsl act src_carr;
                
                source_avg{sb,ncond}.pow(:,nfreq,ntime)    = pow ; clear pow;
                source_avg{sb,ncond}.time                  = round(source_avg{sb,ncond}.time,2);
            end
        end
    end
end

clearvars -except source_avg ; clc ;

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

stat{1}                 =   ft_sourcestatistics(cfg,source_avg{:,1},source_avg{:,3}) ;
stat{2}                 =   ft_sourcestatistics(cfg,source_avg{:,2},source_avg{:,3}) ;
stat{3}                 =   ft_sourcestatistics(cfg,source_avg{:,1},source_avg{:,2}) ;

for cnd_s = 1:length(stat)
    [min_p(cnd_s),p_val{cnd_s}]        =   h_pValSort(stat{cnd_s});
end

for cnd_s = 1:length(stat)
    reg_list{cnd_s}                    = FindSigClustersMultiDimension(stat{cnd_s},0.2);
end

% indxH               = h_createIndexfieldtrip;
% atlas               = ft_read_atlas('../fieldtrip-20151124/template/atlas/aal/ROI_MNI_V4.nii');
%
% load ../data/yctot/index/final_frontal_rois.mat
% indx_arsenal        = indx_arsenal(indx_arsenal(:,2) < 9,:);
% list_arsenal        = list_arsenal(1:8);
% indx_arsenal(:,2)   = indx_arsenal(:,2) + 116;
% indxH               = [indxH;indx_arsenal];
% atlas.tissuelabel   = [atlas.tissuelabel list_arsenal];

% for region          = [1:20 23:26 31:36 57:64 69:70 79:90 117:124]
%
%     figure; hold on;
%
%     for cnd_s = 1:length(stat);
%
%         stat{cnd_s}.mask   = stat{cnd_s}.prob < 0.3 ;
%
%         data            = [];
%         data.time       = stat{cnd_s}.time;
%         data.freq       = stat{cnd_s}.freq;
%         data.label      = atlas.tissuelabel(region);
%
%         avg             = stat{cnd_s}.stat .* stat{cnd_s}.mask;
%         avg             = squeeze(nanmean(avg(indxH(indxH(:,2) == region,1),:,:),1));
%
%         plot(data.time,avg,'LineWidth',5);
%         xlim([data.time(1) data.time(end)])
%         ylim([-2 2]);
%         title(atlas.tissuelabel(region));
%
%     end
%
%     legend({'RmN','LmN','RmL'});
%
% end

% for cnd_s = 1
%     t_lim = 0; z_lim = 5;stat{cnd_s}.mask = stat{cnd_s}.prob < 0.2;
%     big_pow = stat{cnd_s}.mask .* stat{cnd_s}.stat;
%
%     for nregion = 1:length(atlas.tissuelabel)
%
%         ix  = indxH(indxH(:,2)==nregion,1);
%         pow = nanmean(big_pow(ix,:,:),1);
%
%         if nanmean(nanmean(pow)) ~= 0
%
%             freq.powspctrm = pow;
%             freq.time      = stat{cnd_s}.time;
%             freq.freq      = stat{cnd_s}.freq;
%             freq.label     = atlas.tissuelabel(nregion);
%             freq.dimord    = 'chan_freq_time';
%
%             cfg            = []; figure;
%             cfg.zlim       = [-0.05 0.05];
%             ft_singleplotTFR(cfg,freq); clear freq pow;clc;
%
%         end
%     end
%
% end

% plot per window

for cnd_s = 3
    
    t_lim = 0; z_lim = 5;stat{cnd_s}.mask = stat{cnd_s}.prob < 0.1;
    
    for ntime    = 5:6
        for iside = 1:2
            
            lst_side                = {'left','right','both'};
            lst_view                = [-95 1;95,11;0 50];
            lst_position            = {[50 400 500 250],[700 400 500 250],[500 50 500 250]};
            
            clear source ;
            source.pos              = stat{cnd_s}.pos ;
            source.dim              = stat{cnd_s}.dim ;
            tpower                  = stat{cnd_s}.stat .* stat{cnd_s}.mask;
            tpower                  = squeeze(nanmean(tpower,2));
            source.pow              = squeeze(tpower(:,ntime)); clear tpower;
            
            cfg                     =   [];
            cfg.method              =   'surface';
            cfg.funparameter        =   'pow';
            cfg.funcolorlim         =   [-z_lim z_lim];cfg.opacitylim          =   [-z_lim z_lim];
            cfg.opacitymap          =   'rampup';cfg.colorbar            =   'off';
            cfg.camlight            =   'no';
            cfg.projthresh          =   0.2;
            cfg.projmethod          =   'nearest';
            cfg.surffile            =   ['surface_white_' lst_side{iside} '.mat'];
            cfg.surfinflated        =   ['surface_inflated_' lst_side{iside} '_caret.mat'];
            ft_sourceplot(cfg, source);
            view(lst_view(iside,1),lst_view(iside,2))
            %                 set(gcf,'position',lst_position{iside})
            
            clear source
            
        end
    end
end

% no frequency dimensions
% for cnd_s = 2
%     stat{cnd_s}.mask = stat{cnd_s}.prob < 0.2;
%     for region          = 79:82;
%         data            = [];
%         data.time       = stat{cnd_s}.time;
%         data.avg        = stat{cnd_s}.stat .* stat{cnd_s}.mask;
%         data.avg        = squeeze(nanmean(data.avg(indxH(indxH(:,2) == region,1),:,:),1));
%         subplot(2,2,region-78)
%         plot(data.time,data.avg);
%         title(atlas.tissuelabel{region});
%         xlim([data.time(1) data.time(end)])
%     end
% end
% plot per region