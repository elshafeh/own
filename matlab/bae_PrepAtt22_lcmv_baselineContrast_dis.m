clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,suj_group{1},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_group{1}        = suj_group{1}(2:22);

load ../data_fieldtrip/template/template_grid_0.5cm.mat

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj                     = suj_list{sb};
        
        ext_bsl                 = 'm120m50ms';
        
        list_filter             = {'largeWindowFilter'};
        list_time               = {'p80p150ms'};
        
        for nfilt = 1:length(list_filter)
            for ntime = 1:length(list_time)
                
                fname = ['../data/' suj '/field/' suj '.DIS.' list_filter{nfilt} '.' list_time{ntime} '.lcmvSource.mat'];
                
                fprintf('Loading %50s\n',fname);
                load(fname);
                
                source_avg{ngroup}{sb,nfilt,ntime,1}.pow            = source;
                source_avg{ngroup}{sb,nfilt,ntime,1}.pos            = template_grid.pos ;
                source_avg{ngroup}{sb,nfilt,ntime,1}.dim            = template_grid.dim ;
                
                fname = ['../data/' suj '/field/' suj '.fDIS.' list_filter{nfilt} '.' list_time{ntime} '.lcmvSource.mat'];
                
                fprintf('Loading %50s\n',fname);
                load(fname);
                
                source_avg{ngroup}{sb,nfilt,ntime,2}.pow            = source;
                source_avg{ngroup}{sb,nfilt,ntime,2}.pos            = template_grid.pos ;
                source_avg{ngroup}{sb,nfilt,ntime,2}.dim            = template_grid.dim ;
                
            end
        end
    end
end

clearvars -except source_avg list_*

for ngroup = 1:length(source_avg)
    for nfilt = 1:size(source_avg{ngroup},2)
        for ntime = 1:size(source_avg{ngroup},3)
            
            cfg                                =   [];
            cfg.dim                            =   source_avg{1}{1}.dim;
            cfg.method                         =   'montecarlo';
            cfg.statistic                      =   'depsamplesT';
            cfg.parameter                      =   'pow';
            cfg.correctm                       =   'cluster';
            
            cfg.clusteralpha                   =   0.0001;             % First Threshold
            
            cfg.clusterstatistic               =   'maxsum';
            cfg.numrandomization               =   1000;
            cfg.alpha                          =   0.025;
            cfg.tail                           =   0;
            cfg.clustertail                    =   0;
            
            nsuj                               =   length([source_avg{ngroup}{:,nfilt,ntime,2}]);
            cfg.design(1,:)                    =   [1:nsuj 1:nsuj];
            cfg.design(2,:)                    =   [ones(1,nsuj) ones(1,nsuj)*2];
            
            cfg.uvar                           =   1;
            cfg.ivar                           =   2;
            stat{ngroup,nfilt,ntime}           =   ft_sourcestatistics(cfg, source_avg{ngroup}{:,nfilt,ntime,1},source_avg{ngroup}{:,nfilt,ntime,2});
            stat{ngroup,nfilt,ntime}           =   rmfield(stat{ngroup,nfilt,ntime},'cfg');
            
        end
    end
end

for ngroup = 1:size(stat,1)
    for nfilt = 1:size(stat,2)
        for ntime = 1:size(stat,3)
            [min_p(ngroup,nfilt,ntime),p_val{ngroup,nfilt,ntime}]     = h_pValSort(stat{ngroup,nfilt,ntime});
        end
    end
end

for ngroup = 1:size(stat,1)
    for nfilt = 1:size(stat,2)
        for ntime = 1:size(stat,3)
            for iside = [1 2]
                
                lst_side                = {'left','right','both'};
                lst_view                = [-95 1;95 1;0 50];
                
                z_lim                   = 6; % change limit of graph
                
                clear source ;
                
                stat{ngroup,nfilt,ntime}.mask               = stat{ngroup,nfilt,ntime}.prob < 0.05;
                
                source.pos                                  = stat{ngroup,nfilt,ntime}.pos ;
                source.dim                                  = stat{ngroup,nfilt,ntime}.dim ;
                tpower                                      = stat{ngroup,nfilt,ntime}.stat .* stat{ngroup,nfilt,ntime}.mask;
                
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
                
                title([list_filter{nfilt} '.' list_time{ntime}])
                
            end
        end
    end
end
