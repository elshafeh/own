clear ; clc ;

load ../data_fieldtrip/stat/dics_old_young_allTrials_lowhigh_early_late.mat

for a = 1:size(stat,1)
    for b = 1:size(stat,2)
        for c = 1:size(stat,3)
            for d = 1:size(stat,4)
                
                big_stat{a,b,c,d,1} = stat{a,b,c,d};
                
            end
        end
    end
end

clear stat ;

load ../data_fieldtrip/stat/dics_old_young_80slct_lowhigh_early_late.mat

for a = 1:size(stat,1)
    for b = 1:size(stat,2)
        for c = 1:size(stat,3)
            for d = 1:size(stat,4)
                
                big_stat{a,b,c,d,2} = stat{a,b,c,d};
                
            end
        end
    end
end

stat = big_stat ; clearvars -except stat ;

lst_freq    = {'7t11Hz','11t15Hz'};
lst_time    = {'p200p600','p600p1000'};
lst_meth    = {'AllTrials','80Slct'};
lst_test    = {'RCnDvNRCnD','LCnDvNLCnD','RCnDvLCnD','RCnDvNCnD','LCnDvNCnD'};
lst_group   = {'Old','young'};

who_seg     = {};
i           = 0;

for nfreq = 1:size(stat,2)
    for ntime = 1:size(stat,3)
        for ntest = 1:size(stat,4)
            for ngroup = 1:size(stat,1)
                for nmeth = 1:size(stat,5)
                    
                    stoplot            = stat{ngroup,nfreq,ntime,ntest,nmeth};
                    
                    [min_p,p_val]      = h_pValSort(stoplot);
                    
                    p_limit            = 0.11;
                    
                    if min_p < p_limit
                        
                        i            = i + 1;
                        
                        who_seg{i,1} = [lst_freq{nfreq} '.' lst_time{ntime} '.'  lst_test{ntest} '.' lst_group{ngroup} '.' lst_meth{nmeth}];
                        who_seg{i,2} = min_p;
                        who_seg{i,3} = p_val;
                        
                        who_seg{i,4} = FindSigClusters(stoplot,p_limit);
                        who_seg{i,5} = FindSigClustersWithCoordinates(stoplot,p_limit,'../data_fieldtrip/doc/FrontalCoordinates.csv',0.5);
                        
                        
                    end
                    
                end
            end
        end
    end
end

clearvars -except stat who_seg lst_*;

% for nfreq = 1:size(stat,2)
%     for ntime = 1:size(stat,3)
%         for ntest = 1:size(stat,4)
%             for ngroup = 1:size(stat,1)
%                 for nmeth = 1:size(stat,5)
%
%                     stoplot            = stat{ngroup,nfreq,ntime,ntest,nmeth};
%
%                     [min_p,p_val]      = h_pValSort(stoplot);
%
%                     p_limit            = 0.11;
%
%                     if min_p < p_limit
%
%                         for iside = 3
%
%
%                             lst_side                = {'left','right','both'};
%                             lst_view                = [-95 1;95,11;0 50];
%
%                             z_lim                   = 5;
%
%                             clear source ;
%
%                             stoplot.mask            = stoplot.prob < p_limit;
%
%                             source.pos              = stoplot.pos ;
%                             source.dim              = stoplot.dim ;
%                             tpower                  = stoplot.stat .* stoplot.mask;
%                             tpower(tpower == 0)     = NaN;
%                             source.pow              = tpower ; clear tpower;
%
%                             cfg                     =   [];
%                             cfg.funcolormap         = 'jet';
%                             cfg.method              =   'surface';
%                             cfg.funparameter        =   'pow';
%                             cfg.funcolorlim         =   [-z_lim z_lim];
%                             cfg.opacitylim          =   [-z_lim z_lim];
%                             cfg.opacitymap          =   'rampup';
%                             cfg.colorbar            =   'off';
%                             cfg.camlight            =   'no';
%                             cfg.projthresh          =   0.2;
%                             cfg.projmethod          =   'nearest';
%                             cfg.surffile            =   ['surface_white_' lst_side{iside} '.mat'];
%                             cfg.surfinflated        =   ['surface_inflated_' lst_side{iside} '_caret.mat'];
%
%                             ft_sourceplot(cfg, source);
%                             view(lst_view(iside,:))
%
%                             title([lst_freq{nfreq} '.' lst_time{ntime} '.'  lst_test{ntest} '.' lst_group{ngroup} '.' lst_meth{nmeth}])
%
%                         end
%                     end
%                 end
%             end
%         end
%     end
% end