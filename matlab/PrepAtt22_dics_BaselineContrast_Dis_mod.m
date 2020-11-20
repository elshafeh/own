clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/')); close all;

% [~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');

[~,suj_group{1},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_group{1}        = suj_group{1}(2:22);

load ../data/template/template_grid_0.5cm.mat

for ngrp = 1:length(suj_group)
    
    suj_list    = suj_group{ngrp};
    
    lst_freq    = {'20t30Hz','2t6Hz'};
    lst_time    = {'p300p600','p100p500'};
    
    ext_comp    = 'dpssFixedCommonDicSourceMinEvoked0.5cm.mat';
    
    for sb = 1:length(suj_list)
        
        suj                 = suj_list{sb};
        
        for cnd_freq = 1:length(lst_freq)
            
            cond_main   = 'fDIS1';
            dir_data    = '../data/dis_thetabeta_data/';
            
            fname       = [dir_data suj '.' cond_main '.' lst_freq{cnd_freq} '.' lst_time{cnd_freq} '.' ext_comp];
            fprintf('Loading %50s\n',fname);
            load(fname);
            
            source_avg{ngrp}{sb,cnd_freq,1}.pow            = source;
            source_avg{ngrp}{sb,cnd_freq,1}.pos            = template_grid.pos ;
            source_avg{ngrp}{sb,cnd_freq,1}.dim            = template_grid.dim ;
            
            clear source
            
            cond_main   = 'DIS1';
            fname       = [dir_data suj '.' cond_main '.' lst_freq{cnd_freq} '.' lst_time{cnd_freq} '.' ext_comp];
            fprintf('Loading %50s\n',fname);
            load(fname);
            
            source_avg{ngrp}{sb,cnd_freq,2}.pow            = source;
            source_avg{ngrp}{sb,cnd_freq,2}.pos            = template_grid.pos ;
            source_avg{ngrp}{sb,cnd_freq,2}.dim            = template_grid.dim ;
            
            clear source
            
        end
    end
end

clearvars -except source_avg lst*

for ngrp = 1:length(source_avg)
    for cnd_freq = 1:size(source_avg{ngrp},2)
        
        cfg                                 =   [];
        cfg.dim                             =   source_avg{1}{1}.dim;
        cfg.method                          =   'montecarlo';
        cfg.statistic                       =   'depsamplesT';
        cfg.parameter                       =   'pow';
        cfg.correctm                        =   'cluster';
        
        if cnd_freq == 1
            cfg.clusteralpha                    =   0.0001;             % First Threshold
        else
            cfg.clusteralpha                    =   0.001;             % First Threshold
        end
        
        cfg.clusterstatistic                =   'maxsum';
        cfg.numrandomization                =   1000;
        cfg.alpha                           =   0.025;
        cfg.tail                            =   0;
        cfg.clustertail                     =   0;
        nsuj                                =   length([source_avg{ngrp}{:,cnd_freq,2}]);
        cfg.design(1,:)                     =   [1:nsuj 1:nsuj];
        cfg.design(2,:)                     =   [ones(1,nsuj) ones(1,nsuj)*2];
        cfg.uvar                            =   1;
        cfg.ivar                            =   2;
        stat{ngrp,cnd_freq}                 =   ft_sourcestatistics(cfg, source_avg{ngrp}{:,cnd_freq,2},source_avg{ngrp}{:,cnd_freq,1});
        
    end
end

clearvars -except stat lst*

for ngrp = 1:size(stat,1)
    for cnd_freq = 1:size(stat,2)
        [min_p(ngrp,cnd_freq),p_val{ngrp,cnd_freq}]     = h_pValSort(stat{ngrp,cnd_freq});
    end
end

clearvars -except stat source_avg min_p p_val lst*; close all ;

p_limit = 0.05;

% i = 0 ; clear who_seg ,
%
% for ngrp = 1:size(stat,1)
%     for cnd_freq = 1:size(stat,2)
%         for cnd_time = 1:size(stat,3)
%             if min_p(ngrp,cnd_freq,cnd_time) < p_limit
%
%
%                 i = i + 1;
%
%                 who_seg{i,1} = [lst_time{cnd_time} '.' lst_freq{cnd_freq}];
%                 who_seg{i,2} = min_p(ngrp,cnd_freq,cnd_time);
%                 who_seg{i,3} = p_val{ngrp,cnd_freq,cnd_time};
%
%                 who_seg{i,4} = FindSigClusters(stat{ngrp,cnd_freq,cnd_time},p_limit);
%                 who_seg{i,5} = FindSigClustersWithCoordinates(stat{ngrp,cnd_freq,cnd_time},p_limit,'../documents/FrontalCoordinates.csv',0.5);
%
%
%             end
%         end
%     end
% end

for ngrp = 1:size(stat,1)
    for cnd_freq = 1:size(stat,2)
        
        for iside = [1 2]
            
            lst_side                                    = {'left','right','both'};
            lst_view                                    = [-95 1;95 1;0 50];
            
            z_lim                                       = 6;
            
            clear source ;
            
            stoplot                                     = stat{ngrp,cnd_freq};
            
            stoplot.mask                                = stoplot.prob < p_limit;
            
            source.pos                                  = stoplot.pos ;
            source.dim                                  = stoplot.dim ;
            tpower                                      = stoplot.stat .* stoplot.mask;
            
            %                 tpower(tpower<4)                            = 0;
            
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
            
            %                 saveas(gcf,['../images/spnc_hesham/dis_dics/ConcatOldYoung_alldisBaselinesource.' lst_time{cnd_time} '.' lst_freq{cnd_freq} '.' lst_side{iside} '.png']);
            %                 close all;
            
        end
    end
end