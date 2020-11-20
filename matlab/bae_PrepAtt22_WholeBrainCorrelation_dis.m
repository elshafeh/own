% clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,allsuj,~]            = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');
suj_group{1}            = allsuj(2:15,1);
suj_group{2}            = allsuj(2:15,2);
suj_group{3}            = [suj_group{2};suj_group{1}];

[~,suj_group{4},~]      = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_group{4}            = suj_group{4}(2:22);

load ../data_fieldtrip/template/template_grid_0.5cm.mat

for ngroup = 1:length(suj_group)
    
    suj_list            = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj             = suj_list{sb};
        
        cond_main       = {''};
        
        list_time       = {'60t100Hz'};
        list_freq       = {'.p100p300'};
        
        ext_sorce       = '.dpssFixedCommonDicSourceMinEvoked0.5cm.mat';
        
        for cnd_cue = 1:length(cond_main)
            
            for ntime = 1:length(list_time)
                for nfreq = 1:length(list_freq)
                    
                    fname = ['../data/' suj '/field/' suj '.' cond_main{cnd_cue} 'fDIS1.' list_time{ntime} list_freq{nfreq} ext_sorce];
                    fprintf('Loading %50s\n',fname);
                    load(fname);
                    
                    bsl_source            = source; clear source
                    
                    fname = ['../data/' suj '/field/' suj '.' cond_main{cnd_cue} 'DIS1.' list_time{ntime} list_freq{nfreq} ext_sorce];
                    fprintf('Loading %50s\n',fname);
                    load(fname);
                    
                    act_source                                        = source; clear source
                    
                    pow                                               = act_source-bsl_source; %(act_source-bsl_source)./bsl_source;%;
                    
                    allsuj_avg{sb,cnd_cue,ntime,nfreq}.pow            = pow ;
                    allsuj_avg{sb,cnd_cue,ntime,nfreq}.pos            = template_grid.pos ;
                    allsuj_avg{sb,cnd_cue,ntime,nfreq}.dim            = template_grid.dim ;
                    allsuj_avg{sb,cnd_cue,ntime,nfreq}.inside         = template_grid.inside;
                    
                    clear act_source bsl_source pow
                    
                end
            end
        end
        
        clc ; fprintf('Calculating Behavioral Measures for %s\n',suj);
        
        list_ix_cue                     = 0:2;
        list_ix_tar                     = 1:4;
        list_ix_dis                     = 1;
        
        [dis1_median,dis1_mean,~,~,~]   = h_new_behav_eval(suj,list_ix_cue,list_ix_dis,list_ix_tar);
        
        list_ix_dis                     = 2;
        [dis2_median,dis2_mean,~,~,~]   = h_new_behav_eval(suj,list_ix_cue,list_ix_dis,list_ix_tar);
        
        list_ix_dis                     = 0;
        [dis0_median,dis0_mean,~,~,~]   = h_new_behav_eval(suj,list_ix_cue,list_ix_dis,list_ix_tar);
        
        list_ix_cue                     = [1 2];
        list_ix_tar                     = 1:4;
        list_ix_dis                     = 0;
        [inf_median,inf_mean,~,~,~]     = h_new_behav_eval(suj,list_ix_cue,list_ix_dis,list_ix_tar);
        
        list_ix_cue                     = 0;
        [unf_median,unf_mean,~,~,~]     = h_new_behav_eval(suj,list_ix_cue,list_ix_dis,list_ix_tar);
        
        allsuj_behav{sb,1}              = dis2_median - dis1_median;
        allsuj_behav{sb,2}              = dis2_mean - dis1_mean;
        
        allsuj_behav{sb,3}              = unf_median - inf_median;
        allsuj_behav{sb,4}              = unf_mean - inf_mean ;
        
        allsuj_behav{sb,5}              = dis0_median - dis1_median;
        allsuj_behav{sb,6}              = dis0_mean - dis1_mean ;
        
        clearvars -except sb allsuj_* template_* list_* suj_group suj_list ngroup stat
        
    end
    
    clearvars -except allsuj_* list_* suj_group template_* suj_list ngroup stat
    
    for cnd = 1:size(allsuj_avg,2)
        for ntime = 1:size(allsuj_avg,3)
            for nfreq  = 1:size(allsuj_avg,4)
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
                    
                    stat{ngroup,cnd,ntime,nfreq,ntest}  = ft_sourcestatistics(cfg, allsuj_avg{:,cnd,ntime,nfreq});
                    %                     stat{cnd,ntime,nfreq,ntest}         = rmfield(stat{cnd,ntime,nfreq,ntest},'cfg');
                    
                end
            end
        end
    end
    
    clearvars -except suj_group stat template_* ngroup
    
end

clearvars -except sb allsuj_* stat list_*

% load ../data_fieldtrip/stat/allYoung_final_dis_correlation_spearman.mat

list_test   = {'medianCapture','meanCapture','medianTD','meanTD','medianArousal','meanArousal'};

for ngroup = 1:size(stat,1)
    for cnd = 1:size(stat,2)
        for ntime = 1:size(stat,3)
            for nfreq  =1:size(stat,4)
                for ntest = 1:size(stat,5)
                    
                    stat_to_plot                                                                    = stat{ngroup,cnd,ntime,nfreq,ntest};
                    [min_p(ngroup,cnd,ntime,nfreq,ntest),p_val{ngroup,cnd,ntime,nfreq,ntest}]       = h_pValSort(stat_to_plot);
                    
                end
            end
        end
    end
end

% clearvars -except sb allsuj_* stat min_p p_val list_*
%
% i = 0 ;
%
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

p_limit     = 0.11; close all ;

for ngroup = 1:size(stat,1)
    for cnd = 1:size(stat,2)
        for ntime = 1:size(stat,3)
            for nfreq  =1:size(stat,4)
                for ntest = 1:size(stat,5)
                    
                    s2plot                              = stat{ngroup,cnd,ntime,nfreq,ntest};
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
                            
                            list_group                    = {'allyoung'} ; % {'old','young','common'};
                            
                            title([list_group{ngroup} ' ' list_test{ntest} ' ' num2str(single_min_p)]);
                            
                        end
                    end
                end
            end
        end
    end
end