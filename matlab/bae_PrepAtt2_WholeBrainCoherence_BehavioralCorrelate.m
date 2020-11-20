clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/')); clc ;

load ../data_fieldtrip/template/template_grid_0.5cm.mat

for sb = 1:21
    
    suj                 = ['yc' num2str(sb)] ;
    
    list_freq           = {'7t11Hz'};
    list_time           = {'m600m200','p600p1000'};
    list_cue            = {'RCnD','LCnD','RNCnD','LNCnD','CnD'};
    list_roi            = {'audL','audR'};
    list_behav          = {'medRT','meanRT','perCorr'};
    list_corr           = {'Spearman'};
    
    list_ix_cue         = {2,1,0,0,0:2};
    list_ix_tar         = {[2 4],[1 3],[2 4],[1 3],1:4};
    list_ix_dis         = {0,0,0,0,0};
    
    for ncue = 1:length(list_cue)
        for nfreq = 1:length(list_freq)
            for nroi = 1:length(list_roi)
                for ntime = 1:length(list_time)
                    
                    fname_in = ['../data/' suj '/field/' suj '.' list_cue{ncue} '.' list_time{ntime} '.' list_freq{nfreq} '.OriginalPCC.0.5cm.'  ...
                        list_roi{nroi} '.plvConn.allYcLowAlphaIndex.mat'];
                    
                    fprintf('Loading %s\n',fname_in);
                    load(fname_in)
                    
                    tmp{ntime} = source;
                    
                    clear source
                    
                end
                
                source_gavg{sb,ncue,nfreq,nroi}.pow = (tmp{2}-tmp{1})./(tmp{1}); %tmp{2}-tmp{1}; %
                source_gavg{sb,ncue,nfreq,nroi}.pos = template_grid.pos;
                source_gavg{sb,ncue,nfreq,nroi}.dim = template_grid.dim;
                
                clear tmp
       
            end
        end
        
        [allsuj_behav{sb,ncue,1},allsuj_behav{sb,ncue,2},allsuj_behav{sb,ncue,3},~] =   h_behav_eval(suj,list_ix_cue{ncue},list_ix_dis{ncue},list_ix_tar{ncue}); clc ;
        
        clearvars -except list_* sb ncue suj template_grid allsuj_behav source_gavg
        
    end
end

clearvars -except allsuj_behav source_gavg list_*

for ncue = 1:size(source_gavg,2)
    for nfreq = 1:size(source_gavg,3)
        for nroi = 1:size(source_gavg,4)
            for nbehav = 1:size(allsuj_behav,3)
                for ncorr = 1:length(list_corr)
                    
                    
                    cfg                         = [];
                    cfg.parameter               = 'pow';
                    cfg.method                  = 'montecarlo';
                    cfg.statistic               = 'ft_statfun_correlationT';
                    cfg.correctm                = 'cluster';
                    cfg.clusteralpha            = 0.005;
                    cfg.clusterstatistics       = 'maxsum';
                    cfg.tail                    = 0;
                    cfg.clustertail             = 0;
                    cfg.alpha                   = 0.025;
                    cfg.numrandomization        = 1000;
                    cfg.ivar                    = 1;
                    cfg.computestat             = 'yes';
                    
                    cfg.type                                        = list_corr{ncorr};
                    cfg.design                                      = [allsuj_behav{:,ncue,nbehav}];
                    stat{ncue,nfreq,nroi,nbehav,ncorr}              = ft_sourcestatistics(cfg,source_gavg{:,ncue,nfreq,nroi});
                    
                    [min_p(ncue,nfreq,nroi,nbehav,ncorr),p_val{ncue,nfreq,nroi,nbehav,ncorr}]     = h_pValSort(stat{ncue,nfreq,nroi,nbehav,ncorr});
                    
                    
                    
                end
            end
        end
    end
end

clearvars -except allsuj_behav source_gavg list_* stat min_p p_val

p_limit = 0.11;
who_seg = {};
i       = 0;

for ncue = 1:size(stat,1)
    for nfreq = 1:size(stat,2)
        for nroi = 1:size(stat,3)
            for nbehav = 1:size(stat,4)
                for ncorr = 1:size(stat,5)
                    
                    if min_p(ncue,nfreq,nroi,nbehav,ncorr) < p_limit
                        
                        i = i + 1;
                        
                        who_seg{i,1} = [list_cue{ncue} '.' list_freq{nfreq} '.' list_roi{nroi} '.' list_behav{nbehav} '.' list_corr{ncorr}];
                        who_seg{i,2} = min_p(ncue,nfreq,nroi,nbehav,ncorr);
                        who_seg{i,3} = p_val{ncue,nfreq,nroi,nbehav,ncorr};
                        
                        
                        who_seg{i,4} = FindSigClusters(stat{ncue,nfreq,nroi,nbehav,ncorr},p_limit);
                        who_seg{i,5} = FindSigClustersWithCoordinates(stat{ncue,nfreq,nroi,nbehav,ncorr},p_limit,'../data_fieldtrip/doc/FrontalCoordinates.csv',0.5);
                        
                    end
                end
            end
        end
    end
end

clearvars -except allsuj_behav source_gavg list_* stat min_p p_val who_seg seg p_limit = 0.11;

for ncue = 1:size(stat,1)
    for nfreq = 1:size(stat,2)
        for nroi = 1:size(stat,3)
            for nbehav = 1%:size(stat,4)
                for ncorr = 1:size(stat,5)
                    
                    if min_p(ncue,nfreq,nroi,nbehav,ncorr) < p_limit
                        
                        for iside = 3
                            
                            
                            lst_side                = {'left','right','both'};
                            lst_view                = [-95 1;95,11;0 50];
                            
                            z_lim                   = 5;
                            
                            clear source ;
                            
                            stolplot                = stat{ncue,nfreq,nroi,nbehav,ncorr};
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
                            title([list_cue{ncue} '.' list_freq{nfreq} '.' list_roi{nroi} '.' list_behav{nbehav} '.' list_corr{ncorr}]);
                            
                        end
                    end
                end
            end
        end
    end
end
