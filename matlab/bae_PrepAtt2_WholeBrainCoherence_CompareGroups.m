clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/')); clc ;

load ../data_fieldtrip/template/template_grid_0.5cm.mat
[~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');

suj_group{1}    = allsuj(2:15,1);
suj_group{2}    = allsuj(2:15,2);

for ngrp = 1:length(suj_group)
    
    suj_list = suj_group{ngrp};
    
    for sb = 1:length(suj_list)
        
        suj         =  suj_list{sb};
        
        list_freq   = {'7t11Hz','11t15Hz'};
        list_time   = {'m600m200','p600p1000'};
        list_cue    = {'RCnD','RNCnD','LCnD','LNCnD','CnD'};
        list_roi    = {'OriginalPCC.AgeContrast80Slct.0.5cm.audR','OriginalPCC.AgeContrast80Slct.0.5cm.audL'};
        list_mesure = {'cohConn','plvConn'};
        
        for ncue = 1:length(list_cue)
            for nfreq = 1:length(list_freq)
                for nroi = 1:length(list_roi)
                    for nmes = 1:length(list_mesure)
                        for ntime = 1:length(list_time)
                            
                            fname_in = ['../data/' suj '/field/' suj '.' list_cue{ncue} '.' list_time{ntime} '.' list_freq{nfreq} '.' list_roi{nroi} '.' list_mesure{nmes} '.AllSepThenAvg.mat'];
                            
                            fprintf('Loading %s\n',fname_in);
                            load(fname_in)
                            
                            tmp{ntime} = source;
                            
                            clear source
                            
                        end
                        
                        pow                                            = (tmp{2}-tmp{1})./(tmp{1}); %tmp{2}-tmp{1};
                        pow(isnan(pow))                                = 0;
                        source_gavg{ngrp}{sb,ncue,nfreq,nroi,nmes}.pow = pow; clear pow ;
                        source_gavg{ngrp}{sb,ncue,nfreq,nroi,nmes}.pos = template_grid.pos;
                        source_gavg{ngrp}{sb,ncue,nfreq,nroi,nmes}.dim = template_grid.dim;
                        
                        clear tmp
                        
                    end
                end
            end
        end
        
        for nfreq = 1:length(list_freq)
            for nroi = 1:length(list_roi)
                for nmes = 1:length(list_mesure)
                    
                    source_gavg{ngrp}{sb,6,nfreq,nroi,nmes}     = source_gavg{ngrp}{sb,1,nfreq,nroi,nmes};
                    source_gavg{ngrp}{sb,6,nfreq,nroi,nmes}.pow = source_gavg{ngrp}{sb,1,nfreq,nroi,nmes}.pow - source_gavg{ngrp}{sb,2,nfreq,nroi,nmes}.pow;
                    
                    source_gavg{ngrp}{sb,7,nfreq,nroi,nmes}     = source_gavg{ngrp}{sb,3,nfreq,nroi,nmes};
                    source_gavg{ngrp}{sb,7,nfreq,nroi,nmes}.pow = source_gavg{ngrp}{sb,3,nfreq,nroi,nmes}.pow - source_gavg{ngrp}{sb,4,nfreq,nroi,nmes}.pow;
                    
                    source_gavg{ngrp}{sb,8,nfreq,nroi,nmes}     = source_gavg{ngrp}{sb,1,nfreq,nroi,nmes};
                    source_gavg{ngrp}{sb,8,nfreq,nroi,nmes}.pow = source_gavg{ngrp}{sb,1,nfreq,nroi,nmes}.pow - source_gavg{ngrp}{sb,3,nfreq,nroi,nmes}.pow;

                end
            end
        end
        
    end
end

clearvars -except source_gavg list_* *_list ;

for nfreq = 1:length(list_freq)
    for nroi = 1:length(list_roi)
        for nmes = 1:length(list_mesure)
            for ntest = 1:size(source_gavg{1},2)
                
                cfg                     =   [];
                cfg.dim                 =  source_gavg{1}{1}.dim;
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
                
                nsuj                    = length([source_gavg{1}]);
                
                cfg.design              = [ones(1,nsuj) ones(1,nsuj)*2];
                cfg.ivar                = 1;
                
                stat{nfreq,nroi,ntest,nmes}        =   ft_sourcestatistics(cfg, source_gavg{2}{:,ntest,nfreq,nroi,nmes},source_gavg{1}{:,ntest,nfreq,nroi,nmes});
                stat{nfreq,nroi,ntest,nmes}        =   rmfield(stat{nfreq,nroi,ntest,nmes},'cfg');
                
            end
        end
    end
end

clearvars -except source_gavg list_* stat

for nfreq = 1:size(stat,1)
    for nroi = 1:size(stat,2)
        for ntest = 1:size(stat,3)
            for nmes = 1:size(stat,4)
                [min_p(nfreq,nroi,ntest,nmes),p_val{nfreq,nroi,ntest,nmes}]     = h_pValSort(stat{nfreq,nroi,ntest,nmes});
            end
        end
    end
end

clearvars -except source_gavg list_* stat min_p p_val

list_test   = {'RCnD','RNCnD','LCnD','LNCnD','CnD','RvNR','LvNL','RvL'};

p_limit = 0.11;

who_seg = {};
i       = 0;

for nfreq = 1:size(stat,1)
    for nroi = 1:size(stat,2)
        for ntest = 1:size(stat,3)
            for nmes = 1:size(stat,4)
                
                if min_p(nfreq,nroi,ntest,nmes) < p_limit
                    
                    i = i + 1;
                    
                    who_seg{i,1} = FindSigClusters(stat{nfreq,nroi,ntest,nmes},p_limit);
                    who_seg{i,2} = [list_freq{nfreq} '.' list_test{ntest} '.' list_roi{nroi} '.' list_mesure{nmes}];
                    who_seg{i,3} = min_p(nfreq,nroi,ntest,nmes);
                    who_seg{i,4} = FindSigClustersWithCoordinates(stat{nfreq,nroi,ntest,nmes},p_limit,'../data_fieldtrip/doc/FrontalCoordinates.csv',0.5);
                    
                end
                
            end
        end
    end
end

clearvars -except source_gavg list_* stat min_p p_val list_test who_seg p_limit

for nfreq = 1:size(stat,1)
    for nroi = 1:size(stat,2)
        for ntest = 1:size(stat,3)
            for nmes = 1:size(stat,4)
                
                for iside = 3
                    
                    if min_p(nfreq,nroi,ntest,nmes) < p_limit
                        
                        lst_side                = {'left','right','both'};
                        lst_view                = [-95 1;95,11;0 50];
                        
                        z_lim                   = 5;
                        
                        clear source ;
                        
                        stolplot                = stat{nfreq,nroi,ntest,nmes};
                        stolplot.mask           = stolplot.prob < p_limit;
                        
                        source.pos              = stolplot.pos ;
                        source.dim              = stolplot.dim ;
                        tpower                  = stolplot.stat .* stolplot.mask;
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
                        cfg.surffile            =   ['surface_white_' lst_side{iside} '.mat'];
                        cfg.surfinflated        =   ['surface_inflated_' lst_side{iside} '_caret.mat'];
                        
                        ft_sourceplot(cfg, source);
                        view(lst_view(iside,:))
                        title([list_freq{nfreq} '.' list_test{ntest} '.' list_roi{nroi} '.' list_mesure{nmes}]);
                        
                    end
                end
            end
        end
    end
end