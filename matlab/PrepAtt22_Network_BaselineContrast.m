clear ; clc ; addpath(genpath('../fieldtrip-20151124/')); clc ;

load ../data/template/template_grid_0.5cm.mat

for sb = 1:21
    
    suj         = ['yc' num2str(sb)] ;
    
    list_freq   = {'7t11Hz','11t15Hz','7t15Hz'};
    list_time   = {'m700m200','p600p1100'};
    list_mesure = {'plv','powcorr','coh'};
    
    for nfreq = 1:length(list_freq)
        for nmes = 1:length(list_mesure)
            
            list_cue    = {'RCnD','LCnD','NCnD'};
            
            for ncue = 1:length(list_cue)
                for ntime = 1:length(list_time)
                    
                    ext_essai   = '.100SlctMinEvoked0.5cm';
                    fname_in    = ['../data/pat22_data/' suj '.' list_cue{ncue} '.' list_time{ntime} '.' list_freq{nfreq} '.' list_mesure{nmes} 'Network' ext_essai '.mat'];
                    
                    fprintf('Loading %s\n',fname_in);
                    load(fname_in)
                    
                    source_gavg{sb,ncue,nfreq,nmes,ntime}.pow = network_full; %
                    source_gavg{sb,ncue,nfreq,nmes,ntime}.pos = template_grid.pos;
                    source_gavg{sb,ncue,nfreq,nmes,ntime}.dim = template_grid.dim;
                    
                    clear network_full
                    
                end
            end
        end
    end
end

clearvars -except source_gavg list_* *_list ;

for ncue = 1:size(source_gavg,2)
    for nfreq = 1:size(source_gavg,3)
        for nmes = 1:size(source_gavg,4)
            
            cfg                                =   [];
            cfg.dim                            =   source_gavg{1}.dim;
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
            
            nsuj                               =   size(source_gavg,1);
            
            cfg.design(1,:)                    =   [1:nsuj 1:nsuj];
            cfg.design(2,:)                    =   [ones(1,nsuj) ones(1,nsuj)*2];
            cfg.uvar                           =   1;
            cfg.ivar                           =   2;
            
            stat{ncue,nfreq,nmes}              =   ft_sourcestatistics(cfg, source_gavg{:,ncue,nfreq,nmes,2},source_gavg{:,ncue,nfreq,nmes,1});
            
        end
    end
end

clearvars -except source_gavg list_* stat

for ncue = 1:size(stat,1)
    for nfreq = 1:size(stat,2)
        for nmes = 1:size(stat,3)
            [min_p(ncue,nfreq,nmes),p_val{ncue,nfreq,nmes}]     = h_pValSort(stat{ncue,nfreq,nmes});
        end
    end
end

clearvars -except source_gavg list_* stat min_p p_val

p_limit     = 0.05;

for ncue = 1:size(stat,1)
    for nfreq = 1:size(stat,2)
        for nmes = 1:size(stat,3)
            
            for iside = 3
                
                if min_p(ncue,nfreq,nmes) < p_limit
                    
                    lst_side                = {'left','right','both'};
                    lst_view                = [-95 1;95 1;0 50];
                    
                    z_lim                   = 5;
                    
                    clear source ;
                    
                    stolplot                = stat{ncue,nfreq,nmes};
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
                    title([list_cue{ncue} '.' list_freq{nfreq} '.' list_mesure{nmes}]);
                    
                end
            end
        end
    end
end

% who_seg = {};
% i       = 0;
%
% for nfreq = 1:size(stat,1)
%     for nroi = 1:size(stat,2)
%         for ntest = 1:size(stat,3)
%             for nmes = 1:size(stat,4)
%
%                 if min_p(nfreq,nroi,ntest,nmes) < p_limit
%
%                     i = i + 1;
%
%                     who_seg{i,1} = FindSigClusters(stat{nfreq,nroi,ntest,nmes},p_limit);
%                     who_seg{i,2} = [list_freq{nfreq} '.' list_test{ntest} '.' list_roi{nroi} '.' list_mesure{nmes}];
%                     who_seg{i,3} = min_p(nfreq,nroi,ntest,nmes);
%                     who_seg{i,4} = FindSigClustersWithCoordinates(stat{nfreq,nroi,ntest,nmes},p_limit,'../data_fieldtrip/doc/FrontalCoordinates.csv',0.5);
%
%                 end
%
%             end
%         end
%     end
% end

clearvars -except source_gavg list_* stat min_p p_val list_test who_seg p_limit