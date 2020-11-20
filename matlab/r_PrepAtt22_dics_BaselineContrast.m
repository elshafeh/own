function r_PrepAtt22_dics_BaselineContrast(suj_group,fwin,twin,lst_group)

addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

% ctl = {'uc5' 'yc17' 'yc18' 'uc6' 'uc7' 'uc8' 'yc19' 'uc9' ...
%     'uc10' 'yc6' 'yc5' 'yc9' 'yc20' 'yc21' 'yc12' 'uc1' 'uc4' 'yc16' 'yc4'};
% mig = {'mg1' 'mg2' 'mg3' 'mg4' 'mg5' 'mg6' 'mg7' 'mg8' 'mg9' ...
%     'mg10' 'mg11' 'mg12' 'mg13' 'mg14' 'mg15' 'mg16' 'mg17' 'mg18' 'mg19'};
% 
% suj_group = {ctl mig};

%lst_group = {'AllYoung'};

load ../data_fieldtrip/template/template_grid_0.5cm.mat

for ngrp = 1:length(suj_group)
    
    suj_list    = suj_group{ngrp};
    
    lst_freq    = {[num2str(fwin(1)) 't' num2str(fwin(2)) 'Hz']};%lst_freq    = {'7t11Hz','11t15Hz'};
    
    lst_time    = {['p' num2str(twin(1)) 'p' num2str(twin(2))]};%lst_time    = {'p200p600','p600p1000','p1400p1800'};
    
    lst_bsl     = 'm600m200';
    
    ext_comp    = 'dpssFixedCommonDicSource.mat';
    
    for sb = 1:length(suj_list)
        
        suj                 = suj_list{sb};
        cond_main           = 'CnD';
        
        for cnd_freq = 1:length(lst_freq)
            for cnd_time = 1:length(lst_time)
                
                
                fname = ['../data/' suj '/field/' suj '.' cond_main '.' lst_freq{cnd_freq} '.' lst_bsl '.' ext_comp];
                fprintf('Loading %50s\n',fname);
                load(fname);
                
                source_avg{ngrp}{sb,cnd_freq,cnd_time,1}.pow            = source;
                source_avg{ngrp}{sb,cnd_freq,cnd_time,1}.pos            = template_grid.pos ;
                source_avg{ngrp}{sb,cnd_freq,cnd_time,1}.dim            = template_grid.dim ;
                
                clear source
                
                fname = ['../data/' suj '/field/' suj '.' cond_main '.' lst_freq{cnd_freq} '.' lst_time{cnd_time}   '.' ext_comp];
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

clearvars -except source_avg lst_group

for ngrp = 1:length(source_avg)
    for cnd_freq = 1:size(source_avg{ngrp},2)
        for cnd_time = 1:size(source_avg{ngrp},3)
            
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

clearvars -except stat source_avg lst_group

for ngrp = 1:size(stat,1)
    for cnd_freq = 1:size(stat,2)
        for cnd_time = 1:size(stat,3)
            [min_p(ngrp,cnd_freq,cnd_time),p_val{ngrp,cnd_freq,cnd_time}]     = h_pValSort(stat{ngrp,cnd_freq,cnd_time});            
        end
    end
end

clearvars -except stat source_avg min_p p_val lst_group; close all ;

% for ngrp = 1:size(stat,1)
%     for cnd_freq = 1:size(stat,2)
%         for cnd_time = 1:size(stat,3)
%             for iside = 1:3
%                 
%                 lst_side                = {'left','right','both'};
%                 lst_view                = [-95 1;95,11;0 50];
%                 
%                 z_lim                   = 5;
%                 
%                 clear source ;
%                 
%                 stat{ngrp,cnd_freq,cnd_time}.mask           = stat{ngrp,cnd_freq,cnd_time}.prob < 0.05;
%                 
%                 source.pos                                  = stat{ngrp,cnd_freq,cnd_time}.pos ;
%                 source.dim                                  = stat{ngrp,cnd_freq,cnd_time}.dim ;
%                 tpower                                      = stat{ngrp,cnd_freq,cnd_time}.stat .* stat{ngrp,cnd_freq,cnd_time}.mask;
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
%                 cfg.projthresh                              =   0.2;
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

% for ngrp = 1:size(stat,1)
%     for cnd_freq = 1:size(stat,2)
%         for cnd_time = 1:size(stat,3)
%             reg_list{ngrp,cnd_freq,cnd_time} = FindSigClusters(stat{ngrp,cnd_freq,cnd_time},0.05);
%         end
%     end
% end

load rama_index.mat ;

for ngrp = 1:size(stat,1)
    for cnd_freq = 1:size(stat,2)
        for cnd_time = 1:size(stat,3)
            new_reg_list{ngrp,cnd_freq,cnd_time} = FindSigClustersWithIndex(stat{ngrp,cnd_freq,cnd_time},0.05,rama_where,rama_list);
        end
    end
end

clearvars -except new_reg_list stat min_p p_val lst_group

save('../data_fieldtrip/index/controls-pat-mig_p600p1000lowAlpha_bsl_contrast.mat','new_reg_list');