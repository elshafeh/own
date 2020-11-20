clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

patient_list;

suj_group{1}                                = fp_list_meg ;
suj_group{2}                                = cn_list_meg ; clear *list* ;

load ../data/template/template_grid_0.5cm.mat

for ngrp = 1:length(suj_group)
    
    suj_list = suj_group{ngrp};
    
    lst_freq    = {''};
    
    lst_time    = {'DIS.60t100Hz.p100p300.hanning','DIS.60t100Hz.p100p300.dpss'};
    lst_bsl     = {'fDIS.60t100Hz.p100p300.hanning','fDIS.60t100Hz.p100p300.dpss'};
    
    ext_comp    = 'FixedCommonDicSourceMinEvoked0.5cm.mat';
    
    for sb = 1:length(suj_list)
        
        suj                 = suj_list{sb};
        cond_main           = '';
        lst_sub_cond       = {''};
        
        for cnd_freq = 1:length(lst_freq)
            for cnd_time = 1:length(lst_time)
                for ncue = 1:length(lst_sub_cond)
                    
                    fname = ['/Volumes/hesham_megabup/pat22_fieldtrip_data/' suj '.' lst_sub_cond{ncue} cond_main lst_freq{cnd_freq} lst_bsl{cnd_time} ext_comp];
                    fprintf('Loading %50s\n',fname);
                    load(fname);
                    
                    bsl_source                                                  = source; clear source
                    
                    fname = ['/Volumes/hesham_megabup/pat22_fieldtrip_data/' suj '.' lst_sub_cond{ncue} cond_main lst_freq{cnd_freq} lst_time{cnd_time} ext_comp];
                    fprintf('Loading %50s\n',fname);
                    load(fname);
                    
                    act_source                                                  = source; clear source
                    pow                                                         = act_source; % (act_source-bsl_source)./bsl_source; % act_source-bsl_source ; % 
                    pow(isnan(pow))                                             = 0;
                    source_avg{ngrp}{sb,cnd_freq,cnd_time,ncue}.pow             = pow;
                    source_avg{ngrp}{sb,cnd_freq,cnd_time,ncue}.pos             = template_grid.pos ;
                    source_avg{ngrp}{sb,cnd_freq,cnd_time,ncue}.dim             = template_grid.dim ;
                    source_avg{ngrp}{sb,cnd_freq,cnd_time,ncue}.inside          = template_grid.inside;
                    
                    clear act_source bsl_source
                    
                end
            end
        end
    end
end

lst_sub_cond       = {''};

clearvars -except source_avg lst_*; clc ;

for cnd_freq = 1:size(source_avg{2},2)
    for cnd_time = 1:size(source_avg{2},3)
        for ncue = 1:size(source_avg{2},4)
            
            cfg                             =   [];
            cfg.dim                         =  source_avg{1}{1}.dim;
            cfg.method                      =  'montecarlo';
            cfg.statistic                   = 'indepsamplesT';
            cfg.parameter                   = 'pow';
            
            cfg.correctm                    = 'cluster';
            
            cfg.clusteralpha                = 0.05;             % First Threshold
            
            cfg.clusterstatistic            = 'maxsum';
            cfg.numrandomization            = 1000;
            cfg.alpha                       = 0.025;
            cfg.tail                        = 0;
            cfg.clustertail                 = 0;
            
            nsuj                            = length([source_avg{1}{:,cnd_freq,cnd_time,ncue}]);
            
            cfg.design                      = [ones(1,nsuj) ones(1,nsuj)*2];
            cfg.ivar                        = 1;
            
            stat{cnd_freq,cnd_time,ncue}    =   ft_sourcestatistics(cfg, source_avg{2}{:,cnd_freq,cnd_time,ncue},source_avg{1}{:,cnd_freq,cnd_time,ncue});
            
            [min_p(cnd_freq,cnd_time,ncue), ...
                p_val{cnd_freq,cnd_time,ncue}]     = h_pValSort(stat{cnd_freq,cnd_time,ncue});

            
            clear cfg
        end
    end
end

clearvars -except source_avg stat min_p p_val lst_* ; close all ;

i           = 0 ;
p_limit     = 0.2;

for cnd_freq = 1:size(stat,1)
    for cnd_time = 1:size(stat,2)
        for ncue = 1:size(stat,3)
            if min_p(cnd_freq,cnd_time,ncue) < p_limit
                for iside = [1 2]
                    
                    
                    lst_side                      = {'left','right','both'};
                    lst_view                      = [-95 1;95,11;0 50];
                    
                    z_lim                         = 5;
                    
                    clear source ;
                    
                    s2plot                        = stat{cnd_freq,cnd_time,ncue};
                    
                    s2plot.mask                   = s2plot.prob < p_limit;
                    
                    source.pos                    = s2plot.pos ;
                    source.dim                    = s2plot.dim ;
                    tpower                        = s2plot.stat .* s2plot.mask;
                    source.pow                    = tpower ; clear tpower;
                    
                    cfg                           =   [];
                    cfg.method                    =   'surface';
                    cfg.funparameter              =   'pow';
                    cfg.funcolorlim               =   [-z_lim z_lim];
                    cfg.opacitylim                =   [-z_lim z_lim];
                    cfg.opacitymap                =   'rampup';
                    cfg.colorbar                  =   'off';
                    cfg.camlight                  =   'no';
                    cfg.projthresh                =   0.2;
                    cfg.projmethod                =   'nearest';
                    cfg.surffile                  =   ['surface_white_' lst_side{iside} '.mat'];
                    cfg.surfinflated              =   ['surface_inflated_' lst_side{iside} '_caret.mat'];
                    
                    ft_sourceplot(cfg, source);
                    view(lst_view(iside,:));
                    
                    %                     title([lst_sub_cond{ncue} 'CnD.' lst_freq{cnd_freq} '.' lst_time{cnd_time}]);
                    
                end
            end
        end
    end
end
