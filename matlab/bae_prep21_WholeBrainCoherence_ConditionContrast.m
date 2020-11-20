clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/')); clc ;

load ../data_fieldtrip/template/template_grid_0.5cm.mat

suj_list                                = [1:4 8:17];

for sb = 1:length(suj_list)
    
    suj                                 = ['yc' num2str(suj_list(sb))] ;
    
    list_freq                           = {'7t11Hz','11t15Hz','7t15Hz'};
    list_time                           = {'.m600m200','.p600p1000'};
    list_roi                            = {'MinEvoked.aud_L','MinEvoked.aud_R'};
    list_mesure                         = {'plvConn','cohConn'};
    z
    for nfreq = 1:length(list_freq)
        for nroi = 1:length(list_roi)
            for nmes = 1:length(list_mesure)
                
                list_cue    = {'RCnD','LCnD','NCnD'};
                
                for ncue = 1:length(list_cue)
                    
                    for ntime = 1:length(list_time)
                        
                        source_part         = [];
                        
                        for npart = 1:3
                            
                            fname_in = ['../../PAT_MEG21/pat.field/data/' suj '.pt' num2str(npart) '.' list_cue{ncue} list_time{ntime} '.' list_freq{nfreq} '.' list_roi{nroi} '.' list_mesure{nmes} '.paper_data.mat'];
                            
                            fprintf('Loading %s\n',fname_in);
                            load(fname_in)
                            
                            source_part      = [source_part source];
                            
                            tmp{ntime}       = mean(source_part,2);
                            
                        end
                    end
                    
                    source_gavg{sb,ncue,nfreq,nroi,nmes}.pow = (tmp{2}-tmp{1})./(tmp{1}); %
                    source_gavg{sb,ncue,nfreq,nroi,nmes}.pos = template_grid.pos;
                    source_gavg{sb,ncue,nfreq,nroi,nmes}.dim = template_grid.dim;
                    
                    clear tmp
                    
                end
                
                list_to_subtract                = [1 3; 2 3];
                index_cue                       = 3;
                
                for nadd = 1:length(list_to_subtract)
                    
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

for nfreq = 1:length(list_freq)
    for nroi = 1:length(list_roi)
        for nmes = 1:length(list_mesure)
            
            ix_test                                =   [1 2; 1 3; 2 3; 4 5];
            
            for ntest = 1:size(ix_test,1)
                
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
                
                stat{nfreq,nroi,ntest,nmes}        =   ft_sourcestatistics(cfg, source_gavg{:,ix_test(ntest,1),nfreq,nroi,nmes},source_gavg{:,ix_test(ntest,2),nfreq,nroi,nmes});
                
            end
        end
    end
end

clearvars -except source_gavg list_* stat

% save('../data_fieldtrip/stat/WholeBrainCoherence_relBaseline.mat','stat');

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

p_limit     = 0.1;

list_test   = {'RvL','RvN','LvN','RmLm'};

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
                for iside = [1 2]
                    
                    if min_p(nfreq,nroi,ntest,nmes) < p_limit
                        
                        lst_side                = {'left','right','both'};
                        lst_view                = [-95 1;95 1;0 50];
                        
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
                        cfg.opacitymap          =   'rampup';cfg.colorbar            =   'off';cfg.camlight            =   'no';cfg.projmethod          =   'nearest';
                        cfg.surffile            =   ['surface_white_' lst_side{iside} '.mat'];
                        cfg.surfinflated        =   ['surface_inflated_' lst_side{iside} '_caret.mat'];
                        
                        ft_sourceplot(cfg, source);
                        view(lst_view(iside,:))
                        title([list_freq{nfreq} '.' list_test{ntest} '.' list_roi{nroi} '.' list_mesure{nmes} ' ' num2str(min_p(nfreq,nroi,ntest,nmes))]);
                        
                        saveas(gcf,['../images/paper_connectivity/' list_freq{nfreq} '.' list_test{ntest} '.' list_roi{nroi} '.' list_mesure{nmes} '.' lst_side{iside} '.png']); close all ;
                        
                    end
                end
            end
        end
    end
end