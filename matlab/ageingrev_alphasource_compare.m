clear ; clc ;

global ft_default
ft_default.spmversion = 'spm12';

[~,allsuj,~]    = xlsread('../../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');
suj_group{1}    = allsuj(2:15,1);
suj_group{2}    = allsuj(2:15,2);
lst_group       = {'Old','Young'};

load ../../data/template/template_grid_0.5cm.mat

for ngrp = 1:length(suj_group)
    
    suj_list = suj_group{ngrp};
    
    lst_freq                = {'7t11Hz','11t15Hz'};
    
    lst_time                = {'p600p1000'};
    
    lst_bsl                 = 'm600m200';
    
    ext_comp                = 'dpssFixedCommonDicSourceMinEvoked0.5cm.mat';
    
    for sb = 1:length(suj_list)
        
        suj                 = suj_list{sb};
        cond_main           = 'CnD';
        lst_sub_cond        = {''};
        
        for nf = 1:length(lst_freq)
            for nt = 1:length(lst_time)
                for nc = 1:length(lst_sub_cond)
                    
                    dir_data                                     = '../../data/alpha_source/';
                    fname = [dir_data suj '.' cond_main lst_sub_cond{nc} '.' lst_freq{nf} '.' lst_bsl '.' ext_comp];
                    fprintf('Loading %50s\n',fname);
                    load(fname);
                    
                    bsl_source                                    = source; clear source
                    
                    fname = [dir_data suj '.' cond_main lst_sub_cond{nc} '.' lst_freq{nf} '.' lst_time{nt}   '.' ext_comp];
                    fprintf('Loading %50s\n',fname);
                    load(fname);
                    
                    act_source                                    = source; clear source
                    pow                                           = (act_source-bsl_source)./bsl_source;
                    pow(isnan(pow))                               = 0;
                    source_avg{ngrp}{sb,nf,nt,nc}.pow             = pow;
                    source_avg{ngrp}{sb,nf,nt,nc}.pos             = template_grid.pos ;
                    source_avg{ngrp}{sb,nf,nt,nc}.dim             = template_grid.dim ;
                    source_avg{ngrp}{sb,nf,nt,nc}.inside          = template_grid.inside;
                    
                    clear act_source bsl_source
                end
            end
        end
    end
end

lst_sub_cond       = {''};

clearvars -except source_avg lst_*; clc ;

for nf = 1:size(source_avg{2},2)
    for nt = 1:size(source_avg{2},3)
        for nc = 1:size(source_avg{2},4)
            
            cfg                     =   [];
            cfg.dim                 =  source_avg{1}{1}.dim;
            cfg.method              =  'montecarlo';
            cfg.statistic           = 'indepsamplesT';
            cfg.parameter           = 'pow';
            cfg.correctm            = 'cluster';
            
            cfg.clusteralpha        = 0.05;             % First Threshold
            
            cfg.clusterstatistic    = 'maxsum';
            cfg.numrandomization    = 1000;
            cfg.alpha               = 0.025;
            cfg.tail                = 0;
            cfg.clustertail         = 0;
            
            nsuj                    = length([source_avg{1}{:,nf,nt,nc}]);
            
            cfg.design              = [ones(1,nsuj) ones(1,nsuj)*2];
            cfg.ivar                = 1;
            
            stat{nf,nt,nc}          = ft_sourcestatistics(cfg, source_avg{2}{:,nf,nt,nc},source_avg{1}{:,nf,nt,nc});
            
            stat{nf,nt,nc}          =   rmfield(stat{nf,nt,nc},'cfg');
            [min_p(nf,nt,nc),p_val{nf,nt,nc}]     = h_pValSort(stat{nf,nt,nc});
            
            clear cfg
            
        end
    end
end

clearvars -except source_avg stat min_p p_val lst_* ; close all ;

i           = 0 ;
p_limit     = 0.05;

for cnd_freq = 1:size(stat,1)
    for cnd_time = 1:size(stat,2)
        for ncue = 1:size(stat,3)
            if min_p(cnd_freq,cnd_time,ncue) < p_limit
                for iside = [1 2]
                    
                    
                    lst_side                        = {'left','right','both'};
                    lst_view                        = [-95 1;95 1;0 50];
                    
                    z_lim                           = 6;
                    
                    clear source ;
                    
                    s2plot                          = stat{cnd_freq,cnd_time,ncue};
                    
                    s2plot.mask                     = s2plot.prob < p_limit;
                    
                    source.pos                      = s2plot.pos ;
                    source.dim                      = s2plot.dim ;
                    tpower                          = s2plot.stat .* s2plot.mask;
                    tpower(tpower ==0)              = NaN;
                    source.pow                      = tpower ; clear tpower;
                    
                    cfg                             =   [];
                    cfg.method                      =   'surface';
                    cfg.funparameter                =   'pow';
                    cfg.funcolorlim                 =   [-z_lim z_lim];
                    cfg.opacitylim                  =   [-z_lim z_lim];
                    cfg.opacitymap                  =   'rampup';
                    cfg.colorbar                    =   'off';
                    cfg.camlight                    =   'no';
                    cfg.projmethod                  =   'nearest';
                    cfg.surffile                    =   ['surface_white_' lst_side{iside} '.mat'];
                    cfg.surfinflated                =   ['surface_inflated_' lst_side{iside} '_caret.mat'];
                    
                    ft_sourceplot(cfg, source);
                    view(lst_view(iside,:));
                    
                    title([lst_freq{cnd_freq} ' ' lst_time{cnd_time} 'young vs old']);
                    set(gca,'FontSize',14);
                    
                    dir_data     = '~/Dropbox/project_me/pub/Papers/ageing_alpha_and_gamma/plosOne2019/_2prep/';
                    saveas(gca,[dir_data 'alpha source stat compare' num2str(iside) '.6z.png']);
                    
                    close all;
                    
                end
            end
        end
    end
end