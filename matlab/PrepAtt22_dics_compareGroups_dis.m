clear ; clc ; addpath(genpath('../fieldtrip-20151124/')); close all;

[~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');

suj_group{1}    = allsuj(2:15,1);
suj_group{2}    = allsuj(2:15,2);

load ../data/template/template_grid_0.5cm.mat

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        cond_main           = {''};
        
        for cnd_cue = 1:length(cond_main)
            
            suj             = suj_list{sb};
            
            list_freq       = {'.60t100Hz'}; %,'1.60t100Hz','2.60t100Hz'};
            list_time       = {'p100p300'};
            
            for ntime = 1:length(list_time)
                for nfreq = 1:length(list_freq)
                    
                    ext_name    = '.dpssFixedCommonDicSourceMinEvoked0.5cm.mat';
                    dir_data    = '../data/ageing_data/';
                    
                    fname       = [dir_data  suj '.' cond_main{cnd_cue} 'fDIS' list_freq{nfreq} '.' list_time{ntime} ext_name];
                    fprintf('Loading %50s\n',fname);
                    load(fname);
                    
                    bsl_source            = source; clear source
                    
                    fname       = [dir_data  suj '.' cond_main{cnd_cue} 'DIS' list_freq{nfreq} '.' list_time{ntime} ext_name];
                    fprintf('Loading %50s\n',fname);
                    load(fname);
                    
                    act_source            = source; clear source
                    
                    pow                                                       = act_source-bsl_source ;
                    pow(isnan(pow))                                           = 0;
                    
                    source_avg{ngroup}{sb,cnd_cue,ntime,nfreq}.pow            = pow;
                    source_avg{ngroup}{sb,cnd_cue,ntime,nfreq}.pos            = template_grid.pos ;
                    source_avg{ngroup}{sb,cnd_cue,ntime,nfreq}.dim            = template_grid.dim ;
                    source_avg{ngroup}{sb,cnd_cue,ntime,nfreq}.inside         = template_grid.inside;
                    
                    clear act_source bsl_source pow
                    
                end
            end
        end
    end
end

clearvars -except source_avg list_*

for ncue = 1:size(source_avg{1},2)
    for ntime = 1:length(list_time)
        for nfreq = 1:length(list_freq)
            
            cfg                                                 =   [];
            cfg.dim                                             =  source_avg{1}{1}.dim;
            cfg.method                                          =  'montecarlo';
            cfg.statistic                                       = 'indepsamplesT';
            cfg.parameter                                       = 'pow';
            cfg.correctm                                        = 'cluster';
            cfg.clusteralpha                                    = 0.025;             % First Threshold
            cfg.clusterstatistic                                = 'maxsum';
            cfg.numrandomization                                = 1000;
            cfg.alpha                                           = 0.025;
            cfg.tail                                            = 0;
            cfg.clustertail                                     = 0;
            
            nsuj                                                = length([source_avg{1}{:,ncue}]);
            cfg.design                                          = [ones(1,nsuj) ones(1,nsuj)*2];
            cfg.ivar                                            = 1;
            
            stat{ncue,ntime,nfreq}                              = ft_sourcestatistics(cfg, source_avg{2}{:,ncue,ntime,nfreq},source_avg{1}{:,ncue,ntime,nfreq});
            [min_p(ncue,ntime,nfreq),p_val{ncue,ntime,nfreq}]   = h_pValSort(stat{ncue,ntime,nfreq});
            
            clear cfg
            
        end
    end
end

clearvars -except source_avg stat min_p p_val list_*

% z_lim       = 6;
p_limit     = 0.05;

i = 0 ;

clear who_seg

for ncue = 1:size(stat,1)
    for ntime = 1:size(stat,2)
        for nfreq = 1:size(stat,3)
            
            
            if min_p(ncue,ntime,nfreq) < p_limit
                i = i + 1;
                
                who_seg{i,1} = [list_time{ntime} '.' list_freq{nfreq}];
                who_seg{i,2} = min_p(ncue,ntime,nfreq);
                who_seg{i,3} = p_val{ncue,ntime,nfreq};
                
                who_seg{i,4} = FindSigClusters(stat{ncue,ntime,nfreq},p_limit);
                who_seg{i,5} = FindSigClustersWithCoordinates(stat{ncue,ntime,nfreq},p_limit,'../documents/FrontalCoordinates.csv',0.5);
                
                
            end
        end
    end
end

for ncue = 1:size(stat,1)
    for ntime = 1:size(stat,2)
        for nfreq = 1:size(stat,3)
            
            if min_p(ncue,ntime,nfreq) < p_limit
                for iside = [1 2]
                    
                    lst_side                      = {'left','right','both'};
                    %                     lst_view                      = [-128 11;128 11;0 50];
                    lst_view                      = [-95 1;95 1;0 50];
                    
                    z_lim                         = 3; clear source ;
                    
                    s2plot                        = stat{ncue,ntime,nfreq};
                    
                    s2plot.mask                   = s2plot.prob < p_limit;
                    
                    
                    source                        = [];
                    source.pos                    = s2plot.pos ;
                    source.dim                    = s2plot.dim ;
                    tpower                        = s2plot.stat .* s2plot.mask;
                    
                    tpower(tpower==0)             = NaN;
                    
                    source.pow                    = tpower ; clear tpower;
                    
                    cfg                           =   [];
                    cfg.method                    =   'surface';
                    cfg.funparameter              =   'pow';
                    cfg.maskparameter             = cfg.funparameter;
                    cfg.funcolorlim               =   [-z_lim z_lim];
                    cfg.opacitylim                =   [-z_lim z_lim];
                    cfg.opacitymap                =   'rampup';
                    cfg.colorbar                  =   'off';
                    cfg.camlight                  =   'no';
                    cfg.projmethod                =   'nearest';
                    cfg.surffile                  =   ['surface_white_' lst_side{iside} '.mat'];
                    cfg.surfinflated              =   ['surface_inflated_' lst_side{iside} '_caret.mat'];
                    
                    ft_sourceplot(cfg, source);
                    view(lst_view(iside,:));
                    title(list_freq{nfreq});
                    
                    %                     saveas(gcf,['/Users/heshamelshafei/GoogleDrive/PhD/Presentations/updated_ageing/dis.compare.group.DIS' list_freq{nfreq} '.side' num2str(iside) '.png'])
                    %                     close all;
                    
                end
            end
        end
    end
end