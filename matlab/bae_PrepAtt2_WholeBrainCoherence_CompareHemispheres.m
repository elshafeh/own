clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/')); clc ;

load ../data_fieldtrip/template/template_grid_0.5cm.mat

for sb = 1:21
    
    suj         = ['yc' num2str(sb)] ;
    
    list_freq   = {'7t11Hz'};
    list_time   = {'m600m200','p600p1000'};
    list_cue    = {'RCnD','RNCnD','LCnD','LNCnD'};
    list_roi    = {'audL','audR'};
    
    for ncue = 1:length(list_cue)
        for nfreq = 1:length(list_freq)
            for nroi = 1:length(list_roi)
                for ntime = 1:length(list_time)
                    
                    fname_in = ['../data/' suj '/field/' suj '.' list_cue{ncue} '.' list_time{ntime} '.' list_freq{nfreq} '.OriginalPCC.0.5cm.'  ...
                        list_roi{nroi} '.plvConn.allYcLowAlphaIndex.mat'];
                    
                    fprintf('Loading %s\n',fname_in);
                    load(fname_in)
                    
                    tmp{ntime} = source;
                    
                    clear source
                    
                end
                
                source_gavg{sb,ncue,nfreq,nroi}.pow = (tmp{2}-tmp{1})./(tmp{1}); %tmp{2}-tmp{1}; %
                source_gavg{sb,ncue,nfreq,nroi}.pos = template_grid.pos;
                source_gavg{sb,ncue,nfreq,nroi}.dim = template_grid.dim;
                
                clear tmp
                
            end
        end
    end
        
    for nfreq = 1:length(list_freq)
        for nroi = 1:length(list_roi)
            cfg                                 = [];
            cfg.parameter                       = 'pow';
            cfg.operation                       = 'x1-x2';
            source_gavg{sb,5,nfreq,nroi}        = ft_math(cfg,source_gavg{sb,1,nfreq,nroi},source_gavg{sb,2,nfreq,nroi});
            source_gavg{sb,6,nfreq,nroi}        = ft_math(cfg,source_gavg{sb,3,nfreq,nroi},source_gavg{sb,4,nfreq,nroi});
        end
    end
    
    clearvars -except sb source_gavg template_grid list_*
    
end

clearvars -except source_gavg list_* *_list ;

for nfreq = 1:length(list_freq)
    for ncue = 1:length(list_cue)
        
        ix_test                                =   [2 1];
        
        for ntest = 1:size(ix_test,1)
            
            cfg                                =   [];
            cfg.dim                            =   source_gavg{1}.dim;
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
            nsuj                               =   size(source_gavg,1);
            cfg.design(1,:)                    =   [1:nsuj 1:nsuj];
            cfg.design(2,:)                    =   [ones(1,nsuj) ones(1,nsuj)*2];
            cfg.uvar                           =   1;
            cfg.ivar                           =   2;
            stat{nfreq,ncue,ntest}             =   ft_sourcestatistics(cfg, source_gavg{:,ncue,nfreq,ix_test(ntest,1)},source_gavg{:,ncue,nfreq,ix_test(ntest,2)});
            stat{nfreq,ncue,ntest}             =   rmfield(stat{nfreq,ncue,ntest},'cfg');
            
        end
    end
end

clearvars -except source_gavg list_* stat 

for nfreq = 1:size(stat,1)
    for ncue = 1:size(stat,2)
        for ntest = 1:size(stat,3)
            [min_p(nfreq,ncue,ntest),p_val{nfreq,ncue,ntest}]     = h_pValSort(stat{nfreq,ncue,ntest});
        end
    end
end

clearvars -except source_gavg list_* stat min_p p_val

list_test   = {'audRaudL'};

p_limit = 0.11;
    
who_seg = {};
i       = 0;

for nfreq = 1:size(stat,1)
    for ncue = 1:size(stat,2)
        for ntest = 1:size(stat,3)
            
            if min_p(nfreq,ncue,ntest) < p_limit
                
                i = i + 1;
                
                who_seg{i,1} = [list_test{ntest} '.' list_cue{ncue}];
                who_seg{i,2} = min_p(nfreq,ncue,ntest);
                who_seg{i,3} = p_val{nfreq,ncue,ntest};
                
            end
            
        end
    end
end

clearvars -except source_gavg list_* stat min_p p_val list_test who_seg p_limit

for nfreq = 1:size(stat,1)
    for ncue = 1:size(stat,2)
        for ntest = 1:size(stat,3)
            for iside = 3
                
                if min_p(nfreq,ncue,ntest) < p_limit
                    
                    lst_side                = {'left','right','both'};
                    lst_view                = [-95 1;95,11;0 50];
                    
                    z_lim                   = 5;
                    
                    clear source ;
                    
                    stolplot                = stat{nfreq,ncue,ntest};
                    stolplot.mask           = stolplot.prob < p_limit;
                    
                    source.pos              = stolplot.pos ;
                    source.dim              = stolplot.dim ;
                    tpower                  = stolplot.stat .* stolplot.mask;
                    tpower(tpower == 0)     = NaN;
                    source.pow              = tpower ; clear tpower;
                    
                    cfg                     =   [];
                    cfg.funcolormap         = 'jet';
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
                    view(lst_view(iside,:))
                    title([list_test{ntest} '.' list_cue{ncue}]);
                    
                end
            end
        end
    end
end

clearvars -except source_gavg list_* stat min_p p_val p_limit

i = 0 ; clear new_reg_list ;

% list_names = {'audL','audR'};
% list_names = {'occL','occR'};

for nfreq = 1:size(stat,1)
    for nroi = 1:size(stat,2)
        for ntest = 1:size(stat,3)
            
            if min_p(nfreq,ncue,ntest) < p_limit
                
                i = i + 1;
                
                new_reg_list{i,1} = FindSigClusters(stat{nfreq,ncue,ntest},p_limit);
                new_reg_list{i,2} = [list_test{ntest} '.' list_roi{nroi}];
                new_reg_list{i,3} = min_p(nfreq,ncue,ntest);
                new_reg_list{i,4} = FindSigClustersWithCoordinates(stat{nfreq,ncue,ntest},p_limit,'../data_fieldtrip/doc/FrontalCoordinates.csv',0.5);
                
            end
        end
    end
end