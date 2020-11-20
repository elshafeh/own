clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

load ../data/template/template_grid_0.5cm.mat

suj_list        = [1:4 8:17];

for sb = 1:length(suj_list)
    
    suj         = ['yc' num2str(suj_list(sb))] ;
    
    list_freq   = {'7t11Hz','11t15Hz','7t15Hz'};
    list_time   = {'.m600m200','.p600p1000'};
    list_roi    = {'MinEvoked.occ_LR'};
    list_mesure = {'plvConn'};
    list_cue    = {'VCnD','NCnD','CnD'};
    
    for ncue = 1:length(list_cue)
        for nfreq = 1:length(list_freq)
            for nroi = 1:length(list_roi)
                for nmes = 1:length(list_mesure)
                    for ntime = 1:length(list_time)
                        
                        tmp       = [];
                        
                        for npart = 1:3
                            
                            dir_data = '../data/paper_data/';
                            ext_sou  = '.paper.data.dpss.ZBefore.mat';
                            
                            fname_in = [dir_data suj '.pt' num2str(npart) '.' list_cue{ncue} list_time{ntime}  ...
                                '.' list_freq{nfreq} '.' list_roi{nroi} '.' list_mesure{nmes} ext_sou];
                            
                            fprintf('Loading %s\n',fname_in);
                            
                            load(fname_in)
                            
                            %                             source_ztransform                           = .5.*log((1+source)./(1-source)); clear source ;
                            %                             tmp                                         = [tmp source_ztransform];
                            
                            tmp       = [tmp source]; clear source
                            
                        end
                        
                        source_gavg{sb,ncue,nfreq,nroi,nmes,ntime}.pow  = mean(tmp,2);
                        source_gavg{sb,ncue,nfreq,nroi,nmes,ntime}.pos  = template_grid.pos;
                        source_gavg{sb,ncue,nfreq,nroi,nmes,ntime}.dim  = template_grid.dim;
                        
                        clear  source tmp
                        
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
                
                cfg.clusteralpha                    =   0.05;             % First Threshold
                
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
                
                stat{ncue,nfreq,nroi,nmes}          =   ft_sourcestatistics(cfg, source_gavg{:,ncue,nfreq,nroi,nmes,2},source_gavg{:,ncue,nfreq,nroi,nmes,1});
                
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

p_limit = 0.1;

for ncue = 1:length(list_cue)
    for nfreq = 1:length(list_freq)
        for nroi = 1:length(list_roi)
            for nmes = 1:length(list_mesure)
                if min_p(ncue,nfreq,nroi,nmes) < p_limit
                    
                    for iside = [1 2]
                        
                        lst_side                = {'left','right','both'};
                        lst_view                = [-95 1;95 1;0 50];
                        
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
                        cfg.funcolormap         = 'jet';
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
                        title([list_cue{ncue} '.' list_freq{nfreq} '.' list_roi{nroi} '.' list_mesure{nmes} ' ' num2str(min_p(ncue,nfreq,nroi,nmes))]);
                        
                        fname_out               = '/Users/heshamelshafei/GoogleDrive/PhD/Fieldtripping/images/prep21_visConn/';
                        
                        fname_out               = [fname_out list_cue{ncue} '.' list_freq{nfreq} '.' list_roi{nroi} '.' list_mesure{nmes}];
                        
                        fname_out               = [fname_out '.side' num2str(iside) '.png'];
                        
                        saveas(gcf,fname_out); close all ;
                        
                    end
                end
            end
        end
    end
end

i = 0 ; clear new_reg_list ;

% for ncue = 1:length(list_cue)
%     for nfreq = 1:length(list_freq)
%         for nroi = 1:length(list_roi)
%             for nmes = 1:length(list_mesure)
%                 if min_p(ncue,nfreq,nroi,nmes) < p_limit
%
%                     i = i + 1;
%
%                     stolplot          = stat{ncue,nfreq,nroi,nmes};
%
%                     %                     new_reg_list{i,1} = FindSigClustersWithCoordinates(stolplot,p_limit,'../data_fieldtrip/doc/FrontalCoordinates.csv',0.5);
%                     new_reg_list{i,1} = [list_cue{ncue} '.' list_freq{nfreq} '.' list_roi{nroi} '.' list_mesure{nmes}];
%                     new_reg_list{i,2} = min_p(ncue,nfreq,nroi,nmes);
%                     new_reg_list{i,3} = FindSigClusters(stolplot,p_limit);
%
%                 end
%             end
%         end
%     end
% end

clearvars -except source_gavg list_* stat min_p p_val new_reg_list p_limit