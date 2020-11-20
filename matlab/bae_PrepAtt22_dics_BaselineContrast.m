clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

% [~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');
%
% suj_group{1}    = allsuj(2:15,1);
% suj_group{2}    = allsuj(2:15,2);
% suj_group{3}    = [allsuj(2:15,1);allsuj(2:15,2)];

[~,suj_group{1},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_group{1}        = suj_group{1}(2:22);

load ../data_fieldtrip/template/template_grid_0.5cm.mat

for ngroup = 1:length(suj_group)
    
    suj_list    = suj_group{ngroup};
    
    lst_freq    = {'11t15Hz'};
    lst_time    = {'p600p1000'};
    
    lst_bsl     = 'm600m200';
    
    for sb = 1:length(suj_list)
        
        suj                 = suj_list{sb};
        cond_main           = 'CnD';
        
        for nfreq = 1:length(lst_freq)
            for ntime = 1:length(lst_time)
                
                %                 if strcmp(lst_freq{nfreq},'7t15Hz')
                
                ext_comp    = 'dpssFixedCommonDicSource.mat';
                
                %                 else
                %                     ext_comp    = 'dpssFixedCommonDicSource.mat';
                %                 end
                
                fname = ['../data/' suj '/field/' suj '.' cond_main '.' lst_freq{nfreq} '.' lst_bsl '.' ext_comp];
                fprintf('Loading %50s\n',fname);
                load(fname);
                
                source_avg{ngroup}{sb,nfreq,ntime,1}.pow            = source;
                source_avg{ngroup}{sb,nfreq,ntime,1}.pos            = template_grid.pos ;
                source_avg{ngroup}{sb,nfreq,ntime,1}.dim            = template_grid.dim ;
                
                clear source
                
                fname = ['../data/' suj '/field/' suj '.' cond_main '.' lst_freq{nfreq} '.' lst_time{ntime}   '.' ext_comp];
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

clearvars -except source_avg lst*; clc ;

for ngroup = 1:length(source_avg)
    for nfreq = 1:size(source_avg{ngroup},2)
        for ntime = 1:size(source_avg{ngroup},3)
            
            cfg                                =   [];
            cfg.dim                            =   source_avg{1}{1}.dim;
            cfg.method                         =   'montecarlo';
            cfg.statistic                      =   'depsamplesT';
            cfg.parameter                      =   'pow';
            cfg.correctm                       =   'cluster';
            
            cfg.clusteralpha                   =   0.05;             % First Threshold
            
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
            stat{ngroup,nfreq,ntime}           =   ft_sourcestatistics(cfg, source_avg{ngroup}{:,nfreq,ntime,2},source_avg{ngroup}{:,nfreq,ntime,1});
            stat{ngroup,nfreq,ntime}           =   rmfield(stat{ngroup,nfreq,ntime},'cfg');
            
        end
    end
end

clearvars -except stat source_avglst*

for ngroup = 1:size(stat,1)
    for nfreq = 1:size(stat,2)
        for ntime = 1:size(stat,3)
            [min_p(ngroup,nfreq,ntime),p_val{ngroup,nfreq,ntime}]     = h_pValSort(stat{ngroup,nfreq,ntime});
        end
    end
end

clearvars -except stat source_avg min_p p_val lst*; close all ;

% source.pow      = stat{1}.stat .* stat{1}.mask ; 
% source.pos      = stat{1}.pos;
% source.inside   = template_grid.inside;

% for ngroup = 1:size(stat,1)
%     for nfreq = 1:size(stat,2)
%         for ntime = 1:size(stat,3)
%             for iside = 3
%
%                 lst_side                = {'left','right','both'};
%                 lst_view                = [-95 1;95,11;0 50];
%
%                 z_lim                   = 5;
%
%                 clear source ;
%
%                 stat{ngroup,nfreq,ntime}.mask               = stat{ngroup,nfreq,ntime}.prob < 0.05;
%
%                 source.pos                                  = stat{ngroup,nfreq,ntime}.pos ;
%                 source.dim                                  = stat{ngroup,nfreq,ntime}.dim ;
%                 tpower                                      = stat{ngroup,nfreq,ntime}.stat .* stat{ngroup,nfreq,ntime}.mask;
%
%                 tpower(tpower == 0)                         = NaN;
%                 source.pow                                  = tpower ; clear tpower;
%
%                 cfg                                         =   [];
%                 cfg.funcolormap                             = 'jet';
%                 cfg.method                                  =   'surface';
%                 cfg.funparameter                            =   'pow';
%                 cfg.funcolorlim                             =   [-z_lim z_lim];
%                 cfg.opacitylim                              =   [-z_lim z_lim];
%                 cfg.opacitymap                              =   'rampup';
%                 cfg.colorbar                                =   'off';
%                 cfg.camlight                                =   'no';
%                 cfg.projmethod                              =   'nearest';
%                 cfg.surffile                                =   ['surface_white_' lst_side{iside} '.mat'];
%                 cfg.surfinflated                            =   ['surface_inflated_' lst_side{iside} '_caret.mat'];
%                 ft_sourceplot(cfg, source);
%                 view(lst_view(iside,:))
%
%             end
%         end
%     end
% end

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


for ngroup = 1:size(stat,1)
    
    for nfreq = 1:size(stat,2)
        
        for ntime = 1:size(stat,3)
            
            reg_list                    = {[79 81],[80 82]};
            index_H      = [];
            
            for nreg = 1:length(reg_list)
                for nsub = 1:length(reg_list{nreg})
                    
                    %                     tmp_index_H                 = h_createDicsMaxIndex(stat{ngroup,nfreq,ntime},0.05,reg_list{nreg}(nsub));
                    %                     index_H                     = [index_H; tmp_index_H repmat(nreg,length(tmp_index_H),1)];
                    
                    [t_vox_list,t_vox_indx]                = h_findStatMaxVoxel(stat{ngroup,nfreq,ntime},0.05,1,'R');
                    vox_index                              = h_find4NeighVoxels(t_vox_indx(1,1));
                    
                    index_H                                 = [index_H; vox_index repmat(1,length(vox_index(:,1)),1)];
                    
                    [t_vox_list,t_vox_indx]                 = h_findStatMaxVoxel(stat{ngroup,nfreq,ntime},0.05,50,'L');
                    vox_index                              = h_find4NeighVoxels(t_vox_indx(23,1));
                    
                    index_H                                 = [index_H; vox_index repmat(2,length(vox_index(:,1)),1)];

                    
                    %                     if ~isempty(t_vox_indx)
                    %                         index_H                 = [index_H; t_vox_indx(:,1) repmat(nreg,length(t_vox_indx(:,1)),1)];
                    %                     end
                    
                end
            end
        end
    end
end

list_H                          = {'occ_R','occ_L'};
% index_H                         = array_index_H{3,1};

clearvars -except index_H list_H

save('../data_fieldtrip/index/allYc_1Max4Neigh_high_alpha_occipital.mat');

% stat = stat{1};

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