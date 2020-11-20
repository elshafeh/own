clear ; clc ; addpath(genpath('../fieldtrip-20151124/')); close all ;

list_time   = {'fDIS.60t100Hz.p100p300','DIS.60t100Hz.p100p300'};
load ../data/template/template_grid_0.5cm.mat ;

for sb = 1:14
    
    suj_list = [1:4 8:17];
    
    suj                 = ['yc' num2str(suj_list(sb))];
    
    sourceAppend{1}     = [];
    sourceAppend{2}     = [];
    
    for prt = 1:3
        for ix = 1:2
            
            filt_ext    = 'dpssFixedCommonDicSourceMinEvoked0.5cm';
            
            fname       = ['../data/prep21_dis_data/' suj '.pt' num2str(prt) '.' list_time{ix} '.' filt_ext '.mat'];
            
            fprintf('Loading %50s\n',fname);
            
            load(fname);
            
            source_carr{ix} = source ;
            
            clear source ;
            
        end
        
        sourceAppend{1} = [sourceAppend{1} source_carr{2}-source_carr{1}];
        sourceAppend{2} = [sourceAppend{2} source_carr{2}];
        
        clear source_carr
        
    end
    
    where_vox                       = find(template_grid.inside==1);
    
    for nbsl = 1:2
        
        allsuj_avg{sb,nbsl}.pow     = mean(sourceAppend{nbsl},2);
        allsuj_avg{sb,nbsl}.pos     = template_grid.pos ;
        
        allsuj_avg{sb,nbsl}.pow     = allsuj_avg{sb,nbsl}.pow(where_vox,:);
        allsuj_avg{sb,nbsl}.pos     = allsuj_avg{sb,nbsl}.pos(where_vox,:) ;
        
        
        allsuj_avg{sb,nbsl}.dim     = template_grid.dim ;
        
    end
    
    fprintf('Calculating Correlation\n');
    
    [med_inf,~,~,~,~]               = h_prep21_behav_eval(suj,[1 2],0,1:4);
    [med_unf,~,~,~,~]               = h_prep21_behav_eval(suj,0,0,1:4);
    [med_d1,~,~,~,~]                = h_prep21_behav_eval(suj,0:2,1,1:4);
    [med_d3,~,~,~,~]                = h_prep21_behav_eval(suj,0:2,3,1:4);
    
    allsuj_behav{sb,1}              = med_unf - med_inf;
    allsuj_behav{sb,2}              = med_d3 - med_d1;
    
    
end

clearvars -except allsuj_*

for nbsl = 1:size(allsuj_avg,2)
    for ntest = 1:size(allsuj_behav,2)
        
        cfg                                 = [];
        cfg.method                          = 'montecarlo';
        cfg.statistic                       = 'ft_statfun_correlationT';
        
        cfg.correctm                        = 'cluster';
        cfg.clusterstatistics               = 'maxsum';
        
        cfg.clusteralpha                    = 0.05;
        cfg.tail                            = 0;
        cfg.clustertail                     = 0;
        cfg.alpha                           = 0.025;
        cfg.numrandomization                = 1000;
        cfg.ivar                            = 1;
        
        nsuj                                = size(allsuj_behav,1);
        cfg.design(1,1:nsuj)                = [allsuj_behav{:,ntest}];
        
        cfg.type                            = 'Pearson';
        
        stat{nbsl,ntest}                    = ft_sourcestatistics(cfg, allsuj_avg{:,nbsl});
        
    end
end

clearvars -except allsuj_* stat

for nbsl = 1:size(stat,1)
    for ntest = 1:size(stat,2)
        
        stat_to_plot                                = stat{nbsl,ntest};
        [min_p(nbsl,ntest),p_val{nbsl,ntest}]       = h_pValSort(stat_to_plot);
        
    end
end

clearvars -except allsuj_* stat min_p p_val

%% 

lst_side        = {'left','right','both'};
lst_view        = [-95 1;95 1;0 50];
lst_nbsl        = {'corrected','noncorrected'};
lst_test        = {'TDeffect','CaptEffect'};

for nbsl = 1:size(stat,1)
    for ntest = 1:size(stat,2)
        
        p_limit                                             = 0.2;
        z_lim                                               = 1;
        stat_to_plot                                        = stat{nbsl,ntest};
        
        [single_min_p,single_p_val]                         = h_pValSort(stat_to_plot);
        
        if single_min_p < p_limit
            
            for iside = [1 2]
                
                stat_to_plot.mask                           = stat_to_plot.prob < p_limit;
                
                load ../data/template/template_grid_0.5cm.mat ;
                
                where_vox                                   = find(template_grid.inside==1);
                
                source.pos                                  = template_grid.pos;
                source.dim                                  = template_grid.dim;
                source.pow                                  = nan(length(template_grid.pos),1);
                source.pow(where_vox)                       = stat_to_plot.mask .* stat_to_plot.stat;
                source.pow(source.pow == 0)                 = NaN;
                
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
                view(lst_view(iside,:));
                
                title([lst_nbsl{nbsl} ' ' lst_test{ntest} ' ' num2str(single_min_p)]);
                
                
            end
        end
    end
end