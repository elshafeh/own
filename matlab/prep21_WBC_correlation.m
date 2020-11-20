clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

% [~,suj_group{1},~]      = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
% suj_group{1}            = suj_group{1}(2:22);

suj_group{1}    ={'yc1','yc2','yc3','yc4','yc8','yc9','yc10','yc11','yc12','yc13','yc14','yc15','yc16','yc17'};

load ../data/template/template_grid_0.5cm.mat ;

for ngroup = 1:length(suj_group)
    
    suj_list            = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj             = suj_list{sb};
        
        cond_main       = {''};
        
        list_freq       = {'.7t11Hz.MinEvoked.aud_R','.11t15Hz.MinEvoked.aud_R','.7t15Hz.MinEvoked.aud_R', ...
            '.7t11Hz.MinEvoked.aud_L','.11t15Hz.MinEvoked.aud_L','.7t15Hz.MinEvoked.aud_L'};
        
        list_time       = {'.m600m200','.p600p1000'};
        
        ext_sorce       = '.plvConn.paper_data.mat';
        
        for ncue = 1:length(cond_main)
            for nfreq = 1:length(list_freq)
                for ntime = 1:length(list_time)
                    
                    source_part = [];
                    
                    for npart = 1:3
                        
                        dir_data    = '../data/paper_data/';
                        ext_compund = [ list_time{ntime} list_freq{nfreq} ext_sorce];
                        fname       = [dir_data suj '.pt' num2str(npart) '.CnD'  cond_main{ncue}  ext_compund];
                        fprintf('Loading %50s\n',fname);
                        load(fname);
                        
                        source_part                            = [source_part source]; clear source ;
                        
                    end
                    
                    source_time{ntime}                         = mean(source_part,2);
                    source_time{ntime}                         = 0.5 .* (log((1+source_time{ntime})./(1-source_time{ntime})));
                    
                    clear source_part
                    
                end
                
                bsl_source                                      = source_time{1};
                act_source                                      = source_time{2}; clear source_time ;
                
                pow                                             = act_source-bsl_source; %(act_source-bsl_source)./bsl_source;%;
                
                allsuj_avg{sb,ncue,nfreq}.pow                   = pow ;
                allsuj_avg{sb,ncue,nfreq}.pos                   = template_grid.pos ;
                allsuj_avg{sb,ncue,nfreq}.dim                   = template_grid.dim ;
                allsuj_avg{sb,ncue,nfreq}.inside                = template_grid.inside;
                
                clear act_source bsl_source pow
                
            end
        end
        
        load ../data/yctot/rt/rt_CnD_adapt.mat
        load(['../data/paper_data/' suj '.CnD.trialinfo.mat']);
        
        data_fake.trialinfo                                     = trial_info;
        
        ix_inf                                                  = h_chooseTrial(data_fake,[1 2],0,1:4);
        ix_unf                                                  = h_chooseTrial(data_fake,0,0,1:4);
        
        suj_rt                                                  = rt_all{sb};
        suj_inf                                                 = suj_rt(ix_inf);
        suj_unf                                                 = suj_rt(ix_unf);
        
        allsuj_behav{sb,1}                                      = median(suj_rt);
        allsuj_behav{sb,2}                                      = median(suj_unf) - median(suj_inf) ;
        
        clear ix_inf ix_unf suj_rt suj_unf
        
    end
end

clearvars -except allsuj_* list_* suj_group template_* suj_list ngroup stat

for cnd = 1:size(allsuj_avg,2)
    for nfreq  = 1:size(allsuj_avg,3)
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
            
            cfg.type                            = 'Spearman';
            
            stat{ngroup,cnd,nfreq,ntest}        = ft_sourcestatistics(cfg, allsuj_avg{:,cnd,nfreq});
            
        end
    end
end

clearvars -except suj_group stat template_* ngroup list_*

for ngroup = 1:size(stat,1)
    for cnd = 1:size(stat,2)
        for nfreq  = 1:size(stat,3)
            for ntest = 1:size(stat,4)
                
                stat_to_plot                                                        = stat{ngroup,cnd,nfreq,ntest};
                [min_p(ngroup,cnd,nfreq,ntest),p_val{ngroup,cnd,nfreq,ntest}]       = h_pValSort(stat_to_plot);
                
            end
        end
    end
end

clearvars -except sb allsuj_* stat min_p p_val list_*

p_limit             = 0.1; close all ;
list_test           = {'medianRT','medianTD'};

for ngroup = 1:size(stat,1)
    for cnd = 1:size(stat,2)
        for nfreq  = 1:size(stat,3)
            for ntest = 1:size(stat,4)
                
                s2plot                              = stat{ngroup,cnd,nfreq,ntest};
                [single_min_p,single_p_val]         = h_pValSort(s2plot);
                
                if single_min_p < p_limit
                    
                    for iside = [1 2]
                        
                        
                        lst_side                      = {'left','right','both'};
                        lst_view                      = [-95 1;95 7;0 50];
                        
                        z_lim                         = 5; clear source ;
                        
                        s2plot.mask                   = s2plot.prob < p_limit;
                        
                        source.pos                    = s2plot.pos ;
                        source.dim                    = s2plot.dim ;
                        tpower                        = s2plot.stat .* s2plot.mask;
                        tpower(tpower == 0)           = NaN;
                        source.pow                    = tpower ; clear tpower;
                        
                        
                        cfg                           =   [];
                        cfg.method                    =   'surface';
                        cfg.funparameter              =   'pow';
                        cfg.funcolorlim               =   [-z_lim z_lim];
                        cfg.opacitylim                =   [-z_lim z_lim];
                        cfg.opacitymap                =   'rampup';
                        cfg.colorbar                  =   'off';
                        cfg.camlight                  =   'no';
                        %                         cfg.projthresh                =   0.2;
                        cfg.projmethod                =   'nearest';
                        cfg.surffile                  =   ['surface_white_' lst_side{iside} '.mat'];
                        cfg.surfinflated              =   ['surface_inflated_' lst_side{iside} '_caret.mat'];
                        
                        ft_sourceplot(cfg, source);
                        view(lst_view(iside,:));
                        
                        %                             list_group                    = {'allyoung'} ; % {'old','young','common'};
                        %                             list_cue                      = {'DIS aud LR '}; % plv'};
                        
                        title([list_freq{nfreq} ' ' list_test{ntest} ' ' num2str(single_min_p)]);
                        
                    end
                end
            end
        end
    end
end


i = 0 ;

% clear who_seg
%
% for cnd = 1:size(stat,1)
%     for ntime = 1:size(stat,2)
%         for nfreq  =1:size(stat,3)
%             for ntest = 1:size(stat,4)
%
%                 if min_p(cnd,ntime,nfreq,ntest) < p_limit
%
%                     tmp_stat = stat{cnd,ntime,nfreq,ntest};
%
%                     i = i + 1;
%
%
%                     who_seg{i,1} = [list_time{ntime} '.' list_freq{nfreq} '.' list_test{ntest}];
%                     who_seg{i,2} = min_p(cnd,ntime,nfreq,ntest);
%                     who_seg{i,3} = p_val{cnd,ntime,nfreq,ntest};
%
%                     who_seg{i,4} = FindSigClusters(tmp_stat,p_limit);
%                     who_seg{i,5} = FindSigClustersWithCoordinates(tmp_stat,p_limit,'../data_fieldtrip/doc/FrontalCoordinates.csv',0.5);
%
%
%                 end
%             end
%         end
%     end
% end
%
% load ../data_fieldtrip/stat/allyc_dis_dis1_dis3_spearman_correlation.mat
% list_test           = {'capture median','capture mean','tdown median','tdown mean','arousal median','arousal mean'};
% list_test           = {'capture_pre','capture_post','tdown_pre','tdown_post','arousal_pre','arousal_post'};