clear ; clc ; addpath(genpath('../fieldtrip-20151124/')); close all;

[~,suj_group{1},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_group{1}        = suj_group{1}(2:22);

load ../data/template/template_grid_0.5cm.mat

for ngrp = 1:length(suj_group)
    
    suj_list    = suj_group{ngrp};
    
    list_freq    = {'.60t100Hz','1.60t100Hz','2.60t100Hz'};
    list_time    = {'p100p300'};
    
    ext_comp    = 'dpssFixedCommonDicSourceMinEvoked0.5cm.mat'; % for paper
    
    for sb = 1:length(suj_list)
        
        suj                 = suj_list{sb};
        
        for nfreq = 1:length(list_freq)
            
            for ntime = 1:length(list_time)
                
                cond_main   = 'fDIS';
                
                %for paper
                dir_data    = '../data/dis_rep4rev/';
                fname       = [dir_data suj '.' cond_main list_freq{nfreq} '.' list_time{ntime} '.' ext_comp];
                
                
                fprintf('Loading %50s\n',fname);
                load(fname);
                
                source_avg{ngrp}{sb,nfreq,ntime,1}.pow            = source;
                source_avg{ngrp}{sb,nfreq,ntime,1}.pos            = template_grid.pos ;
                source_avg{ngrp}{sb,nfreq,ntime,1}.dim            = template_grid.dim ;
                
                clear source
                
                cond_main   = 'DIS';
                fname       = [dir_data suj '.' cond_main list_freq{nfreq} '.' list_time{ntime} '.' ext_comp];
                fprintf('Loading %50s\n',fname);
                load(fname);
                
                source_avg{ngrp}{sb,nfreq,ntime,2}.pow            = source;
                source_avg{ngrp}{sb,nfreq,ntime,2}.pos            = template_grid.pos ;
                source_avg{ngrp}{sb,nfreq,ntime,2}.dim            = template_grid.dim ;
                
                clear source
                
            end
        end
    end
end

clearvars -except source_avg list*

for ngrp = 1:length(source_avg)
    for nfreq = 1:size(source_avg{ngrp},2)
        for ntime = 1:size(source_avg{ngrp},3)
            
            cfg                                 =   [];
            cfg.dim                             =   source_avg{1}{1}.dim;
            cfg.method                          =   'montecarlo';
            cfg.statistic                       =   'depsamplesT';
            cfg.parameter                       =   'pow';
            cfg.correctm                        =   'cluster';
            
            list_lusteralpha                    =   [0.001 0.005 0.025];
            
            cfg.clusteralpha                    =   list_lusteralpha(nfreq);  %% First Threshold (paper = 0.001)
            
            cfg.clusterstatistic                =   'maxsum';
            cfg.numrandomization                =   1000;
            cfg.alpha                           =   0.025;
            cfg.tail                            =   0;
            cfg.clustertail                     =   0;
            nsuj                                =   length([source_avg{ngrp}{:,nfreq,ntime,2}]);
            cfg.design(1,:)                     =   [1:nsuj 1:nsuj];
            cfg.design(2,:)                     =   [ones(1,nsuj) ones(1,nsuj)*2];
            cfg.uvar                            =   1;
            cfg.ivar                            =   2;
            stat{ngrp,nfreq,ntime}              =   ft_sourcestatistics(cfg, source_avg{ngrp}{:,nfreq,ntime,2},source_avg{ngrp}{:,nfreq,ntime,1});
            stat{ngrp,nfreq,ntime}              =   rmfield(stat{ngrp,nfreq,ntime},'cfg');
            
        end
    end
end

clearvars -except stat list*

for ngrp = 1:size(stat,1)
    for nfreq = 1:size(stat,2)
        for ntime = 1:size(stat,3)
            [min_p(ngrp,nfreq,ntime),p_val{ngrp,nfreq,ntime}]     = h_pValSort(stat{ngrp,nfreq,ntime});
        end
    end
end

clearvars -except stat source_avg min_p p_val list*; close all ;

p_limit = 0.05;

i = 0 ; clear who_seg

for ngrp = 1:size(stat,1)
    for ntime = 1:size(stat,3)
        for nfreq = 1:size(stat,2)
            
            for iside = 1:2
                
                lst_side                                    = {'left','right','both'};
                lst_view                                    = [-95 1;95 1;0 50];
                
                z_lim                                       = 5;
                
                clear source ;
                
                stat{ngrp,nfreq,ntime}.mask                 = stat{ngrp,nfreq,ntime}.prob < p_limit;
                
                source.pos                                  = stat{ngrp,nfreq,ntime}.pos ;
                source.dim                                  = stat{ngrp,nfreq,ntime}.dim ;
                tpower                                      = stat{ngrp,nfreq,ntime}.stat .* stat{ngrp,nfreq,ntime}.mask;
                
                tpower(tpower==0)                           =   NaN;
                source.pow                                  =   tpower ; clear tpower;
                
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
                
                title(list_freq{nfreq})
                
                
                dir_out = '~/GoogleDrive/NeuroProj/Publications/Papers/distractor2018/cerebcortex2018/_rep_for_reviews/';
                saveas(gcf,[dir_out 'delayCompare_BaselineContrast' list_freq{nfreq} '.' lst_side{iside} '.png']);
                close all;
                
            end
        end
    end
end