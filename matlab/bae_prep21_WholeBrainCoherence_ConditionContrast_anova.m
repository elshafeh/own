clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/')); clc ;

load ../data_fieldtrip/template/template_grid_0.5cm.mat

suj_list                                = [1:4 8:17];

for sb = 1:length(suj_list)
    
    suj                                 = ['yc' num2str(suj_list(sb))] ;
    
    list_freq                           = {'7t11Hz','11t15Hz','7t15Hz'};
    list_time                           = {'.m600m200','.p600p1000'};
    list_roi                            = {'MinEvoked.aud_L','MinEvoked.aud_R'};
    list_mesure                         = {'plvConn','cohConn'};
    
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
            end
        end
    end
end

clearvars -except source_gavg list_* *_list ;

for nfreq = 1:length(list_freq)
    for nroi = 1:length(list_roi)
        for nmes = 1:length(list_mesure)
            
            cfg                                =   [];
            cfg.dim                            =   source_gavg{1}.dim;
            cfg.method                         =   'montecarlo';
            
            cfg.statistic                      =   'ft_statfun_depsamplesFunivariate';
            
            cfg.parameter                      =   'pow';
            cfg.correctm                       =   'cluster';
            
            cfg.clusteralpha                   =   0.05;             % First Threshold
            
            cfg.clusterstatistic               =   'maxsum';
            cfg.numrandomization               =   1000;
            cfg.alpha                          =   0.025;
            cfg.tail                           =   0;
            cfg.clustertail                    =   0;
            
            nsuj                               =   size(source_gavg,1);
            
            design=zeros(2,3*nsuj);
            for i=1:nsuj
                design(1,i)=i;
            end
            
            for i=1:nsuj
                design(1,nsuj+i)=i;
            end
            
            for i=1:nsuj
                design(1,nsuj*2+i)=i;
            end
            
            design(2,1:nsuj)=1;
            design(2,nsuj+1:2*nsuj)=2;
            design(2,nsuj*2+1:3*nsuj)=3;
            
            cfg.design                         =   design;
            cfg.uvar                           =   1;
            cfg.ivar                           =   2;
            cfg.clustercritval                 =   0.05;

            stat{nfreq,nroi,nmes}              =   ft_sourcestatistics(cfg, source_gavg{:,:,nfreq,nroi,nmes});
            
        end
    end
end

clearvars -except source_gavg list_* stat

% save('../data_fieldtrip/stat/WholeBrainCoherence_relBaseline.mat','stat');

for nfreq = 1:size(stat,1)
    for nroi = 1:size(stat,2)
        for nmes = 1:size(stat,3)
            [min_p(nfreq,nroi,nmes),p_val{nfreq,nroi,nmes}]     = h_pValSort(stat{nfreq,nroi,nmes});
        end
    end
end

clearvars -except source_gavg list_* stat min_p p_val

p_limit     = 0.11;

who_seg = {};
i       = 0;

for nfreq = 1:size(stat,1)
    for nroi = 1:size(stat,2)
        for nmes = 1:size(stat,3)
            
            if min_p(nfreq,nroi,nmes) < p_limit
                
                i = i + 1;
                
                who_seg{i,1} = FindSigClusters(stat{nfreq,nroi,nmes},p_limit);
                who_seg{i,2} = [list_freq{nfreq} '.' list_roi{nroi} '.' list_mesure{nmes}];
                who_seg{i,3} = min_p(nfreq,nroi,nmes);
                who_seg{i,4} = FindSigClustersWithCoordinates(stat{nfreq,nroi,nmes},p_limit,'../data_fieldtrip/doc/FrontalCoordinates.csv',0.5);
                
            end
            
        end
    end
end


clearvars -except source_gavg list_* stat min_p p_val list_test who_seg p_limit

for nfreq = 1:size(stat,1)
    for nroi = 1:size(stat,2)
        for nmes = 1:size(stat,3)
            for iside = [1 2]
                
                if min_p(nfreq,nroi,nmes) < p_limit
                    
                    lst_side                = {'left','right','both'};
                    lst_view                = [-95 1;95 1;0 50];
                    
                    z_lim                   = 1;
                    
                    clear source ;
                    
                    stolplot                = stat{nfreq,nroi,nmes};
                    stolplot.mask           = stolplot.prob < p_limit;
                    
                    source.pos              = stolplot.pos ;
                    source.dim              = stolplot.dim ;
                    tpower                  = stolplot.stat .* stolplot.mask;
                    tpower(tpower == 0)     = NaN;
                    source.pow              = tpower ; clear tpower;
                    
                    cfg                     =   [];
                    cfg.method              =   'surface';
                    cfg.funparameter        =   'pow';
                    cfg.funcolorlim         =   [0 z_lim];
                    cfg.opacitylim          =   [0 z_lim];
                    cfg.opacitymap          =   'rampup';cfg.colorbar            =   'off';cfg.camlight            =   'no';cfg.projmethod          =   'nearest';
                    cfg.surffile            =   ['surface_white_' lst_side{iside} '.mat'];
                    cfg.surfinflated        =   ['surface_inflated_' lst_side{iside} '_caret.mat'];
                    
                    ft_sourceplot(cfg, source);
                    view(lst_view(iside,:))
                    title([list_freq{nfreq} '.' list_roi{nroi} '.' list_mesure{nmes} ' ' num2str(min_p(nfreq,nroi,nmes))]);
                    
                end
            end
        end
    end
end
