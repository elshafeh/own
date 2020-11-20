clear; clc; close all;
h_start('/Users/heshamelshafei/Dropbox/ade_training/fieldtrip-20190127/');

suj_list    = [1:4 8:17];
list_time   = {'m600m200','p600p1000'};
targ_band   = {'2t6Hz','20t30Hz','60t100Hz'};
ext_source  = 'wConcatm600m200p600p1200PCCSource.dpss.0.5cm.mat';

for nsub = 1:length(suj_list)
    
    suj                 = ['yc' num2str(suj_list(nsub))];
    fname_in            = ['../data/virtual/' suj '.CnD.MaxAudVizMotor.BigCov.VirtTimeCourse.KeepTrial.wav.1t20Hz.m3000p3000..mat'];
    
    load(fname_in);
    
    freq                = rmfield(freq,'hidden_trialinfo');
    iaf_matrix          = h_calculateIAF(freq);
    ntest               = 0;
    
    for ntarg = 1:length(targ_band)
        
        targ_source     = [];
        
        for npart = 1:3
            for ntime = 1:2
                
                fname   = ['../data/source/' suj '.pt' num2str(npart) '.CnD.'  targ_band{ntarg} '.' list_time{ntime}  '.' ext_source];
                fprintf('Loading %s\n',fname);
                load(fname)
                
                source_time{ntime}   = source; clear source;
                
            end
            
            source_corrected    = (source_time{2}-source_time{1})./source_time{1};
            targ_source         = [targ_source;source_corrected']; clear source_corrected;
            
        end
        
        chan_name                                 = {'index IAF'};
        
        for nchan = 1:size(iaf_matrix,2)
            
            ntest                                 = ntest +1;
            
            name_test{ntest,1}                    = [chan_name{nchan} ' with ' targ_band{ntarg}];
            
            fprintf('Calculating Correlations %s for %s\n',name_test{ntest},suj);
            load ../data/template_grid_0.5cm.mat;
            
            [rho,p]                               = corr(targ_source,iaf_matrix(:,nchan), 'type', 'Spearman');
            rho(isnan(rho))                       = 0;
            rhoF                                  = 0.5 .* (log((1+rho)./(1-rho)));
            
            
            all_source{nsub,ntest,1}.pow          = rhoF;
            all_source{nsub,ntest,1}.pos          = template_grid.pos;
            all_source{nsub,ntest,1}.dim          = template_grid.dim;
            
            all_source{nsub,ntest,2}              = all_source{nsub,ntest,1};
            all_source{nsub,ntest,2}.pow(:)       = 0;
            
            clear rhoF
            
        end
    end
    
    clearvars -except suj_list nsub all_source name_test ext_source targ_band list_time
    
end

clearvars -except all_source name_test

for ntest = 1:size(all_source,2)
    
    cfg                        =   [];
    cfg.dim                    =   all_source{1,1}.dim;
    cfg.method                 =   'montecarlo';
    cfg.statistic              =   'depsamplesT';
    cfg.parameter              =   'pow';
    cfg.correctm               =   'cluster';
    cfg.clusteralpha           =   0.01;             % First Threshold
    cfg.clusterstatistic       =   'maxsum';
    cfg.numrandomization       =   1000;
    cfg.alpha                  =   0.025;
    cfg.tail                   =   0;
    cfg.clustertail            =   0;
    cfg.design(1,:)            =   [1:14 1:14];
    cfg.design(2,:)            =   [ones(1,14) ones(1,14)*2];
    cfg.uvar                   =   1; 
    cfg.ivar                   =   2;
    
    stat{ntest}                =   ft_sourcestatistics(cfg,all_source{:,ntest,1},all_source{:,ntest,2});
    
end

clearvars -except all_source name_test stat

for nstat = 1:length(stat)
    
    [min_p(nstat),p_val{nstat}]         = h_pValSort(stat{nstat});
    p_limit                             = 0.05;
    
    name_test{nstat,2}                  = min_p(nstat);
    
    if min_p(nstat) < p_limit
        
        for iside = [1 2]
            
            lst_side                    = {'left','right','both'};
            lst_view                    = [-95 1;95,11;0 50];
            
            z_lim                       = 5;
            
            clear source ;
            
            stat_to_plot                = stat{nstat};
            stat_to_plot.mask           = stat_to_plot.prob < 0.05;
            
            source.pos                  = stat_to_plot.pos ;
            source.dim                  = stat_to_plot.dim ;
            tpower                      = stat_to_plot.stat .* stat_to_plot.mask;
            
            tpower(tpower == 0)         = NaN;
            source.pow                  = tpower ; clear tpower;
            
            cfg                         =   [];
            cfg.method                  =   'surface';
            cfg.funparameter            =   'pow';
            cfg.funcolorlim             =   [-z_lim z_lim];
            cfg.opacitylim              =   [-z_lim z_lim];
            cfg.opacitymap              =   'rampup';
            cfg.colorbar                =   'off';
            cfg.camlight                =   'no';
            cfg.projmethod              =   'nearest';
            cfg.surffile                =   ['surface_white_' lst_side{iside} '.mat'];
            cfg.surfinflated            =   ['surface_inflated_' lst_side{iside} '_caret.mat'];
            ft_sourceplot(cfg, source);
            view(lst_view(iside,:))
            
            title(name_test{nstat});
            
        end
    end
end