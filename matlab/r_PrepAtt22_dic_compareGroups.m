clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

suj_group{1}    = {'uc5' 'yc17' 'yc18' 'uc6' 'uc7' 'uc8' 'yc19' 'uc9' ...
  'uc10' 'yc6' 'yc5' 'yc9' 'yc20' 'yc21' 'yc12' 'uc1' 'uc4' 'yc16' 'yc4'};
suj_group{2}    = {'mg1' 'mg2' 'mg3' 'mg4' 'mg5' 'mg6' 'mg7' 'mg8' 'mg9' ...
  'mg10' 'mg11' 'mg12' 'mg13' 'mg14' 'mg15' 'mg16' 'mg17' 'mg18' 'mg19'};

lst_group       = {'Controls','Migraine'};

load ../data_fieldtrip/template/template_grid_0.5cm.mat

for ngrp = 1:length(suj_group)
    
    suj_list = suj_group{ngrp};
    
    lst_freq    = {'7t11Hz','11t15Hz'};
    lst_time    = {'p200p600','p600p1000','p1400p1800'};
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
                
                bsl_source            = source; clear source
                
                fname = ['../data/' suj '/field/' suj '.' cond_main '.' lst_freq{cnd_freq} '.' lst_time{cnd_time}   '.' ext_comp];
                fprintf('Loading %50s\n',fname);
                load(fname);
                
                act_source            = source; clear source

                pow                                                   = (act_source-bsl_source)./bsl_source;
                pow(isnan(pow))                                       = 0;
                
                source_avg{ngrp}{sb,cnd_freq,cnd_time}.pow            = pow;
                                
                source_avg{ngrp}{sb,cnd_freq,cnd_time}.pos            = template_grid.pos ;
                source_avg{ngrp}{sb,cnd_freq,cnd_time}.dim            = template_grid.dim ;
                source_avg{ngrp}{sb,cnd_freq,cnd_time}.inside         = template_grid.inside;
                
                clear act_source bsl_source
                
            end
        end
    end
end

clearvars -except source_avg ; clc ; 

for cnd_freq = 1:size(source_avg{2},2)
    for cnd_time = 1:size(source_avg{2},3)
        
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
        
        nsuj                    = length([source_avg{1}{:,cnd_freq,cnd_time}]);
        
        cfg.design              = [ones(1,nsuj) ones(1,nsuj)*2];
        cfg.ivar                = 1;
        
        stat{cnd_freq,cnd_time} =   ft_sourcestatistics(cfg, source_avg{2}{:,cnd_freq,cnd_time},source_avg{1}{:,cnd_freq,cnd_time});
        
        stat{cnd_freq,cnd_time} =   rmfield(stat{cnd_freq,cnd_time},'cfg');
        
        clear cfg
        
    end
end

clearvars -except source_avg stat; clc ; 

for cnd_freq = 1:size(stat,1)
    for cnd_time = 1:size(stat,2)
        [min_p(cnd_freq,cnd_time),p_val{cnd_freq,cnd_time}]     = h_pValSort(stat{cnd_freq,cnd_time});
    end
end

clearvars -except stat min_p p_val ; close all ;

for cnd_freq = 1:size(stat,1)
    for cnd_time = 1:size(stat,2)
        for iside = 3
            
            lst_side                      = {'left','right','both'};
            lst_view                      = [-95 1;95,11;0 50];
            
            z_lim                         = 5; clear source ;
            
            stat{cnd_freq,cnd_time}.mask  = stat{cnd_freq,cnd_time}.prob < 0.1;
            
            source.pos                    = stat{cnd_freq,cnd_time}.pos ;
            source.dim                    = stat{cnd_freq,cnd_time}.dim ;
            tpower                        = stat{cnd_freq,cnd_time}.stat .* stat{cnd_freq,cnd_time}.mask;
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
            
        end
    end
end

