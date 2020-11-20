clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

[~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');
suj_group{1}    = allsuj(2:15,1);
suj_group{2}    = allsuj(2:15,2);

load ../data/template/template_grid_0.5cm.mat

list_group                  = {'Old','young'};

for ngroup = 1:length(suj_group)
    
    suj_list                = suj_group{ngroup};
    
    %     list_time               = {'CnD.largeWindowFilter.p600p900ms','CnD.largeWindowFilter.p900p1200ms'};
    %     list_bsl                = {'CnD.largeWindowFilter.m400m100ms','CnD.largeWindowFilter.m400m100ms'};
    
    %     list_time               = {'nDT.largeWindowFilter.p70p150ms','nDT.largeWindowFilter.p250p400ms'};
    %     list_bsl                = {'nDT.largeWindowFilter.m180m100ms','nDT.largeWindowFilter.m250m100ms'};

    list_time               = {'DIS.largeWindowFilter.p40p80ms','DIS.largeWindowFilter.p80p130ms', ...
        'DIS.largeWindowFilter.p200p250ms','DIS.largeWindowFilter.p290p340ms', ...
        'DIS.largeWindowFilter.p350p500ms'};
    
    list_bsl                = {'fDIS.largeWindowFilter.p40p80ms','fDIS.largeWindowFilter.p80p130ms', ...
        'fDIS.largeWindowFilter.p200p250ms','fDIS.largeWindowFilter.p290p340ms', ...
        'fDIS.largeWindowFilter.p350p500ms'};
    
    for sb = 1:length(suj_list)
        
        suj                 = suj_list{sb};
        
        %         list_cond_main      = {'','V','N'};
        %         list_cond_main      = {'1','V1','N1'};
        list_cond_main      = {'2','V2','N2'};
        
        for ntime = 1:length(list_time)
            for ncue = 1:length(list_cond_main)
                
                dir_data    = '../data/lcmv_data/';
                ext_source  = '.FinalcmvSource5%.mat';
                fname       = [dir_data suj '.' list_cond_main{ncue} list_bsl{ntime} ext_source];
                
                fprintf('Loading %50s\n',fname);
                load(fname);
                
                bsl_source  = source; clear source
                
                fname       = [dir_data suj '.' list_cond_main{ncue} list_time{ntime} ext_source];
                
                fprintf('Loading %50s\n',fname);
                load(fname);
                
                act_source            = source; clear source
                
                ext_bsl               = 'relchange';
                
                if strcmp(ext_bsl,'relchange')
                    pow                                           = (act_source-bsl_source)./bsl_source;
                else
                    pow                                           = act_source-bsl_source ;
                end
                
                source_avg{ngroup}{sb,ncue,ntime}.pow             = pow;
                source_avg{ngroup}{sb,ncue,ntime}.pos             = template_grid.pos ;
                source_avg{ngroup}{sb,ncue,ntime}.dim             = template_grid.dim ;
                source_avg{ngroup}{sb,ncue,ntime}.inside          = template_grid.inside;
                
                clear act_source bsl_source pow
            end
            
        end
    end
    
end

clearvars -except source_avg list* cond_main ext_*;

istat                                               = 0;

for ngroup = 1:length(source_avg)
    for ntime = 1:size(source_avg{ngroup},3)
        
        ix_test = [2 3];
            
        for ntest = 1:size(ix_test,1)
        
        cfg                                 =   [];
        cfg.dim                             =   source_avg{1}{1}.dim;
        cfg.method                          =   'montecarlo';
        cfg.statistic                       =   'depsamplesT';
        cfg.parameter                       =   'pow';
        cfg.correctm                        =   'cluster';
        
        cfg.clusteralpha                    =   0.01;             % First Threshold
        ext_p                               = num2str(cfg.clusteralpha);
        
        cfg.clusterstatistic                =   'maxsum';
        cfg.numrandomization                =   1000;
        cfg.alpha                           =   0.025;
        cfg.tail                            =   0;
        cfg.clustertail                     =   0;
        
        nsuj                                =   size(source_avg{ngroup},1);
        
        cfg.design(1,:)                     =   [1:nsuj 1:nsuj];
        cfg.design(2,:)                     =   [ones(1,nsuj) ones(1,nsuj)*2];
        cfg.uvar                            =   1;
        cfg.ivar                            =   2;
        
        
        istat                               =   istat+1;
        
        stat{istat}                         =   ft_sourcestatistics(cfg, source_avg{ngroup}{:,ix_test(ntest,1),ntime},source_avg{ngroup}{:,ix_test(ntest,2),ntime});
        stat{istat}                         =   rmfield(stat{istat},'cfg');
        
        list_test{istat}                    =   [list_time{ntime} '.' list_group{ngroup} '.'  list_cond_main{ix_test(ntest,1)} 'v' list_cond_main{ix_test(ntest,2)} '.' ext_p];
        
        end
    end
end

clearvars -except source_avg stat list* istat ext_*;

for ntime = 1:size(source_avg{1},3)
    
    ix_test = 1;
    
    for ntest = 1:size(ix_test,1)
        
        cfg                                 =   [];
        cfg.dim                             =   source_avg{1}{1}.dim;
        cfg.method                          =   'montecarlo';
        cfg.statistic                       =   'depsamplesT';
        cfg.parameter                       =   'pow';
        cfg.correctm                        =   'cluster';
        
        cfg.clusteralpha                    =   0.01;             % First Threshold
        ext_p                               = num2str(cfg.clusteralpha);
        
        cfg.clusterstatistic                =   'maxsum';
        cfg.numrandomization                =   1000;
        cfg.alpha                           =   0.025;
        cfg.tail                            =   0;
        cfg.clustertail                     =   0;
        
        nsuj                                =   size(source_avg{1},1);
        
        cfg.design(1,:)                     =   [1:nsuj 1:nsuj];
        cfg.design(2,:)                     =   [ones(1,nsuj) ones(1,nsuj)*2];
        cfg.uvar                            =   1;
        cfg.ivar                            =   2;
        
        
        istat                               =   istat+1;
        
        stat{istat}                         =   ft_sourcestatistics(cfg, source_avg{2}{:,ix_test,ntime},source_avg{1}{:,ix_test,ntime});
        stat{istat}                         =   rmfield(stat{istat},'cfg');
        
        list_test{istat}                    =   [list_time{ntime} '.' 'YoungVOld.'  list_cond_main{ix_test} '.' ext_p];
        
    end
end

clearvars -except source_avg stat list* istat ext_*;

for p_limit     = 0.02;
    
    for ntest = 1:length(stat)
        
        stolplot                            = stat{ntest};
        [min_p(ntest),p_val{ntest}]         = h_pValSort(stolplot);
        
        if min_p(ntest) < p_limit
            for iside = [1 2]
                
                lst_side                    = {'left','right','both'};
                lst_view                    = [-95 1;95 1;0 50];
                
                z_lim                       = 5;
                
                clear source ;
                
                [new_min_p,new_p_val]       = h_pValSort(stolplot);
                
                stolplot.mask               = stolplot.prob < p_limit;
                
                source.pos                  = stolplot.pos ;
                source.dim                  = stolplot.dim ;
                tpower                      = stolplot.stat .* stolplot.mask;
                tpower(tpower == 0)         = NaN;
                source.pow                  = tpower ; clear tpower;
                
                cfg                         =   [];
                cfg.method                  =   'surface';
                cfg.funparameter            =   'pow';
                cfg.funcolorlim             =   [-z_lim z_lim];
                cfg.opacitylim              =   [-z_lim z_lim];
                cfg.opacitymap              =   'rampup';
                cfg.colorbar                =   'off';
                cfg.camlight                =   'no';
                cfg.projmethod              =   'nearest';
                cfg.surffile                =   ['surface_white_' lst_side{iside} '.mat'];
                cfg.surfinflated            =   ['surface_inflated_' lst_side{iside} '_caret.mat'];
                
                ft_sourceplot(cfg, source);
                view(lst_view(iside,:))
                
                title([list_test{ntest} ' ' num2str(min_p(ntest))]);
                
                saveas(gcf,['../images/final_lcmv/' ext_bsl '.' list_test{ntest} '.side' num2str(iside) '.plimit' num2str(p_limit) '.png']);
                
                close all;
                
            end
        end
    end
end

clearvars -except source_avg stat list* istat ext_* min_p p_val;