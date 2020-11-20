clear ; clc ;

suj_list = [1:4 8:17];

cnd_freq    = {'7t11Hz'};
cnd_time    = {'m600m200','p600p1000'};

ext_end = 'NewSource' ;

for nfreq = 1:length(cnd_freq)
    
    for sb = 1:length(suj_list)
        
        suj = ['yc' num2str(suj_list(sb))];
        
        for ntime = 1:2
            
            for cp = 1:3
                
                if strcmp(suj,'yc1') || strcmp(suj,'yc14')
                    fname = ['/mnt/autofs/Aurelie/DATA/MEG/PAT_EXPE22/scripts.field/tmp_data/' suj '.pt' num2str(cp) '.CnD.' cnd_time{ntime} '.' cnd_freq{nfreq} '.' ext_end '.mat'];
                else
                    fname = ['/media/hesham.elshafei/PAT_MEG2/Fieldtripping/data/all_data/' suj '.pt' num2str(cp) '.CnD.' cnd_time{ntime} '.' cnd_freq{nfreq} '.' ext_end '.mat'];
                end
                
                fprintf('Loading %50s\n',fname);
                
                load(fname);
                
                if isstruct(source);
                    source = source.avg.pow;
                end
                
                src_carr{cp} = source ; clear source ;
                
            end
            
            load ../data_fieldtrip/template/template_grid_0.5cm.mat
            
            source_avg{sb,ntime,nfreq}.pow        = nanmean([src_carr{1} src_carr{2} src_carr{3}],2);
            source_avg{sb,ntime,nfreq}.pos        = template_grid.pos;
            source_avg{sb,ntime,nfreq}.dim        = template_grid.dim;
            
            clear src_carr
            
        end
    end
end

clearvars -except source_avg; clc ;

cfg                                =   [];
cfg.dim                            =   source_avg{1}.dim;
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
nsuj                               =   length(source_avg);
cfg.design(1,:)                    =   [1:nsuj 1:nsuj];
cfg.design(2,:)                    =   [ones(1,nsuj) ones(1,nsuj)*2];
cfg.uvar                           =   1;
cfg.ivar                           =   2;
stat                               =   ft_sourcestatistics(cfg, source_avg{:,2,1},source_avg{:,1,1});

[min_p,p_val]                      = h_pValSort(stat);

load ../data_fieldtrip/index/TD_BU_index.mat

seg_voxels = {};
i          = 0 ;

for nroi = 1:length(list_H)

    roi_zoom        = stat.stat(index_H(index_H(:,2) == nroi,1)) ;
    
    pos_zoom        = index_H(index_H(:,2) == nroi,1);
    
    val_zoom        = min(roi_zoom);
    
    if val_zoom ~= 0
        
        vox_zoom        = find(roi_zoom == val_zoom);
        
        neigh_vox       = h_find4NeighVoxels(pos_zoom(vox_zoom));
        
        i               = i + 1;
        
        seg_voxels{i,1} = neigh_vox ;
        seg_voxels{i,2} = list_H{nroi} ;
        seg_voxels{i,3} = val_zoom ;

        
    end
end
    
clearvars -except seg_voxels ; 

index_H     = [];
list_H      = {};

for nroi = 1:length(seg_voxels)
    
    index_H             = [index_H; seg_voxels{nroi,1} repmat(nroi,length(seg_voxels{nroi,1}),1)];
    list_H{end+1}       = seg_voxels{nroi,2}(11:end);
    
end

save('../data_fieldtrip/index/prep21_TDBU_5vox.mat','index_H','list_H');

% for iside = 3
%     lst_side                    = {'left','right','both'};
%     lst_view                    = [-95 1;95,11;0 50];
%
%     z_lim                       = 5;
%
%     clear source ;
%
%     stat.mask                     = stat.prob < 0.05;
%
%     source.pos                    = stat.pos ;
%     source.dim                    = stat.dim ;
%     tpower                        = stat.stat .* stat.mask;
%     source.pow                    = tpower ; clear tpower;
%
%     cfg                           =   []; cfg.method                    =   'surface'; cfg.funparameter              =   'pow';
%     cfg.funcolorlim               =   [-z_lim z_lim];
%     cfg.opacitylim                =   [-z_lim z_lim];
%     cfg.opacitymap                =   'rampup'; cfg.colorbar                  =   'off'; cfg.camlight                  =   'no';
%     cfg.projthresh                =   0.2;
%     cfg.projmethod                =   'nearest';
%     cfg.surffile                  =   ['surface_white_' lst_side{iside} '.mat'];
%     cfg.surfinflated              =   ['surface_inflated_' lst_side{iside} '_caret.mat'];
%     ft_sourceplot(cfg, source);
%     view(lst_view(iside,:))
%
%     s_act = ft_sourcegrandaverage([],source_avg{:,2});
%     s_bsl = ft_sourcegrandaverage([],source_avg{:,1});
%
%     source      = s_act;
%     source.pow  = (s_act.pow - s_bsl.pow) ./ s_bsl.pow;
%
%     z_lim                         = 0.15;
%
%     cfg                           =   [];
%     cfg.method                    =   'surface';
%     cfg.funparameter              =   'pow';
%     cfg.funcolorlim               =   [-z_lim z_lim];
%     cfg.opacitylim                =   [-z_lim z_lim];
%     cfg.opacitymap                =   'rampup';
%     cfg.colorbar                  =   'off';
%     cfg.camlight                  =   'no';
%     cfg.projthresh                =   0.2;
%     cfg.projmethod                =   'nearest';
%     cfg.surffile                  =   ['surface_white_' lst_side{iside} '.mat'];
%     cfg.surfinflated              =   ['surface_inflated_' lst_side{iside} '_caret.mat'];
%     ft_sourceplot(cfg, source);
%     view(lst_view(iside,:))
%
% end
%
