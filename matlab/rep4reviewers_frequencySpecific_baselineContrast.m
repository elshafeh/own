clear ; clc ; addpath(genpath('../fieldtrip-20151124/')); close all;

[~,suj_group{1},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_group{1}        = suj_group{1}(2:22);

load ../data/template/template_grid_0.5cm.mat

for ngroup = 1:length(suj_group)
    
    suj_list        = suj_group{ngroup};
    
    list_freq       = {'1.3t7Hz','1.7t13Hz','1.20t30Hz','1.60t100Hz'};
    list_time       = {'p0p400','p300p600','p300p500','p100p300'};
    
    ext_comp        = 'dpssFixedCommonDicSourceMinEvoked0.5cm.mat'; % for paper
    
    for sb = 1:length(suj_list)
        
        suj                 = suj_list{sb};
        
        for nfreq = 1:length(list_freq)
            
            cond_main   = 'fDIS';
            
            %for paper
            dir_data    = '../data/dis_rep4rev/';
            fname       = [dir_data suj '.' cond_main list_freq{nfreq} '.' list_time{nfreq} '.' ext_comp];
            
            
            fprintf('Loading %50s\n',fname);
            load(fname);
            
            source_avg{ngroup}{sb,nfreq,1}.pow            = source;
            source_avg{ngroup}{sb,nfreq,1}.pos            = template_grid.pos ;
            source_avg{ngroup}{sb,nfreq,1}.dim            = template_grid.dim ;
            
            clear source
            
            cond_main   = 'DIS';
            fname       = [dir_data suj '.' cond_main list_freq{nfreq} '.' list_time{nfreq} '.' ext_comp];
            fprintf('Loading %50s\n',fname);
            load(fname);
            
            source_avg{ngroup}{sb,nfreq,2}.pow            = source;
            source_avg{ngroup}{sb,nfreq,2}.pos            = template_grid.pos ;
            source_avg{ngroup}{sb,nfreq,2}.dim            = template_grid.dim ;
            
            clear source
            
        end
    end
end

clearvars -except source_avg list*

for ngroup = 1:length(source_avg)
    for nfreq = 1:size(source_avg{ngroup},2)
        
        cfg                                 =   [];
        cfg.dim                             =   source_avg{1}{1}.dim;
        cfg.method                          =   'montecarlo';
        cfg.statistic                       =   'depsamplesT';
        cfg.parameter                       =   'pow';
        cfg.correctm                        =   'cluster';
        
        list_lusteralpha                    =   [0.0001 0.001 0.0001 0.005];
        
        cfg.clusteralpha                    =   list_lusteralpha(nfreq);  %% First Threshold (paper = 0.001)
        
        cfg.clusterstatistic                =   'maxsum';
        cfg.numrandomization                =   1000;
        cfg.alpha                           =   0.025;
        cfg.tail                            =   0;
        cfg.clustertail                     =   0;
        nsuj                                =   length([source_avg{ngroup}{:,nfreq,2}]);
        cfg.design(1,:)                     =   [1:nsuj 1:nsuj];
        cfg.design(2,:)                     =   [ones(1,nsuj) ones(1,nsuj)*2];
        cfg.uvar                            =   1;
        cfg.ivar                            =   2;
        stat{ngroup,nfreq}                    =   ft_sourcestatistics(cfg, source_avg{ngroup}{:,nfreq,2},source_avg{ngroup}{:,nfreq,1});
        stat{ngroup,nfreq}                    =   rmfield(stat{ngroup,nfreq},'cfg');
        
    end
end

clearvars -except stat list*

for ngroup = 1:size(stat,1)
    for nfreq = 1:size(stat,2)
        [min_p(ngroup,nfreq),p_val{ngroup,nfreq}]     = h_pValSort(stat{ngroup,nfreq});
    end
end

clearvars -except stat source_avg min_p p_val list*; close all ;

p_limit = 0.05;
who_seg = {};
i       = 0 ; 

for ngroup = 1:size(stat,1)
    for nfreq = 1:size(stat,2)
        
        i = i + 1;
        
        who_seg{i,1} = list_freq{nfreq};
        who_seg{i,2} = min_p(ngroup,nfreq);
        who_seg{i,3} = p_val{ngroup,nfreq};
        
        who_seg{i,4} = FindSigClusters(stat{ngroup,nfreq},p_limit);
        
    end
end


for ngroup = 1:size(stat,1)
    for nfreq = 1:size(stat,2)
        for iside = [1 2]
            
            lst_side                                    =   {'left','right','both'};
            lst_view                                    =   [-95 1;95 1;0 50];
            
            z_lim                                       =   6;
            
            clear source ;
            
            stat{ngroup,nfreq}.mask                     =   stat{ngroup,nfreq}.prob < p_limit;
            
            source.pos                                  =   stat{ngroup,nfreq}.pos ;
            source.dim                                  =   stat{ngroup,nfreq}.dim ;
            tpower                                      =   stat{ngroup,nfreq}.stat .* stat{ngroup,nfreq}.mask;
            
            tpower(tpower==0)                           =   NaN;
            source.pow                                  =   tpower ; clear tpower;
            
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
            
            title(list_freq{nfreq})
            
            dir_out = '~/GoogleDrive/NeuroProj/Publications/Papers/distractor2018/cerebcortex2018/_rep_for_reviews/freqSpecific/';
            saveas(gcf,[dir_out 'freqSpec.BaselineContrast' list_freq{nfreq} '.' lst_side{iside} list_time{nfreq} '.png']);
            close all;
            
        end
    end
end