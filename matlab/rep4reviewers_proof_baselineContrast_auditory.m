clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

[~,suj_group{1},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_group{1}        = suj_group{1}(2:22);

load ../data/template/template_grid_0.5cm.mat

for ngroup = 1:length(suj_group)
    
    suj_list    = suj_group{ngroup};
    
    lst_freq    = {'R.60t100Hz','L.60t100Hz'};
    lst_time    = {'p100p200'};
    lst_bsl     = 'm200m100';
    
    ext_comp    = 'dpssFixedCommonDicSourceMinEvoked0.5cm.mat';
    
    for sb = 1:length(suj_list)
        
        suj                 = suj_list{sb};
        cond_main           = 'nDT';
        
        for nfreq = 1:length(lst_freq)
            for ntime = 1:length(lst_time)
                
                
                dir_data    = '../data/dis_rep4rev/';
                fname       = [dir_data suj '.' cond_main lst_freq{nfreq} '.' lst_bsl '.' ext_comp];
                fprintf('Loading %50s\n',fname);
                load(fname);
                
                source_avg{ngroup}{sb,nfreq,ntime,1}.pow            = source;
                source_avg{ngroup}{sb,nfreq,ntime,1}.pos            = template_grid.pos ;
                source_avg{ngroup}{sb,nfreq,ntime,1}.dim            = template_grid.dim ;
                
                clear source
                
                fname = [dir_data suj '.' cond_main lst_freq{nfreq} '.' lst_time{ntime}   '.' ext_comp];
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

clearvars -except source_avg lst_*; clc ;

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
            
            cfg.clusteralpha                   =   0.005;             % First Threshold
            stat{ngroup,nfreq,1}               =   ft_sourcestatistics(cfg, source_avg{ngroup}{:,nfreq,ntime,2},source_avg{ngroup}{:,nfreq,ntime,1});
            
        end
    end
end

clearvars -except stat source_avg lst_*

for ngroup = 1:size(stat,1)
    for nfreq = 1:size(stat,2)
        for ntime = 1:size(stat,3)
            [min_p(ngroup,nfreq,ntime),p_val{ngroup,nfreq,ntime}]     = h_pValSort(stat{ngroup,nfreq,ntime});
        end
    end
end

clearvars -except stat source_avg min_p p_val lst_*; close all ; 

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
                cfg.colorbar                                =   'yes';
                cfg.camlight                                =   'no';
                cfg.projmethod                              =   'nearest';
                cfg.surffile                                =   ['surface_white_' lst_side{iside} '.mat'];
                cfg.surfinflated                            =   ['surface_inflated_' lst_side{iside} '_caret.mat'];
                ft_sourceplot(cfg, source);
                view(lst_view(iside,:))
                
                title([lst_freq{nfreq} ' ' num2str(ntime)]);
                
                dir_out = '~/GoogleDrive/NeuroProj/Publications/Papers/distractor2018/cerebcortex2018/_rep_for_reviews/new_proof/';
                saveas(gcf,[dir_out 'proof_target60t100Hz.' lst_freq{nfreq} '.' lst_side{iside} '.png']);
                close all;
                
            end
        end
    end
end