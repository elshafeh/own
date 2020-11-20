clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

% [~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');
% suj_group{1}    = allsuj(2:15,1);
% suj_group{2}    = allsuj(2:15,2);
% suj_group{1}    = [allsuj(2:15,1);allsuj(2:15,2)];

[~,suj_group{1},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_group{1}        = suj_group{1}(2:22);

load ../data/template/template_grid_0.5cm.mat

% suj_group{1}    = {'yc1','yc2', 'yc3', 'yc4', 'yc8', 'yc9', 'yc10', 'yc11', 'yc12', 'yc13', 'yc14', 'yc15', 'yc16', 'yc17'};

for ngroup = 1:length(suj_group)
    
    suj_list    = suj_group{ngroup};
    
    lst_freq    = {'60t100Hz'};
    lst_time    = {'p1300p1450'};
    lst_bsl     = 'm350m200';
    
    ext_comp    = 'hanningFixedCommonDicSourceMinEvoked0.5cm.mat';
    
    for sb = 1:length(suj_list)
        
        suj                 = suj_list{sb};
        cond_main           = 'CnD';
        
        for nfreq = 1:length(lst_freq)
            for ntime = 1:length(lst_time)
                
                
                dir_data    = '../data/pat22_targetGamma/';
                fname       = [dir_data suj '.' cond_main '.' lst_freq{nfreq} '.' lst_bsl '.' ext_comp];
                fprintf('Loading %50s\n',fname);
                load(fname);
                
                source_avg{ngroup}{sb,nfreq,ntime,1}.pow            = source;
                source_avg{ngroup}{sb,nfreq,ntime,1}.pos            = template_grid.pos ;
                source_avg{ngroup}{sb,nfreq,ntime,1}.dim            = template_grid.dim ;
                
                clear source
                
                fname = [dir_data suj '.' cond_main '.' lst_freq{nfreq} '.' lst_time{ntime}   '.' ext_comp];
                fprintf('Loading %50s\n',fname);
                load(fname);
                
                source_avg{ngroup}{sb,nfreq,ntime,2}.pow            = source;
                source_avg{ngroup}{sb,nfreq,ntime,2}.pos            = template_grid.pos ;
                source_avg{ngroup}{sb,nfreq,ntime,2}.dim            = template_grid.dim ;
                
                clear source
                
            end
        end
    end
end

clearvars -except source_avg; clc ;

for ngroup = 1:length(source_avg)
    for nfreq = 1:size(source_avg{ngroup},2)
        for ntime = 1:size(source_avg{ngroup},3)
            
            cfg                                =   [];
            cfg.dim                            =   source_avg{1}{1}.dim;
            cfg.method                         =   'montecarlo';
            cfg.statistic                      =   'depsamplesT';
            cfg.parameter                      =   'pow';
            cfg.correctm                       =   'cluster';
            
            
            cfg.clusterstatistic               =   'maxsum';
            cfg.numrandomization               =   1000;
            cfg.alpha                          =   0.025;
            cfg.tail                           =   0;
            cfg.clustertail                    =   0;
            
            nsuj                               =   length([source_avg{ngroup}{:,nfreq,ntime,2}]);
            cfg.design(1,:)                    =   [1:nsuj 1:nsuj];
            cfg.design(2,:)                    =   [ones(1,nsuj) ones(1,nsuj)*2];
            
            cfg.uvar                           =   1;
            cfg.ivar                           =   2;
            
            
            cfg.clusteralpha                   =   0.05;             % First Threshold
            stat{ngroup,nfreq,1}               =   ft_sourcestatistics(cfg, source_avg{ngroup}{:,nfreq,ntime,2},source_avg{ngroup}{:,nfreq,ntime,1});
            
            cfg.clusteralpha                   =   0.01;             % First Threshold
            stat{ngroup,nfreq,2}               =   ft_sourcestatistics(cfg, source_avg{ngroup}{:,nfreq,ntime,2},source_avg{ngroup}{:,nfreq,ntime,1});
            
            cfg.clusteralpha                   =   0.005;             % First Threshold
            stat{ngroup,nfreq,3}               =   ft_sourcestatistics(cfg, source_avg{ngroup}{:,nfreq,ntime,2},source_avg{ngroup}{:,nfreq,ntime,1});
            
        end
    end
end

clearvars -except stat source_avg

for ngroup = 1:size(stat,1)
    for nfreq = 1:size(stat,2)
        for ntime = 1:size(stat,3)
            [min_p(ngroup,nfreq,ntime),p_val{ngroup,nfreq,ntime}]     = h_pValSort(stat{ngroup,nfreq,ntime});
        end
    end
end

clearvars -except stat source_avg min_p p_val ; close all ;

for ngroup = 1:size(stat,1)
    for nfreq = 1:size(stat,2)
        for ntime = 1:size(stat,3)
            for iside = [1 2]
                
                lst_side                                    = {'left','right','both'};
                lst_view                                    = [-95 1;95,11;0 50];
                
                z_lim                                       = 5;
                
                clear source ;
                
                stat{ngroup,nfreq,ntime}.mask               = stat{ngroup,nfreq,ntime}.prob < 0.05;
                
                source.pos                                  = stat{ngroup,nfreq,ntime}.pos ;
                source.dim                                  = stat{ngroup,nfreq,ntime}.dim ;
                tpower                                      = stat{ngroup,nfreq,ntime}.stat .* stat{ngroup,nfreq,ntime}.mask;
                
                tpower(tpower == 0)                         = NaN;
                source.pow                                  = tpower ; clear tpower;
                
                cfg                                         =   [];
                cfg.method                                  =   'surface';
                cfg.funparameter                            =   'pow';
                cfg.funcolorlim                             =   [-z_lim z_lim];
                cfg.opacitylim                              =   [-z_lim z_lim];
                cfg.opacitymap                              =   'rampup';
                cfg.colorbar                                =   'off';
                cfg.camlight                                =   'no';
                cfg.projmethod                              =   'nearest';
                cfg.surffile                                =   ['surface_white_' lst_side{iside} '.mat'];
                cfg.surfinflated                            =   ['surface_inflated_' lst_side{iside} '_caret.mat'];
                ft_sourceplot(cfg, source);
                view(lst_view(iside,:))
                
            end
        end
    end
end

% i = 0 ;
%
% for ngrp = 1:size(stat,1)
%     for cnd_freq = 1:size(stat,2)
%         for cnd_time = 1:size(stat,3)
%
%             i = i + 1;
%
%             reg_list{i,1} = FindSigClusters(stat{ngrp,cnd_freq,cnd_time},0.05);
%
%         end
%     end
% end
%
% stat = stat{1};
%
% clearvars -except stat ;
%
% list_roi = {79,80,81,82};
%
% clear vox_list ; index_H = [];
%
% for ngrp = 1:size(stat,1)
%     for cnd_freq = 1:size(stat,2)
%
%         for cnd_time = 1:size(stat,3)
%             for nroi = 1:length(list_roi)
%
%                 vox_list{nroi,1} = [];
%                 vox_list{nroi,2} = {};
%
%                 for sub_roi = 1:length(list_roi{nroi})
%
%                     v_limit             = 5;
%
%                     [tmp_list,tmp_indx] = h_findStatMaxVoxelPerRegion(stat,0.05,list_roi{nroi}(sub_roi),v_limit);
%
%                     vox_list{nroi,1}    = [vox_list{nroi,1}; tmp_indx repmat(nroi,size(tmp_indx,1),1)];
%                     vox_list{nroi,2}    = [vox_list{nroi,2}; tmp_list];
%
%                 end
%
%                 vox_list{nroi,3}        = sortrows(vox_list{nroi,1},-2);
%
%                 if size(vox_list{nroi,3},1) < v_limit
%                     vox_list{nroi,4}        = vox_list{nroi,3}(:,[1 4]);
%                 else
%                     vox_list{nroi,4}        = vox_list{nroi,3}(1:v_limit,[1 4]);
%                 end
%
%             end
%         end
%     end
% end
%
% clearvars -except stat source_avg min_p p_val vox_list index_H ; close all ;
%
% for xi = 1:size(vox_list,1)
%     index_H = [index_H;vox_list{xi,4}];
% end
%
% list_H = atlas.tissuelabel(79:82);
%
% save('../data_fieldtrip/index/age_common_emergence_auditory_low_alpha_mni_based_index.mat','index_H','list_H');
%
% h_seeyourvoxels(index_H(:,1),stat{1}.pos,length(index_H))
%
%
% load rama_index.mat ;
% for ngrp = 1:size(stat,1)
%     for cnd_freq = 1:size(stat,2)
%         for cnd_time = 1:size(stat,3)
%             new_reg_list{ngrp,cnd_freq,cnd_time} = FindSigClustersWithIndex(stat{ngrp,cnd_freq,cnd_time},0.05,rama_where,rama_list);
%         end
%     end
% end
% clearvars -except new_reg_list stat min_p p_val
% save('../data_fieldtrip/index/allyoungcontrol_p600p1000lowAlpha_bsl_contrast.mat','new_reg_list');
% save('../data_fieldtrip/123OldYoungAllyoung.Dicsbeamformer3Twindows2FreqBaselineContrast.mat','stat');