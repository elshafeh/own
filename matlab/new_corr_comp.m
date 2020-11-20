clear ; clc ; addpath(genpath('/Users/heshamelshafei/GoogleDrive/PhD/Fieldtripping/fieldtrip-20151124/'));

load /Volumes/SHORT_LOUIE/pcc_data/wPCC.mat ;

for sb = 1:14
    
    zero_avg{sb,1} = source_avg{1}{1};
    zero_avg{sb,1}.pow(:) = 0;
end

clearvars -except source_avg zero_avg ;

for ngroup = 1:2
    for nfreq = 1:2
        
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
        
        nsuj                               =   size(source_avg{ngroup},1);
        
        cfg.design(1,:)                    =   [1:nsuj 1:nsuj];
        cfg.design(2,:)                    =   [ones(1,nsuj) ones(1,nsuj)*2];
        cfg.uvar                           =   1;
        cfg.ivar                           =   2;
        
        stat{ngroup,nfreq}                 =   ft_sourcestatistics(cfg, source_avg{ngroup}{:,1,nfreq,1,1},zero_avg{:,1});

        
    end
end

for ngroup = 1:2
    for nfreq = 1:2
        [min_p(ngroup,nfreq),p_val{ngroup,nfreq}] = h_pValSort(stat{ngroup,nfreq});
    end
end

p_limit = 0.05;

for ngroup = 1:2
    for nfreq = 1:2
        
        stoplot                     = stat{ngroup,nfreq};
        [t_min_p,t_p_val]               = h_pValSort(stoplot);
        
        if t_min_p < p_limit
            
            lst_side                = {'left','right','both'};
            lst_view                = [-95 1;95,11;0 50];
            
            z_lim                   = 5;
            
            clear source ;
            
            stoplot.mask           = stoplot.prob < p_limit;
            
            source.pos              = stoplot.pos ;
            source.dim              = stoplot.dim ;
            tpower                  = stoplot.stat .* stoplot.mask;
            tpower(tpower == 0)     = NaN;
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
            cfg.surffile            =   ['surface_white_' lst_side{3} '.mat'];
            cfg.surfinflated        =   ['surface_inflated_' lst_side{3} '_caret.mat'];
            
            ft_sourceplot(cfg, source);
            view(lst_view(3,:))
            

            
        end
    end
end
