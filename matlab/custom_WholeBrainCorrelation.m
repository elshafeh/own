clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

load ../data/template/template_grid_0.5cm.mat

[~,suj_group{1},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_list            = suj_group{1}(2:22);
for sb = 1:length(suj_list)
    
    suj                     = suj_list{sb};
    
    list_cond_main          = {'','1','2'};
    list_time               = 'p100p300';
    list_freq               = '60t100Hz';
    ext_comp                ='dpssFixedCommonDicSourceMinEvoked0.5cm.mat'; %
    
    for ncond = 1:length(list_cond_main)
        
        dir_data                                = '../data/all_dis_data/';
        fname                                   = [dir_data suj '.fDIS'  list_cond_main{ncond} '.' list_freq '.' list_time '.' ext_comp];
        
        fprintf('Loading %50s\n',fname);
        load(fname);
        
        bsl_source                              = source; clear source
        
        fname                                   = [dir_data suj '.DIS'   list_cond_main{ncond} '.' list_freq '.' list_time '.' ext_comp];
        fprintf('Loading %50s\n',fname);
        load(fname);
        
        act_source                              = source; clear source ;
        
        pow                                     = act_source-bsl_source ; % act_source; % (act_source-bsl_source)./bsl_source; %
        pow(isnan(pow))                         = 0;
        
        allsuj_avg{sb,ncond}.pow                = pow;
        allsuj_avg{sb,ncond}.pos                = template_grid.pos ;
        allsuj_avg{sb,ncond}.dim                = template_grid.dim ;
        allsuj_avg{sb,ncond}.inside             = template_grid.inside;
        
        clear pow act_source bsl_source
        
    end
    
    allsuj_avg{sb,4}                = allsuj_avg{sb,3};
    allsuj_avg{sb,4}.pow            = allsuj_avg{sb,3}.pow - allsuj_avg{sb,2}.pow;
    
    list_ix_dis                     = 1:2;
    [medAll,~,~,~,~,~,~,~]          = h_behav_eval(suj,0:2,list_ix_dis,1:4);
    
    list_ix_dis                     = 1;
    [medOne,~,~,~,~,~,~,~]          = h_behav_eval(suj,0:2,list_ix_dis,1:4);
    
    list_ix_dis                     = 2;
    [medTwo,~,~,~,~,~,~,~]          = h_behav_eval(suj,0:2,list_ix_dis,1:4);
    
    allsuj_behav{sb,1}              = medAll;
    allsuj_behav{sb,2}              = medOne;
    allsuj_behav{sb,3}              = medTwo;
    allsuj_behav{sb,4}              = medTwo-medOne;
    
end

clearvars -except allsuj_*

for ntest = 1:size(allsuj_behav,2)
    
    cfg                                 = [];
    cfg.method                          = 'montecarlo'; cfg.statistic = 'ft_statfun_correlationT';
    cfg.correctm = 'cluster'; cfg.clusterstatistics = 'maxsum';
    
    cfg.clusteralpha                    = 0.05;
    cfg.tail                            = 0;
    cfg.clustertail                     = 0;
    cfg.alpha                           = 0.025;
    cfg.numrandomization                = 1000;
    cfg.ivar                            = 1;
    
    nsuj                                = size(allsuj_behav,1);
    cfg.design(1,1:nsuj)                = [allsuj_behav{:,ntest}];
    
    cfg.type                            = 'Spearman'; % 'Pearson'; % 
    
    stat{ntest}                         = ft_sourcestatistics(cfg, allsuj_avg{:,ntest});
    
end

for ntest = 1:length(stat)
    stat_to_plot                        = stat{ntest};
    [p_min(ntest),p_val{ntest}]         = h_pValSort(stat_to_plot);
end

list_test                               = {'Alldis','dis1','dis2','dis1mdis2'};
p_limit                                 = 0.1;

for ntest = 1:length(stat)
    if p_min(ntest) < p_limit
        
        for iside = [1 2]
            
            
            lst_side                      = {'left','right','left','right'};
            
            lst_view                      = [-95 1;95 1;0 50];
            
            z_lim                         = 5; clear source ;
            
            s2plot                        = stat{ntest};
            
            s2plot.mask                   = s2plot.prob < p_limit;
            
            source.pos                    = s2plot.pos ;
            source.dim                    = s2plot.dim ;
            tpower                        = s2plot.stat .* s2plot.mask;
            
            tpower(tpower == 0)           = NaN;
            
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
            
            title(list_test{ntest});
            
        end
    end
end