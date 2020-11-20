clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

[~,suj_group{1},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_list            = suj_group{1}(2:22);

load ../data/template/template_grid_0.5cm.mat


for sb = 1:length(suj_list)
    
    suj                                         = suj_list{sb};
    cond_main                                   = 'CnD';
    
    ext_comp                                    = 'hanningFixedCommonDicSourceMinEvoked0.5cm.mat';
    
    lst_freq                                    = '60t100Hz';
    lst_time                                    = 'p1300p1500';
    lst_bsl                                     = 'm300m100';
    
    dir_data                                    = '../data/pat22_cnd_gamma/';
    fname                                       = [dir_data suj '.' cond_main '.' lst_freq '.' lst_bsl '.' ext_comp];
    fprintf('Loading %50s\n',fname);
    load(fname);
    
    bsl_source                                  = source ; clear source
    
    fname = [dir_data suj '.' cond_main '.' lst_freq '.' lst_time   '.' ext_comp];
    fprintf('Loading %50s\n',fname);
    load(fname);
    
    act_source                                  = source ; clear source ;
    
    cue_source                                  = (act_source-bsl_source)./bsl_source;
    
    lst_time                                    = 'p100p300';
    
    ext_comp                                    = 'dpssFixedCommonDicSourceMinEvoked0.5cm.mat';
    
    cond_main                                   = 'fDIS';
    dir_data                                    = '../data/all_dis_data/';
    
    fname                                       = [dir_data suj '.' cond_main '.' lst_freq '.' lst_time '.' ext_comp];
    fprintf('Loading %50s\n',fname);
    load(fname);
    
    bsl_source                                  = source ; clear source ;
    
    cond_main                                   = 'DIS';
    fname                                       = [dir_data suj '.' cond_main '.' lst_freq '.' lst_time '.' ext_comp];
    fprintf('Loading %50s\n',fname);
    load(fname);
    
    act_source                                  = source ; clear source ;
    
    dis_source                                  = (act_source-bsl_source)./bsl_source;
    
    source_avg{sb,1}.pow                        = cue_source;
    source_avg{sb,1}.pos                        = template_grid.pos ;
    source_avg{sb,1}.dim                        = template_grid.dim ;
    
    source_avg{sb,2}.pow                        = dis_source;
    source_avg{sb,2}.pos                        = template_grid.pos ;
    source_avg{sb,2}.dim                        = template_grid.dim ;
    
    
end

clearvars -except source_avg ;


cfg                                             =   [];
cfg.dim                                         =   source_avg{1}.dim;
cfg.method                                      =   'montecarlo';
cfg.statistic                                   =   'depsamplesT';
cfg.parameter                                   =   'pow';
cfg.correctm                                    =   'cluster';

cfg.clusteralpha                                =   0.05;             % First Threshold

cfg.clusterstatistic                            =   'maxsum';
cfg.numrandomization                            =   1000;
cfg.alpha                                       =   0.025;
cfg.tail                                        =   0;
cfg.clustertail                                 =   0;

nsuj                                            =   length([source_avg{:,2}]);
cfg.design(1,:)                                 =   [1:nsuj 1:nsuj];
cfg.design(2,:)                                 =   [ones(1,nsuj) ones(1,nsuj)*2];

cfg.uvar                                        =   1;
cfg.ivar                                        =   2;
stat                                            =   ft_sourcestatistics(cfg, source_avg{:,2},source_avg{:,1});


[min_p,p_val]                                   = h_pValSort(stat);

for iside = [1 2]
    
    lst_side                                    = {'left','right','both'};
    lst_view                                    = [-95 1;95,11;0 50];
    
    z_lim                                       = 5;
    
    clear source ;
    
    stat.mask                                   = stat.prob < 0.05;
    
    source.pos                                  = stat.pos ;
    source.dim                                  = stat.dim ;
    tpower                                      = stat.stat .* stat.mask;
    
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
    view(lst_view(iside,:))
    
end