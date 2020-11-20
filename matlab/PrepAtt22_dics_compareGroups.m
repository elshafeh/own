clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

[~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');
suj_group{1}    = allsuj(2:15,1);
suj_group{2}    = allsuj(2:15,2);
lst_group       = {'Old','Young'};

load ../data/template/template_grid_0.5cm.mat

for ngrp = 1:length(suj_group)
    
    suj_list = suj_group{ngrp};
    
    lst_freq    = {'60t100Hz'};
    lst_time    = {'p1300p1450'};
    lst_bsl     = 'm350m200';
    ext_comp    = 'hanningFixedCommonDicSourceMinEvoked0.5cm.mat';
    
    for sb = 1:length(suj_list)
        
        suj                 = suj_list{sb};
        cond_main           = 'CnD';
        lst_sub_cond        = {'R','L'};
        
        for cnd_freq = 1:length(lst_freq)
            for cnd_time = 1:length(lst_time)
                for ncue = 1:length(lst_sub_cond)
                    
                    fname = ['../data/pat22_targetGamma/' suj '.' cond_main lst_sub_cond{ncue} '.' lst_freq{cnd_freq} '.' lst_bsl '.' ext_comp];
                    fprintf('Loading %50s\n',fname);
                    load(fname);
                    
                    bsl_source                                                  = source; clear source
                    
                    fname = ['../data/pat22_targetGamma/' suj '.' cond_main lst_sub_cond{ncue} '.' lst_freq{cnd_freq} '.' lst_time{cnd_time}   '.' ext_comp];
                    fprintf('Loading %50s\n',fname);
                    load(fname);
                    
                    act_source                                                  = source; clear source
                    pow                                                         = (act_source-bsl_source)./bsl_source;
                    pow(isnan(pow))                                             = 0;
                    source_avg{ngrp}{sb,cnd_freq,cnd_time,ncue}.pow             = pow;
                    source_avg{ngrp}{sb,cnd_freq,cnd_time,ncue}.pos             = template_grid.pos ;
                    source_avg{ngrp}{sb,cnd_freq,cnd_time,ncue}.dim             = template_grid.dim ;
                    source_avg{ngrp}{sb,cnd_freq,cnd_time,ncue}.inside          = template_grid.inside;
                    
                    clear act_source bsl_source
                end
            end
        end
    end
end

lst_sub_cond       = {''};

clearvars -except source_avg lst_*; clc ;

for cnd_freq = 1:size(source_avg{2},2)
    for cnd_time = 1:size(source_avg{2},3)
        for ncue = 1:size(source_avg{2},4)
            
            cfg                     =   [];
            cfg.dim                 =  source_avg{1}{1}.dim;
            cfg.method              =  'montecarlo';
            cfg.statistic           = 'indepsamplesT';
            cfg.parameter           = 'pow';
            cfg.correctm            = 'cluster';
            
            cfg.clusteralpha        = 0.05;             % First Threshold
            
            cfg.clusterstatistic    = 'maxsum';
            cfg.numrandomization    = 1000;
            cfg.alpha               = 0.025;
            cfg.tail                = 0;
            cfg.clustertail         = 0;
            
            nsuj                    = length([source_avg{1}{:,cnd_freq,cnd_time,ncue}]);
            
            cfg.design              = [ones(1,nsuj) ones(1,nsuj)*2];
            cfg.ivar                = 1;
            
            stat{cnd_freq,cnd_time,ncue} =   ft_sourcestatistics(cfg, source_avg{2}{:,cnd_freq,cnd_time,ncue},source_avg{1}{:,cnd_freq,cnd_time,ncue});
            
            stat{cnd_freq,cnd_time,ncue} =   rmfield(stat{cnd_freq,cnd_time,ncue},'cfg');
            [min_p(cnd_freq,cnd_time,ncue),p_val{cnd_freq,cnd_time,ncue}]     = h_pValSort(stat{cnd_freq,cnd_time,ncue});
            
            clear cfg
        end
    end
end

clearvars -except source_avg stat min_p p_val lst_* ; close all ;

% for cnd_freq = 1:size(stat,1)
%     for cnd_time = 1:size(stat,2)
%         for ncue = 1:size(stat,3)
%
%             if min_p(cnd_freq,cnd_time,ncue) < p_limit
%
%                 i = i + 1;
%
%                 who_seg{i,1} = [lst_sub_cond{ncue} 'CnD.' lst_freq{cnd_freq} '.' lst_time{cnd_time}];
%                 who_seg{i,2} = min_p(cnd_freq,cnd_time,ncue);
%                 who_seg{i,3} = p_val{cnd_freq,cnd_time,ncue};
%
%                 who_seg{i,4} = FindSigClusters(stat{cnd_freq,cnd_time,ncue},p_limit);
%                 who_seg{i,5} = FindSigClustersWithCoordinates(stat{cnd_freq,cnd_time,ncue},p_limit,'../data_fieldtrip/doc/FrontalCoordinates.csv',0.5);
%
%             end
%         end
%     end
% end

clearvars -except source_avg stat min_p p_val lst_* who_seg p_limit; close all ;
%
% for cnd_freq = 1:size(stat,1)
%     for cnd_time = 1:size(stat,2)
%         for ncue = 1:size(stat,3)
%             for ngroup = 1:2
%
%                 grand_average{cnd_freq,cnd_time,ncue,ngroup} = ft_sourcegrandaverage([],source_avg{ngroup}{:,cnd_freq,cnd_time,ncue});
%
%             end
%         end
%     end
% end


i           = 0 ;
p_limit     = 0.2;

for cnd_freq = 1:size(stat,1)
    for cnd_time = 1:size(stat,2)
        for ncue = 1:size(stat,3)
            if min_p(cnd_freq,cnd_time,ncue) < p_limit
                for iside = [1 2]
                    
                    
                    lst_side                      = {'left','right','both'};
                    lst_view                      = [-95 1;95,11;0 50];
                    
                    z_lim                         = 6;
                    
                    clear source ;
                    
                    s2plot                        = stat{cnd_freq,cnd_time,ncue};
                    
                    s2plot.mask                   = s2plot.prob < p_limit;
                    
                    source.pos                    = s2plot.pos ;
                    source.dim                    = s2plot.dim ;
                    tpower                        = s2plot.stat .* s2plot.mask;
                    tpower(tpower ==0)            = NaN;
                    source.pow                    = tpower ; clear tpower;
                    
                    cfg                           =   [];
                    cfg.method                    =   'surface';
                    cfg.funparameter              =   'pow';
                    cfg.funcolorlim               =   [-z_lim z_lim];
                    cfg.opacitylim                =   [-z_lim z_lim];
                    cfg.opacitymap                =   'rampup';
                    cfg.colorbar                  =   'off';
                    cfg.camlight                  =   'no';
                    cfg.projthresh                =   0.2;
                    cfg.projmethod                =   'nearest';
                    cfg.surffile                  =   ['surface_white_' lst_side{iside} '.mat'];
                    cfg.surfinflated              =   ['surface_inflated_' lst_side{iside} '_caret.mat'];
                    
                    ft_sourceplot(cfg, source);
                    view(lst_view(iside,:));
                    
                    %                     title([lst_sub_cond{ncue} 'CnD.' lst_freq{cnd_freq} '.' lst_time{cnd_time}]);
                    
                end
            end
        end
    end
end

% data_to_box = [];
%
% for ngroup = 1:length(source_avg)
%     for sb = 1:size(source_avg{ngroup},1)
%         for cnd_freq = 1:size(source_avg{ngroup},2)
%             for cnd_time = 1:size(source_avg{ngroup},3)
%                 for ncue = 1:size(source_avg{ngroup},4)
%
%                     load ../data_fieldtrip/index/broadman_based_audiovisual_index.mat
%                     data_to_box(ngroup,sb,cnd_freq,cnd_time,ncue,:) = h_boxplot_source_data(source_avg{ngroup}{sb,cnd_freq,cnd_time,ncue},index_H,list_H);
%
%                 end
%             end
%         end
%     end
% end
%
% data_to_box = squeeze(data_to_box);
%
% y_lim        = [-0.8 0.8];
%
% subplot(2,4,1)
% boxplot(squeeze(data_to_box(:,:,7))','Labels',{'Old','Young'}) ; ylim(y_lim);title('Left Auditory Cortex') ;
% subplot(2,4,2)
% boxplot(squeeze(data_to_box(:,:,8))','Labels',{'Old','Young'}) ; ylim(y_lim);title('Right Auditory Cortex') ;
% subplot(2,4,3)
% boxplot(squeeze(mean(data_to_box(:,:,[1 3 5]),3))','Labels',{'Old','Young'}) ; ylim(y_lim);title('Left Occipital Cortex') ;
% subplot(2,4,4)
% boxplot(squeeze(mean(data_to_box(:,:,[2 4 6]),3))','Labels',{'Old','Young'}) ; ylim(y_lim);title('Right Occipital Cortex') ;
%
% clearvars -except stat
%
% atlas = ft_read_atlas('../../fieldtrip-20151124/template/atlas/aal/ROI_MNI_V4.nii');
%
% list_roi = {79,81,80,82};
%
% clear vox_list ; index_H = [];
%
% i        = 0;
%
% for nroi = 1:length(list_roi)
%
%     vox_list{nroi,1} = [];
%     vox_list{nroi,2} = {};
%
%     for sub_roi = 1:length(list_roi{nroi})
%
%         v_limit             = 5;
%
%         [tmp_list,tmp_indx] = h_findStatMaxVoxelPerRegion(stat{1},0.05,list_roi{nroi}(sub_roi),v_limit);
%
%         if ~isempty(tmp_indx)
%
%             vox_list{nroi,1}    = [vox_list{nroi,1}; tmp_indx repmat(nroi,size(tmp_indx,1),1)];
%             vox_list{nroi,2}    = [vox_list{nroi,2}; tmp_list];
%
%             i       = i + 1;
%
%             index_H = [index_H; tmp_indx repmat(i,size(tmp_indx,1),1)];
%
%         end
%
%     end
%
%     vox_list{nroi,3}            = sortrows(vox_list{nroi,1},-2);
%
%     if size(vox_list{nroi,3},1) < v_limit
%         vox_list{nroi,4}        = vox_list{nroi,3}(:,[1 4]);
%     else
%         vox_list{nroi,4}        = vox_list{nroi,3}(1:v_limit,[1 4]);
%     end
%
% end
%
% for xi = 1:size(vox_list,1)
%     index_H = [index_H;vox_list{xi,4}];
% end
%
% clearvars -except stat index_H vox_list atlas
%
% list_H = atlas.tissuelabel(unique(index_H(:,3),'stable'));
%
% save('../data_fieldtrip/index/0.5cm_NewHighAlphaLateWindowAgeContrast11Rois.mat','index_H','list_H');