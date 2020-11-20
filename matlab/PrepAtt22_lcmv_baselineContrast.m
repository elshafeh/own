clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,suj_group{1},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_group{1}        = suj_group{1}(2:22);

load ../data_fieldtrip/template/template_grid_0.5cm.mat

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj                     = suj_list{sb};
        cond_main               = '';
        
        list_filter             = {''};
        
        %         list_time               = {'p35p70ms','p80p150ms','p150p200ms','p250p500ms'};
        %         ext_bsl                 = {'m85m50ms','m120m50ms','m100m50ms','m300m50ms'};
        
        list_time               = {'DIS.largeWindowFilter.p80p150ms','DIS.largeWindowFilter.p210p290ms','DIS.largeWindowFilter.p290p370ms','DIS.largeWindowFilter.p390p470ms'};
        list_bsl                = {'fDIS.largeWindowFilter.p80p150ms','fDIS.largeWindowFilter.p210p290ms','fDIS.largeWindowFilter.p290p370ms','fDIS.largeWindowFilter.p390p470ms'};
        
        
        for nfilt = 1:length(list_filter)
            for ntime = 1:length(list_time)
                
                ex_s  = '.lcmvSource5%.mat';
                
                fname = ['../data/' suj '/field/' suj '.' cond_main list_filter{nfilt} list_time{ntime} ex_s];
                
                fprintf('Loading %50s\n',fname);
                load(fname);
                
                source_avg{ngroup}{sb,nfilt,ntime,1}.pow            = source;
                source_avg{ngroup}{sb,nfilt,ntime,1}.pos            = template_grid.pos ;
                source_avg{ngroup}{sb,nfilt,ntime,1}.dim            = template_grid.dim ;
                
                fname = ['../data/' suj '/field/' suj '.' cond_main list_filter{nfilt} list_bsl{ntime} ex_s];
                
                fprintf('Loading %50s\n',fname);
                load(fname);
                
                source_avg{ngroup}{sb,nfilt,ntime,2}.pow            = source;
                source_avg{ngroup}{sb,nfilt,ntime,2}.pos            = template_grid.pos ;
                source_avg{ngroup}{sb,nfilt,ntime,2}.dim            = template_grid.dim ;
                
            end
        end
    end
end

clearvars -except source_avg list_*

for ngroup = 1:length(source_avg)
    for nfilt = 1:size(source_avg{ngroup},2)
        for ntime = 1:size(source_avg{ngroup},3)
            
            cfg                                 =   [];
            cfg.dim                             =   source_avg{1}{1}.dim;
            cfg.method                          =   'montecarlo';
            cfg.statistic                       =   'depsamplesT';
            cfg.parameter                       =   'pow';
            cfg.correctm                        =   'cluster';
                        
            cfg.clusterstatistic                =   'maxsum';
            cfg.numrandomization                =   1000;
            cfg.alpha                           =   0.01;
            cfg.tail                            =   0;
            cfg.clustertail                     =   0;
            
            nsuj                                =   length([source_avg{ngroup}{:,nfilt,ntime,2}]);
            cfg.design(1,:)                     =   [1:nsuj 1:nsuj];
            cfg.design(2,:)                     =   [ones(1,nsuj) ones(1,nsuj)*2];
            
            cfg.uvar                            =   1;
            cfg.ivar                            =   2;
            
            clusterp_list                       = [0.001 0.0005] ; % [0.05 0.01 0.005 0.001 0.0005];
            list_p_names                        = {'0point001','0point0005'}; % {'0point05','0point01','0point005','0point001','0point0005'};
            
            for xi = 1:length(clusterp_list)
                cfg.clusteralpha                =   clusterp_list(xi);          % First Threshold
                stat{ngroup,nfilt,ntime,xi}     =   ft_sourcestatistics(cfg, source_avg{ngroup}{:,nfilt,ntime,1},source_avg{ngroup}{:,nfilt,ntime,2});
            end
            
        end
    end
end

% for ngroup = 1:size(stat,1)
%     for nfilt = 1:size(stat,2)
%         for ntime = 1:size(stat,3)
%             [min_p(ngroup,nfilt,ntime),p_val{ngroup,nfilt,ntime}]     = h_pValSort(stat{ngroup,nfilt,ntime});
%         end
%     end
% end

for ngroup = 1:size(stat,1)
    for nfilt = 1:size(stat,2)
        for ntime = 1:size(stat,3)
            for xi = 1:size(stat,4)
                for iside = [1 2]
                    
                    lst_side                                    = {'left','right','both'};
                    lst_view                                    = [-95 1;95 1;0 50];
                    
                    z_lim                                       = 5; % change limit of graph
                    
                    clear source ;
                    
                    stolplot                                    = stat{ngroup,nfilt,ntime,xi};
                    
                    [new_min_p,new_p_val]                       = h_pValSort(stolplot);
                    
                    stolplot.mask                               = stolplot.prob < 0.05;
                    
                    source.pos                                  = stolplot.pos ;
                    source.dim                                  = stolplot.dim ;
                    tpower                                      = stolplot.stat .* stolplot.mask;
                    
                    tpower(tpower == 0)                         = NaN;
                    source.pow                                  = tpower ; clear tpower;
                    
                    cfg                                         =   [];
                    cfg.method                                  =   'surface';
                    cfg.funparameter                            =   'pow';
                    cfg.funcolorlim                             =   [-z_lim z_lim];
                    cfg.opacitylim                              =   [-z_lim z_lim];
                    cfg.opacitymap                              =   'rampup';
                    cfg.colorbar                                =   'off';
                    cfg.camlight                                =   'no';
                    cfg.projmethod                              =   'nearest';
                    cfg.surffile                                =   ['surface_white_' lst_side{iside} '.mat'];
                    cfg.surfinflated                            =   ['surface_inflated_' lst_side{iside} '_caret.mat'];
                    ft_sourceplot(cfg, source);
                    view(lst_view(iside,:))
                    
                    title([list_filter{nfilt} ' ' list_time{ntime} ' ' list_p_names{xi} ' ' num2str(new_min_p)])
                    
                    saveas(gcf,['/home/hesham.elshafei/Images/dis/' list_time{ntime} '.' list_p_names{xi} '.side' num2str(iside) '.png']);
                    
                    close all;
                    
                end
            end
        end
    end
end