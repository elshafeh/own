clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

load ../data/template/template_grid_0.5cm.mat

for sb = 1:21
    
    suj         = ['yc' num2str(sb)] ;
    
    list_freq   = {'.60t100Hz'};
    list_time   = {'fDIS.p100p300','DIS.p100p300'};
    list_roi    = {'.MinEvoked.audLR'};
    list_mesure = {'.plvConn.dpssZBeforeNewFiltNewBroadAreas'};
    list_cue    = {''};

    for ncue = 1:length(list_cue)
        for nfreq = 1:length(list_freq)
            for nroi = 1:length(list_roi)
                for nmes = 1:length(list_mesure)
                    for ntime = 1:length(list_time)
                        
                        % for paper
                        fname_in                                        = ['../data/dis_conn_data/' suj '.' list_cue{ncue} list_time{ntime} list_freq{nfreq} list_roi{nroi} list_mesure{nmes} '.mat'];
                        
                        fprintf('Loading %s\n',fname_in);
                        load(fname_in)
                        
                        source_ztransform                               = source ; % .5.*log((1+source)./(1-source)); clear source ;
                        
                        source_gavg{sb,ncue,nfreq,nroi,nmes,ntime}.pow  = source_ztransform;
                        source_gavg{sb,ncue,nfreq,nroi,nmes,ntime}.pos  = template_grid.pos;
                        source_gavg{sb,ncue,nfreq,nroi,nmes,ntime}.dim  = template_grid.dim;
                        
                        clear  source
                        
                    end
                end
            end
        end
    end
end

clearvars -except source_gavg list_* *_list

for ncue = 1:length(list_cue)
    for nfreq = 1:length(list_freq)
        for nroi = 1:length(list_roi)
            for nmes = 1:length(list_mesure)
                
                cfg                                 =   [];
                cfg.dim                             =   source_gavg{1}.dim;
                cfg.method                          =   'montecarlo';
                cfg.statistic                       =   'depsamplesT';
                cfg.parameter                       =   'pow';
                
                cfg.correctm                        =   'cluster';
                
                cfg.clusteralpha                    =   0.005;             % First Threshold
                
                cfg.clusterstatistic                =   'maxsum';
                cfg.numrandomization                =   1000;
                cfg.alpha                           =   0.025;
                cfg.tail                            =   0;
                cfg.clustertail                     =   0;
                
                nsuj                                =   size(source_gavg,1);
                 
                cfg.design(1,:)                     =   [1:nsuj 1:nsuj];
                cfg.design(2,:)                     =   [ones(1,nsuj) ones(1,nsuj)*2];
                cfg.uvar                            =   1;
                cfg.ivar                            =   2;
                
                stat{ncue,nfreq,nroi,nmes} =   ft_sourcestatistics(cfg, source_gavg{:,ncue,nfreq,nroi,nmes,2},source_gavg{:,ncue,nfreq,nroi,nmes,1});
                
            end
        end
    end
end

clearvars -except source_gavg list_* stat 

for ncue = 1:length(list_cue)
    for nfreq = 1:length(list_freq)
        for nroi = 1:length(list_roi)
            for nmes = 1:length(list_mesure)
                
                [min_p(ncue,nfreq,nroi,nmes),p_val{ncue,nfreq,nroi,nmes}]     = h_pValSort(stat{ncue,nfreq,nroi,nmes});
                
            end
        end
    end
end

clearvars -except source_gavg list_* stat min_p p_val

p_limit = 0.05;

i = 0 ; clear new_reg_list ;

for ncue = 1:length(list_cue)
    for nfreq = 1:length(list_freq)
        for nroi = 1:length(list_roi)
            for nmes = 1:length(list_mesure)
                if min_p(ncue,nfreq,nroi,nmes) < p_limit
                    
                    i = i + 1;
                    
                    stolplot          = stat{ncue,nfreq,nroi,nmes};
                    
                    new_reg_list{i,1} = FindSigClustersWithCoordinates(stolplot,p_limit,'../documents/FrontalCoordinates.csv',0.5);
                    new_reg_list{i,2} = [list_cue{ncue} '.' list_freq{nfreq} '.' list_roi{nroi} '.' list_mesure{nmes}];
                    new_reg_list{i,3} = min_p(ncue,nfreq,nroi,nmes);
                    new_reg_list{i,4} = FindSigClusters(stolplot,p_limit);
                    
                end
            end
        end
    end
end

clearvars -except source_gavg list_* stat min_p p_val new_reg_list p_limit

for ncue = 1:length(list_cue)
    for nfreq = 1:length(list_freq)
        for nroi = 1:length(list_roi)
            for nmes = 1:length(list_mesure)
                
                if min_p(ncue,nfreq,nroi,nmes) < p_limit
                    
                    for iside = [1 2]
                        
                        lst_side                = {'left','right','both'};
                        lst_view                = [-95 1;95,11;0 50];
                        
                        z_lim                   = 5;
                        
                        clear source ;
                        
                        stolplot                = stat{ncue,nfreq,nroi,nmes};
                        stolplot.mask           = stolplot.prob < p_limit;
                        
                        source.pos              = stolplot.pos ;
                        source.dim              = stolplot.dim ;
                        tpower                  = stolplot.stat .* stolplot.mask;
                        tpower(tpower == 0)     = NaN;
                        source.pow              = tpower ; clear tpower;
                        
                        cfg                     =   [];
                        cfg.method              =   'surface';
                        cfg.funparameter        =   'pow';
                        cfg.funcolorlim         =   [-z_lim z_lim];
                        cfg.opacitylim          =   [-z_lim z_lim];
                        cfg.opacitymap          =   'rampup';
                        cfg.colorbar            =   'off';
                        cfg.camlight            =   'no';
                        cfg.projmethod          =   'nearest';
                        cfg.surffile            =   ['surface_white_' lst_side{iside} '.mat'];
                        cfg.surfinflated        =   ['surface_inflated_' lst_side{iside} '_caret.mat'];
                        
                        ft_sourceplot(cfg, source);
                        view(lst_view(iside,:))
                        
                    end
                end
            end
        end
    end
end