clear ; clc ; addpath(genpath('../../fieldtrip-20151124/'));

[~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');
suj_group{1}    = allsuj(2:15,1);
suj_group{2}    = allsuj(2:15,2);

lst_group       = {'old','young'};

load ../data_fieldtrip/template/template_grid_0.5cm.mat

for ngroup = 1:length(suj_group)
    
    suj_list    = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj         = suj_list{sb} ;
        
        list_freq   = {'60t100Hz'};
        list_time   = {'.fDIS.p100p300','.DIS.p100p300'};
        list_roi    = {'MinEvoked.audLR'};
        list_mesure = {'plvConn.dpssNewFiltNewBroadAreas','plvConn.hanningNewFiltNewBroadAreas'};
        list_cue    = {''};
        
        for nfreq = 1:length(list_freq)
            for nroi = 1:length(list_roi)
                for nmes = 1:length(list_mesure)
                                        
                    for ncue = 1:length(list_cue)
                        
                        for ntime = 1:length(list_time)
                            
                            fname_in = ['../data/' suj '/field/' suj  list_cue{ncue} list_time{ntime} '.' list_freq{nfreq} '.' list_roi{nroi} '.' list_mesure{nmes} '.mat'];
                            
                            fprintf('Loading %s\n',fname_in);
                            load(fname_in)
                            
                            source_Ztransform   = 0.5 .* (log((1+source)./(1-source)));
                            tmp{ntime}          = source_Ztransform;
                            
                            clear source
                            
                        end
                        
                        act                                                 = tmp{2} ; % tmp{2}-tmp{1}; % (tmp{2}-tmp{1})./(tmp{1}); % 
                        act(isnan(act))                                     = 0;
                        
                        source_gavg{ngroup}{sb,ncue,nfreq,nroi,nmes}.pow    = act;
                        
                        source_gavg{ngroup}{sb,ncue,nfreq,nroi,nmes}.pos    = template_grid.pos;
                        source_gavg{ngroup}{sb,ncue,nfreq,nroi,nmes}.dim    = template_grid.dim;
                        
                        clear tmp
                        
                    end
                end
            end
        end
    end
end

clearvars -except source_gavg list_* *_list ;

for ncue = 1:length(list_cue)
    for nfreq = 1:length(list_freq)
        for nroi = 1:length(list_roi)
            for nmes = 1:length(list_mesure)
                
                cfg                                 =   [];
                cfg.dim                             =  source_gavg{1}{1}.dim;
                cfg.method                          =  'montecarlo';
                cfg.statistic                      = 'indepsamplesT';
                cfg.parameter                       = 'pow';
                cfg.correctm                        = 'cluster';
                cfg.clusteralpha                    = 0.05;             % First Threshold
                cfg.clusterstatistic                = 'maxsum';
                cfg.numrandomization                = 1000;
                cfg.alpha                           = 0.025;
                cfg.tail                            = 0;
                cfg.clustertail                     = 0;
                
                nsuj                                = length([source_gavg{1}]);
                cfg.design                          = [ones(1,nsuj) ones(1,nsuj)*2];
                cfg.ivar                            = 1;
                
                stat{ncue,nfreq,nroi,nmes}          = ft_sourcestatistics(cfg, source_gavg{2}{:,ncue,nfreq,nroi,nmes},source_gavg{1}{:,ncue,nfreq,nroi,nmes});
                
            end
        end
    end
end

clearvars -except source_gavg list_* *_list stat;

p_limit = 0.05;

i = 0 ; clear who_seg ,

for ncue = 1:length(list_cue)
    for nfreq = 1:length(list_freq)
        for nroi = 1:length(list_roi)
            for nmes = 1:length(list_mesure)
                
                stoplot             = stat{ncue,nfreq,nroi,nmes};
                [min_p,p_val]       = h_pValSort(stoplot);
                
                if min_p < p_limit
                    
                    i = i + 1;
                    
                    who_seg{i,1} = [list_cue{ncue} ' ' list_freq{nfreq} '' list_roi{nroi} ' ' list_mesure{nmes}];
                    who_seg{i,2} = min_p;
                    who_seg{i,3} = p_val;
                    
                    who_seg{i,4} = FindSigClusters(stoplot,p_limit);
                    who_seg{i,5} = FindSigClustersWithCoordinates(stoplot,p_limit,'../data_fieldtrip/doc/FrontalCoordinates.csv',0.5);
                    
                end
            end
        end
    end
end

clearvars -except source_gavg list_* *_list stat who_seg p_limit;

for ncue = 1:length(list_cue)
    for nfreq = 1:length(list_freq)
        for nroi = 1:length(list_roi)
            for nmes = 1:length(list_mesure)
                
                stoplot             = stat{ncue,nfreq,nroi,nmes};
                [min_p,p_val]       = h_pValSort(stoplot);
                
                if min_p < p_limit
                    
                    for iside = [1 2]
                        
                        lst_side                = {'left','right','both'};
                        lst_view                = [-95 1;95 1;0 50];
                        
                        z_lim                   = 5;
                        
                        clear source ;
                        
                        stoplot.mask            = stoplot.prob < p_limit;
                        
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
                        cfg.surffile            =   ['surface_white_' lst_side{iside} '.mat'];
                        cfg.surfinflated        =   ['surface_inflated_' lst_side{iside} '_caret.mat'];
                        
                        ft_sourceplot(cfg, source);
                        view(lst_view(iside,:))
                        
                        title([list_cue{ncue} ' ' list_freq{nfreq} '' list_roi{nroi} ' ' list_mesure{nmes} ' p=' num2str(min_p)])
                        
                    end                 
                end
            end
        end
    end
end