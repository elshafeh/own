clear ; clc ;

global ft_default
ft_default.spmversion = 'spm12';

[~,allsuj,~]                    = xlsread('../../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');

suj_group{2}                    = allsuj(2:15,1);
suj_group{1}                    = allsuj(2:15,2);

lst_group                       = {'Young','Old'};

load ../../data/template/template_grid_0.5cm.mat

for ngroup = 1:length(suj_group)
    
    suj_list    = suj_group{ngroup};
    
    lst_freq    = {'7t11Hz','11t15Hz'};
    lst_time    = {'p600p1000'};
    lst_bsl     = 'm600m200';
    
    ext_comp    = 'dpssFixedCommonDicSourceMinEvoked0.5cm.mat';
    
    for sb = 1:length(suj_list)
        
        suj                 = suj_list{sb};
        cond_main           = 'CnD';
        
        for nfreq = 1:length(lst_freq)
            for ntime = 1:length(lst_time)
                
                
                dir_data    = '../../data/alpha_source/';
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
            
            
            cfg.clusteralpha                   =   0.05;             % First Threshold
            stat{ngroup,nfreq,1}               =   ft_sourcestatistics(cfg, source_avg{ngroup}{:,nfreq,ntime,2},source_avg{ngroup}{:,nfreq,ntime,1});
            
        end
    end
end

clearvars -except stat source_avg lst_*;

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
                lst_view                                    = [-95 1;95 1;0 50];
                
                z_lim                                       = 6;
                
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
                
                title([lst_group{ngroup} ' ' lst_freq{nfreq}]);
                view(lst_view(iside,:))
                
                dir_data     = '~/Dropbox/project_me/pub/Papers/ageing_alpha_and_gamma/plosOne2019/_2prep/';
                saveas(gca,[dir_data  lst_group{ngroup} ' ' lst_freq{nfreq} ' ' num2str(iside) '.6z.png']);
                
                close all;
                
            end
        end
    end
end
