clear ; clc ;

suj_list = [1:4 8:17];
% load ../data/yctot/index/ForCorrelation.bslcorrected.p600p100.7t11Hz.1AudL.2AudR.mat

ext_freq    = {'7t11Hz','11t15Hz'};
ext_time    = {'p800p1500'};
ext_bsl     = 'm900m200';

[cnd_freq,cnd_time] = prepare_cnd_freq_time(ext_freq,ext_time);

load ../data/template/source_struct_template_MNIpos.mat; template_source = source ; clear source ;

for sb = 1:length(suj_list)
    
    suj = ['yc' num2str(suj_list(sb))];
    
    source_avg{sb}.pow    = zeros(length(template_source.pos),length(cnd_freq),length(cnd_time));
    source_avg{sb}.pos    = template_source.pos;
    source_avg{sb}.dim    = template_source.dim;
    source_avg{sb}.freq   = cnd_freq;
    source_avg{sb}.time   = cnd_time;
    source_avg{sb}.dimord = 'pos_freq_time';
    
    for nfreq = 1:length(ext_freq)
        for ntime = 1:length(ext_time)
            
            src_carr{1} =[]; src_carr{2} =[];
            
            for npart = 1:3
                
                ext_lock    = 'CnD';
                ext_source  = '.New.source.mat';
                
                fname = dir(['../data/source/' suj '.pt' num2str(npart) '.' ext_lock '.' ext_bsl '.' ext_freq{nfreq} ext_source]);
                fprintf('Loading %50s\n',fname.name);load(['../data/source/' fname.name]);
                
                src_carr{1} = [src_carr{1} source]; clear source ;
                
                fname = dir(['../data/source/' suj '.pt' num2str(npart) '.' ext_lock '.' ext_time{ntime} '.' ext_freq{nfreq} ext_source]);
                fprintf('Loading %50s\n',fname.name);load(['../data/source/' fname.name]);
                
                src_carr{2} = [src_carr{2} source]; clear source ;
                
            end
            
            bsl                                             = nanmean(src_carr{1},2);
            act                                             = nanmean(src_carr{2},2);
            pow                                             = (act-bsl)./bsl; clear bsl act src_carr;
            %             pow                                             = (act-bsl); clear bsl act src_carr;
            
            source_avg{sb}.pow(:,nfreq,ntime)    = pow ; clear pow;
            
        end
    end
    
    load ../data/yctot/gavg/CnD_percentage_correct_gavg.mat
    
    allsuj_behav{sb,1}          = sub_per{sb};
    
    
end

clearvars -except source_avg allsuj_behav

% load ../data/yctot/rt/rt_CnD_adapt.mat ;
% load ../data/yctot/elements4alpha2gamma.correlation.mat ;
%
% % clear allsuj_behav;
%
% for sb = 1:14
%     allsuj_behav{sb,5} = mean(rt_all{sb});
%     allsuj_behav{sb,6} = median(rt_all{sb});
% end

clearvars -except source_avg allsuj_behav

cfg                         = [];
cfg.parameter               = 'pow';
cfg.method                  = 'montecarlo';
cfg.statistic               = 'ft_statfun_correlationT';
cfg.correctm                = 'cluster';
cfg.clusteralpha            = 0.005;
cfg.clusterstatistics       = 'maxsum';
cfg.tail                    = 0;
cfg.clustertail             = 0;
cfg.alpha                   = 0.025;
cfg.numrandomization        = 1000;
cfg.ivar                    = 1;
cfg.computestat             = 'yes';
corr_list                   = {'Pearson'};%,'Spearman'};

for x = 1:length(corr_list)
    for y = 1:size(allsuj_behav,2)
        
        cfg.type                    = corr_list{x};
        cfg.design(1:14)            = [allsuj_behav{:,y}];
        stat{x,y}                   = ft_sourcestatistics(cfg,source_avg{:});
        [min_p(x,y),p_val{x,y}]     = h_pValSort(stat{x,y});
        
    end
end

for x = 1:length(corr_list)
    for y = 1:size(allsuj_behav,2)      
        reg_list{x,y}                    = FindSigClustersMultiDimension(stat{x,y},0.1);
    end
end

% p_lim                       = 0.05;
%
% Plot region
% indxH               = h_createIndexfieldtrip;
% atlas               = ft_read_atlas('../fieldtrip-20151124/template/atlas/aal/ROI_MNI_V4.nii');
%
% load ../data/yctot/index/final_frontal_rois.mat
% indx_arsenal      = indx_arsenal(indx_arsenal(:,2) < 9,:);
% list_arsenal      = list_arsenal(1:8);
% indx_arsenal(:,2) = indx_arsenal(:,2) + 116;
% indxH = [indxH;indx_arsenal];
% atlas.tissuelabel = [atlas.tissuelabel list_arsenal];
%
% new_list    = {};
% stat.mask   = stat.prob < 0.05 ;
%
% for region          = [1:20 23:26 31:36 57:64 69:70 79:90 117:124]
%
%     figure;
%     data            = [];
%     data.time       = stat.time;
%     data.freq       = stat.freq;
%     data.label      = atlas.tissuelabel(region);
%
%     if length(data.freq)>1
%
%         data.powspctrm  = stat.stat .* stat.mask;
%         data.powspctrm  = nanmean(data.powspctrm(indxH(indxH(:,2) == region,1),:,:),1);
%         data.dimord     = 'chan_freq_time';
%         cfg             = [];
%         cfg.xlim        = [data.time(1) data.time(end)];
%         cfg.zlim        = [-0.05 0.05];
%         figure;
%         ft_singleplotTFR(cfg,data);
%
%     else
%
%         avg         = stat.stat .* stat.mask;
%         avg         = squeeze(nanmean(avg(indxH(indxH(:,2) == region,1),:,:),1));
%
%         plot(data.time,avg,'LineWidth',5);
%         xlim([data.time(1) data.time(end)])
%         ylim([-6 6]);
%         title(atlas.tissuelabel(region));
%
%     end
%
%     new_list{end+1} = atlas.tissuelabel(region);
%
% end
%
%
% for cnd_s = 2
%     z_lim = 5;stat{cnd_s}.mask = stat{cnd_s}.prob < 0.05;
%
%     for nfreq = 1:length(stat{cnd_s}.freq)
%         for ntime           = length(stat{cnd_s}.time):-1:1
%             for iside = 1:2
%
%                 lst_side                = {'left','right','both'};
%                 lst_view                = [-95 1;95,11;0 50];
%
%                 source                  = [];
%                 source.pos              = stat{cnd_s}.pos ;
%                 source.dim              = stat{cnd_s}.dim ;
%                 tpower                  = stat{cnd_s}.stat .* stat{cnd_s}.mask;
%
%                 source.pow              = squeeze(tpower(:,nfreq,ntime)) ; clear tpower;
%
%                 cfg                     =   [];
%                 cfg.method              =   'surface';
%                 cfg.funparameter        =   'pow';
%                 cfg.funcolorlim         =   [-z_lim z_lim];
%                 cfg.opacitylim          =   [-z_lim z_lim];
%                 cfg.opacitymap          =   'rampup';cfg.colorbar            =   'off';
%                 cfg.camlight            =   'no';
%                 cfg.projthresh          =   0.2;
%                 cfg.projmethod          =   'nearest';
%                 cfg.surffile            =   ['surface_white_' lst_side{iside} '.mat'];
%                 cfg.surfinflated        =   ['surface_inflated_' lst_side{iside} '_caret.mat'];
%                 ft_sourceplot(cfg, source);
%                 view(lst_view(iside,1),lst_view(iside,2))
%
%                 clear source
%
%             end
%         end
%     end
% end