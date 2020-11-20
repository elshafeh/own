clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

[~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');
suj_group{1}    = allsuj(2:15,1);
suj_group{2}    = allsuj(2:15,2);

clear allsuj ; 

lst_group       = {'Old','Young'};

load ../data/template/template_grid_0.5cm.mat

for ngroup = 1:length(suj_group)
    
    suj_list    = suj_group{ngroup};
    
    lst_freq    = '60t100Hz';
    lst_time    = 'p100p300';
    ext_comp    = 'dpssFixedCommonDicSourceMinEvoked0.5cm.mat';
    
    for sb = 1:length(suj_list)
        
        suj                 = suj_list{sb};
        lst_sub_cond        = {''};
        
        for ncue = 1:length(lst_sub_cond)
            
            dir_data    = '../data/ageing_data/';
            fname       = [dir_data suj '.DIS' lst_sub_cond{ncue} '.' lst_freq '.' lst_time '.' ext_comp];
            fprintf('Loading %50s\n',fname);
            load(fname);
            
            act_source                                                  = source; clear source fname
            
            fname = [dir_data suj '.fDIS' lst_sub_cond{ncue}  '.' lst_freq '.' lst_time '.' ext_comp];
            fprintf('Loading %50s\n',fname);
            load(fname);
            
            bsl_source                                                  = source; clear source fname
            
            pow                                                         = (act_source-bsl_source); % ./bsl_source;
            pow(isnan(pow))                                             = 0;
            
            source_avg{ngroup}{sb,ncue}.pow                             = pow;
            source_avg{ngroup}{sb,ncue}.pos                             = template_grid.pos ;
            source_avg{ngroup}{sb,ncue}.dim                             = template_grid.dim ;
            source_avg{ngroup}{sb,ncue}.inside                          = template_grid.inside;
            
            clear act_source bsl_source pow
            
        end
        
%         source_avg{ngroup}{sb,4}                                        = source_avg{ngroup}{sb,3};
%         pow                                                             = source_avg{ngroup}{sb,3}.pow - source_avg{ngroup}{sb,2}.pow;
%         source_avg{ngroup}{sb,4}.pow                                    = pow; clear pow;
        
    end
end

for ntest = 1:size(source_avg{1},2)
    
    cfg                             = [];
    cfg.dim                         = source_avg{1}{1}.dim;
    cfg.method                      = 'montecarlo';
    cfg.statistic                   = 'indepsamplesT';
    cfg.parameter                   = 'pow';
    cfg.correctm                    = 'cluster';
    
    cfg.clusteralpha                = 0.05;             % First Threshold
    
    cfg.clusterstatistic            = 'maxsum';
    cfg.numrandomization            = 1000;
    cfg.alpha                       = 0.025;
    cfg.tail                        = 0;
    cfg.clustertail                 = 0;
    
    nsuj                            = length([source_avg{1}{:,ntest}]);
    
    cfg.design                      = [ones(1,nsuj) ones(1,nsuj)*2];
    cfg.ivar                        = 1;
    
    stat{ntest}                     = ft_sourcestatistics(cfg, source_avg{2}{:,ntest},source_avg{1}{:,ntest});
    
    [min_p(ntest),p_val{ntest}]     = h_pValSort(stat{ntest});
    
    clear cfg
end

clearvars -except source_avg stat min_p p_val lst_* ; close all ;

i           = 0 ;
p_limit     = 0.05;

for ntest = 1:length(stat)
    
    if min_p(ntest) < p_limit
        for iside = [1 2]
            
            
            lst_side                      = {'left','right','both'};
            lst_view                      = [-95 1;95 1;0 50]; % [-129 7;129 7;0 50];
            
            z_lim                         = 3;
            
            clear source ;
            
            s2plot                        = stat{ntest};
            
            s2plot.mask                   = s2plot.prob < p_limit;
            source.pos                    = s2plot.pos ;
            source.dim                    = s2plot.dim ;
            tpower                        = s2plot.stat .* s2plot.mask;
            
            tpower(tpower ==0)            = NaN;
            source.pow                    = tpower ; clear tpower;
            
            cfg                           =   [];
            cfg.method                    =   'surface';
            cfg.funparameter              =   'pow';
            cfg.funcolorlim               =   [-z_lim z_lim];
            cfg.opacitylim                =   [-z_lim z_lim];
            cfg.opacitymap                =   'rampup';
            cfg.colorbar                  =   'off';
            cfg.camlight                  =   'no';
            cfg.projmethod                =   'nearest';
            cfg.surffile                  =   ['surface_white_' lst_side{iside} '.mat'];
            cfg.surfinflated              =   ['surface_inflated_' lst_side{iside} '_caret.mat'];
            
            ft_sourceplot(cfg, source);
            view(lst_view(iside,:));
            
            title(['Test' num2str(ntest)]);
            
            fname_out                   =  '~/GoogleDrive/NeuroProj/Publications/Papers/ageing_alpha_and_gamma/NBAgeing2019/prep/';
            fname_out                   =  [fname_out 'Test' num2str(ntest) '.side.' num2str(iside+2) '.png'];
            
            saveas(gcf,fname_out);
            
            clear source;
            close all;
            
            
        end
    end
end