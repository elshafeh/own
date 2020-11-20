clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/')); clc ;

load ../data_fieldtrip/template/template_grid_0.5cm.mat

for sb = 1:21
    
    suj         = ['yc' num2str(sb)] ;
    
    list_freq   = {'7t11Hz'};
    list_time   = {'m600m200','p600p1000'};
    list_roi    = {'OriginalPCC100SlctMinEvoked0.5cm.aud_L','OriginalPCC100SlctMinEvoked0.5cm.aud_R'};
    list_mesure = {'plvConn'};
    
    for nfreq = 1:length(list_freq)
        for nroi = 1:length(list_roi)
            for nmes = 1:length(list_mesure)
                
                list_cue    = {'RCnD','LCnD'};
                
                for ncue = 1:length(list_cue)
                    
                    for ntime = 1:length(list_time)
                        
                        fname_in = ['../data/' suj '/field/' suj '.' list_cue{ncue} '.' list_time{ntime} '.' list_freq{nfreq} '.' list_roi{nroi} '.' list_mesure{nmes} '.broadAreas.mat'];
                        
                        fprintf('Loading %s\n',fname_in);
                        load(fname_in)
                        
                        tmp{ntime} = source;
                        
                        clear source
                        
                    end
                    
                    source_gavg{sb,ncue,nfreq,nroi,nmes}.pow = (tmp{2}-tmp{1})./(tmp{1}); % 
                    source_gavg{sb,ncue,nfreq,nroi,nmes}.pos = template_grid.pos;
                    source_gavg{sb,ncue,nfreq,nroi,nmes}.dim = template_grid.dim;
                    
                    clear tmp
                    
                end
                
                list_to_subtract                = [1 2];
                index_cue                       = 2;
                
                for nadd = 1:size(list_to_subtract,1)
                    
                    source_gavg{sb,index_cue+nadd,nfreq,nroi,nmes}  = source_gavg{sb,list_to_subtract(nadd,1),nfreq,nroi,nmes} ;
                    
                    pow                                             = source_gavg{sb,list_to_subtract(nadd,1),nfreq,nroi,nmes}.pow - ...
                        source_gavg{sb,list_to_subtract(nadd,2),nfreq,nroi,nmes}.pow ;
                    
                    source_gavg{sb,index_cue+nadd,nfreq,nroi,nmes}.pow = pow; clear pow;
                    
                    list_cue{index_cue+nadd}                        = [list_cue{list_to_subtract(nadd,1)} 'm' list_cue{list_to_subtract(nadd,2)}];
                    
                end
                
            end
        end
    end
end

clearvars -except source_gavg list_* *_list ;

for sb = 1:size(source_gavg,1)
    for ncue = 1:size(source_gavg,2)
        for nfreq = 1:size(source_gavg,3)
            for nroi = 1:size(source_gavg,4)
                for nmes = 1:size(source_gavg,5)
                    
                    zero_avg{sb,ncue,nfreq,nroi,nmes}           = source_gavg{sb,ncue,nfreq,nroi,nmes};
                    zero_avg{sb,ncue,nfreq,nroi,nmes}.pow(:)    = 0;
                    
                end
            end
        end
    end
end

clearvars -except source_gavg list_* *_list zero_avg;

for ncue = 1:size(source_gavg,2)
    for nfreq = 1:size(source_gavg,3)
        for nroi = 1:size(source_gavg,4)
            for nmes = 1:size(source_gavg,5)
                
                cfg                                =   [];
                cfg.dim                            =   source_gavg{1}.dim;
                cfg.method                         =   'montecarlo';
                cfg.statistic                      =   'depsamplesT';
                cfg.parameter                      =   'pow';
                
                cfg.correctm                       =   'fdr';
                
                cfg.clusteralpha                   =   0.05;             % First Threshold
                
                cfg.clusterstatistic               =   'maxsum';
                cfg.numrandomization               =   1000;
                cfg.alpha                          =   0.025;
                cfg.tail                           =   0;
                cfg.clustertail                    =   0;
                
                nsuj                               =   size(source_gavg,1);
                
                cfg.design(1,:)                    =   [1:nsuj 1:nsuj];
                cfg.design(2,:)                    =   [ones(1,nsuj) ones(1,nsuj)*2];
                cfg.uvar                           =   1;
                cfg.ivar                           =   2;
                
                stat{nfreq,nroi,ncue,nmes}        =   ft_sourcestatistics(cfg, source_gavg{:,ncue,nfreq,nroi,nmes},zero_avg{:,ncue,nfreq,nroi,nmes});
                
            end
        end
    end
end

clearvars -except source_gavg list_* stat

for nfreq = 1:size(stat,1)
    for nroi = 1:size(stat,2)
        for ncue = 1:size(stat,3)
            for nmes = 1:size(stat,4)
                [min_p(nfreq,nroi,ncue,nmes),p_val{nfreq,nroi,ncue,nmes}]     = h_pValSort(stat{nfreq,nroi,ncue,nmes});
            end
        end
    end
end

clearvars -except source_gavg list_* stat min_p p_val

list_test   = {'R','L','RmL'};

p_limit = 0.05;

who_seg = {};
i       = 0;

% for nfreq = 1:size(stat,1)
%     for nroi = 1:size(stat,2)
%         for ncue = 1:size(stat,3)
%             for nmes = 1:size(stat,4)
%
%                 if min_p(nfreq,nroi,ncue,nmes) < p_limit
%
%                     i = i + 1;
%
%                     who_seg{i,1} = FindSigClusters(stat{nfreq,nroi,ncue,nmes},p_limit);
%                     who_seg{i,2} = [list_freq{nfreq} '.' list_test{ncue} '.' list_roi{nroi} '.' list_mesure{nmes}];
%                     who_seg{i,3} = min_p(nfreq,nroi,ncue,nmes);
%                     who_seg{i,4} = FindSigClustersWithCoordinates(stat{nfreq,nroi,ncue,nmes},p_limit,'../data_fieldtrip/doc/FrontalCoordinates.csv',0.5);
%
%                 end
%
%             end
%         end
%     end
% end

clearvars -except source_gavg list_* stat min_p p_val list_test who_seg p_limit

for nfreq = 1:size(stat,1)
    for nroi = 1:size(stat,2)
        for ncue = 1:size(stat,3)
            for nmes = 1:size(stat,4)
                
                for iside = 3
                    
                    if min_p(nfreq,nroi,ncue,nmes) < p_limit
                        
                        lst_side                = {'left','right','both'};
                        lst_view                = [-95 1;95,11;0 50];
                        
                        z_lim                   = 5;
                        
                        clear source ;
                        
                        stolplot                = stat{nfreq,nroi,ncue,nmes};
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
                        %                         cfg.projthresh          =   0.2;
                        cfg.projmethod          =   'nearest';
                        cfg.surffile            =   ['surface_white_' lst_side{iside} '.mat'];
                        cfg.surfinflated        =   ['surface_inflated_' lst_side{iside} '_caret.mat'];
                        
                        ft_sourceplot(cfg, source);
                        view(lst_view(iside,:))
                        title([list_freq{nfreq} '.' list_test{ncue} '.' list_roi{nroi} '.' list_mesure{nmes}]);
                        
                    end
                end
            end
        end
    end
end