clear ; clc ; 

global ft_default
ft_default.spmversion = 'spm12';

[~,allsuj,~]        = xlsread('../../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');

suj_group{1}        = allsuj(2:15,1);
suj_group{2}        = allsuj(2:15,2);

lst_group           = {'Old','Young'};

load ../../data/template/template_grid_0.5cm.mat

for ngrp = 1:length(suj_group)
    
    suj_list    = suj_group{ngrp};
    
    lst_freq    = {'60t100Hz'};
    lst_time    = {'p100p300'};
    
    ext_comp    = 'dpssFixedCommonDicSourceMinEvoked0.5cm.mat'; % for paper
    
    for sb = 1:length(suj_list)
        
        suj                 = suj_list{sb};
        
        for cnd_freq = 1:length(lst_freq)
            
            for cnd_time = 1:length(lst_time)
                
                cond_main   = 'fDIS';
                
                %for paper
                dir_data    = '../../data/dis_source/';
                fname       = [dir_data suj '.' cond_main '.' lst_freq{cnd_freq} '.' lst_time{cnd_time} '.' ext_comp];
                
                
                fprintf('Loading %50s\n',fname);
                load(fname);
                
                source_avg{ngrp}{sb,cnd_freq,cnd_time,1}.pow            = source;
                source_avg{ngrp}{sb,cnd_freq,cnd_time,1}.pos            = template_grid.pos ;
                source_avg{ngrp}{sb,cnd_freq,cnd_time,1}.dim            = template_grid.dim ;
                
                clear source
                
                cond_main   = 'DIS';
                fname       = [dir_data suj '.' cond_main '.' lst_freq{cnd_freq} '.' lst_time{cnd_time} '.' ext_comp];
                fprintf('Loading %50s\n',fname);
                load(fname);
                
                source_avg{ngrp}{sb,cnd_freq,cnd_time,2}.pow            = source;
                source_avg{ngrp}{sb,cnd_freq,cnd_time,2}.pos            = template_grid.pos ;
                source_avg{ngrp}{sb,cnd_freq,cnd_time,2}.dim            = template_grid.dim ;
                
                clear source
                
            end
        end
    end
end

clearvars -except source_avg lst*

for ngrp = 1:length(source_avg)
    for cnd_freq = 1:size(source_avg{ngrp},2)
        for cnd_time = 1:size(source_avg{ngrp},3)
            
            cfg                                =   [];
            cfg.dim                            =   source_avg{1}{1}.dim;
            cfg.method                         =   'montecarlo';
            cfg.statistic                      =   'depsamplesT';
            cfg.parameter                      =   'pow';
            cfg.correctm                       =   'cluster';
            
            if ngrp == 1
                cfg.clusteralpha               =   0.05;  %% First Threshold
            else
                cfg.clusteralpha               =   0.025;  %% First Threshold
            end
            
            cfg.clusterstatistic               =   'maxsum';
            cfg.numrandomization               =   1000;
            cfg.alpha                          =   0.025;
            cfg.tail                           =   0;
            cfg.clustertail                    =   0;
            nsuj                               =   length([source_avg{ngrp}{:,cnd_freq,cnd_time,2}]);
            
            cfg.design(1,:)                    =   [1:nsuj 1:nsuj];
            cfg.design(2,:)                    =   [ones(1,nsuj) ones(1,nsuj)*2];
            cfg.uvar                           =   1;
            cfg.ivar                           =   2;
            
            stat{ngrp,cnd_freq,cnd_time}       =   ft_sourcestatistics(cfg, source_avg{ngrp}{:,cnd_freq,cnd_time,2},source_avg{ngrp}{:,cnd_freq,cnd_time,1});
            stat{ngrp,cnd_freq,cnd_time}       =   rmfield(stat{ngrp,cnd_freq,cnd_time},'cfg');
            
        end
    end
end

clearvars -except stat lst*

for ngrp = 1:size(stat,1)
    for cnd_freq = 1:size(stat,2)
        for cnd_time = 1:size(stat,3)
            [min_p(ngrp,cnd_freq,cnd_time),p_val{ngrp,cnd_freq,cnd_time}]     = h_pValSort(stat{ngrp,cnd_freq,cnd_time});
        end
    end
end

clearvars -except stat source_avg min_p p_val lst*; close all ;

p_limit = 0.05;

i = 0 ; clear who_seg

for ngrp = 1:size(stat,1)
    for cnd_time = 1:size(stat,3)
        for cnd_freq = 1:size(stat,2)
            
            for iside = 1:2
                
                lst_side                                    = {'left','right','both'};
                lst_view                                    = [-95 1;95 1;0 50];
                
                z_lim                                       = 6;
                
                clear source ;
                
                stat{ngrp,cnd_freq,cnd_time}.mask           = stat{ngrp,cnd_freq,cnd_time}.prob < p_limit;
                
                source.pos                                  = stat{ngrp,cnd_freq,cnd_time}.pos ;
                source.dim                                  = stat{ngrp,cnd_freq,cnd_time}.dim ;
                tpower                                      = stat{ngrp,cnd_freq,cnd_time}.stat .* stat{ngrp,cnd_freq,cnd_time}.mask;
                
                tpower(tpower==0)                           = NaN;
                source.pow                                  = tpower ; clear tpower;
                
                cfg                                         = [];
                cfg.method                                  = 'surface';
                cfg.funparameter                            = 'pow';
                cfg.funcolorlim                             = [-z_lim z_lim];
                cfg.opacitylim                              = [-z_lim z_lim];
                cfg.opacitymap                              = 'rampup';
                cfg.colorbar                                = 'off';
                cfg.camlight                                = 'no';
                cfg.projmethod                              = 'nearest';
                cfg.surffile                                = ['surface_white_' lst_side{iside} '.mat'];
                cfg.surfinflated                            = ['surface_inflated_' lst_side{iside} '_caret.mat'];
                ft_sourceplot(cfg, source);
                view(lst_view(iside,:))
                
                dir_data                                    = '~/Dropbox/project_me/pub/Papers/ageing_alpha_and_gamma/plosOne2019/_2prep/';
                
                saveas(gcf,[dir_data lst_group{ngrp} '.' lst_side{iside} '.6zlim.png']);
                
                close all;
                
            end
        end
    end
end