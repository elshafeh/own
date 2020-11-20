clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');

suj_group{1}    = allsuj(2:15,1);
suj_group{2}    = allsuj(2:15,2);

% [~,suj_group{3},~]  = xlsread('../documents/PrepAtt2_PreProcessingIndex.xlsx','B:B');
% suj_group{3}        = suj_group{3}(2:22);
% lst_group = {'Old','Young'};

load ../data_fieldtrip/template/template_grid_0.5cm.mat

for ngrp = 1:length(suj_group)
    
    suj_list    = suj_group{ngrp};
    
    lst_cnd     = {'VCnD','NCnD'}; %'RCnD','LCnD','NRCnD','NLCnD','VCnD','NCnD'};
    
    lst_time    = {'p540p790ms'}; %p500p600ms','p600p700ms','p700p800ms','p800p900ms','p900p1000ms'};
    
    lst_bsl     = 'm300m50ms';
    
    ext_comp    = 'lcmvSource.mat';
    
    for sb = 1:length(suj_list)
        
        suj                 = suj_list{sb};
        
        for ncue = 1:length(lst_cnd)
            for cnd_time = 1:length(lst_time)
                
                
                fname = ['../data/' suj '/field/' suj '.' lst_cnd{ncue} '.bigCovFilter.' lst_bsl '.' ext_comp];
                fprintf('Loading %50s\n',fname);
                load(fname);
                
                pow   = source; clear source
                
                fname = ['../data/' suj '/field/' suj '.' lst_cnd{ncue} '.bigCovFilter.' lst_time{cnd_time}   '.' ext_comp];
                fprintf('Loading %50s\n',fname);
                load(fname);
                
                bsl   = source; clear source
                
                
                source_avg{ngrp}{sb,ncue,cnd_time,1}.pow            = pow-bsl;
                source_avg{ngrp}{sb,ncue,cnd_time,1}.pos            = template_grid.pos ;
                source_avg{ngrp}{sb,ncue,cnd_time,1}.dim            = template_grid.dim ;
               
                
                source_avg{ngrp}{sb,ncue,cnd_time,2}.pow            = (pow-bsl)./bsl; clear pow bsl
                source_avg{ngrp}{sb,ncue,cnd_time,2}.pos            = template_grid.pos ;
                source_avg{ngrp}{sb,ncue,cnd_time,2}.dim            = template_grid.dim ;
                
            end
        end
    end
end

clearvars -except source_avg lst_time

for ngrp = 1:length(source_avg)
    
    ix_test = [1 2]; %1 3; 2 4; 5 6];
    
    for ntest = 1:size(ix_test,1)
        for cnd_time = 1:size(source_avg{ngrp},3)
            for nbsl = 1:2
                
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
                nsuj                               =   length([source_avg{ngrp}{:,ntest,1,nbsl}]);
                cfg.design(1,:)                    =   [1:nsuj 1:nsuj];
                cfg.design(2,:)                    =   [ones(1,nsuj) ones(1,nsuj)*2];
                cfg.uvar                           =   1;
                cfg.ivar                           =   2;
                
                stat{ngrp,ntest,cnd_time,nbsl}      =   ft_sourcestatistics(cfg, source_avg{ngrp}{:,ix_test(ntest,1),cnd_time,nbsl}, ... 
                    source_avg{ngrp}{:,ix_test(ntest,2),cnd_time,nbsl});
                
                stat{ngrp,ntest,cnd_time,nbsl}      =   rmfield(stat{ngrp,ntest,cnd_time,nbsl} ,'cfg');
                
            end
        end
    end
end

clearvars -except stat source_avg lst_time

for ngrp = 1:size(stat,1)
    for ntest =1:size(stat,2)
        for cnd_time = 1:size(stat,3)
            for nbsl = 1:size(stat,4)
                [min_p{ngrp,ntest,cnd_time,nbsl},p_val{ngrp,ntest,cnd_time,nbsl}]     = h_pValSort(stat{ngrp,ntest,cnd_time,nbsl});
            end
        end
    end
end

clearvars -except stat source_avg min_p p_val lst_time ; close all ;

lst_group = {'Old','Young'};
lst_test  = {'VmN'};
lst_bsl   = {'abs','rel'};

z_lim       = 3;
p_limit     = 0.05;

i = 0 ;

clear who_seg

for ngrp = 1:size(stat,1)
    for ntest =1:size(stat,2)
        for cnd_time = 1:size(stat,3)
            for nbsl = 1:size(stat,4)
                
                
                if min_p{ngrp,ntest,cnd_time,nbsl} < p_limit
                    
                    i = i + 1;
                    
                    who_seg{i,1} = [lst_group{ngrp} '.' lst_test{ntest} '.' lst_time{cnd_time} '.' lst_bsl{nbsl}];
                    who_seg{i,2} = min_p{ngrp,ntest,cnd_time,nbsl};
                    who_seg{i,3} = p_val{ngrp,ntest,cnd_time,nbsl};
                    
                    who_seg{i,4} = FindSigClusters(stat{ngrp,ntest,cnd_time,nbsl},p_limit);
                    who_seg{i,5} = FindSigClustersWithCoordinates(stat{ngrp,ntest,cnd_time,nbsl},p_limit,'../data_fieldtrip/doc/FrontalCoordinates.csv',0.5);
                    
                end
            end
        end
    end
end


for ngrp = 1:size(stat,1)
    for ntest =1:size(stat,2)
        for cnd_time = 1:size(stat,3)
            for nbsl = 1:size(stat,4)
                
                
                if min_p{ngrp,ntest,cnd_time,nbsl} < p_limit
                    for iside = 3
                        
                        lst_side                = {'left','right','both'};
                        lst_view                = [-95 1;95,11;0 50];
                        
                        z_lim                   = 5;
                        
                        clear source ;
                        stat2plot               = stat{ngrp,ntest,cnd_time,nbsl};
                        stat2plot.mask          = stat2plot.prob < 0.05;
                        
                        source.pos              = stat2plot.pos ;
                        source.dim              = stat2plot.dim ;
                        tpower                  = stat2plot.stat .* stat2plot.mask;
                        
                        tpower(tpower==0)       = NaN;
                        
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
                        
                    end
                end
            end
        end
    end
end
    
% load rama_index.mat ;
%
% for ngrp = 1:size(stat,1)
%     for ncue = 1:size(stat,2)
%         for cnd_time = 1:size(stat,3)
%             new_reg_list{ngrp,ncue,cnd_time} = FindSigClustersWithIndex(stat{ngrp,ncue,cnd_time},0.05,rama_where,rama_list);
%         end
%     end
% end
%
% clearvars -except new_reg_list stat min_p p_val
%
% save('../data_fieldtrip/index/allyoungcontrol_p600p1000lowAlpha_bsl_contrast.mat','new_reg_list');