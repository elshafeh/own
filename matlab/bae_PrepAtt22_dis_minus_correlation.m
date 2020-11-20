clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,suj_list,~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_list        = suj_list(2:22);

load ../data_fieldtrip/template/template_grid_0.5cm.mat

for sb = 1:length(suj_list)
    
    suj = suj_list{sb};
    
    cond_main       = {'1','2'}; %
    
    ext_comp        = '.60t100Hz.p100p300.dpssFixedCommonDicSourceMinEvoked0.5cm.mat';
    
    for cnd_cue = 1:length(cond_main)
        
        fname = ['../data/' suj '/field/' suj '.fDIS'  cond_main{cnd_cue}  ext_comp];
        fprintf('Loading %50s\n',fname);
        load(fname);
        
        bsl_source            = source; clear source
        
        fname = ['../data/' suj '/field/' suj '.DIS'  cond_main{cnd_cue} ext_comp];
        fprintf('Loading %50s\n',fname);
        load(fname);
        
        act_source                                                  = source; clear source ;
        
        pow                                                         = act_source-bsl_source;
        
        pow(isnan(pow))                                             = 0;
        
        source_tmp{cnd_cue,1}                                       = pow;
        source_tmp{cnd_cue,2}                                       = act_source;
        
        clear act_source bsl_source pow
        
    end
    
    for nbsl = 1:2
        
        allsuj_avg{sb,nbsl}.pow                                     = source_tmp{2,nbsl} - source_tmp{1,nbsl}; 
        allsuj_avg{sb,nbsl}.pos                                     = template_grid.pos ;
        allsuj_avg{sb,nbsl}.dim                                     = template_grid.dim ;
        allsuj_avg{sb,nbsl}.inside                                  = template_grid.inside;
        
    end
    
    clear source_tmp
    
    list_ix_cue                                                     = 0:2;
    list_ix_tar                                                     = 1:4;
    list_ix_dis                                                     = 1;
    
    [dis1_median,dis1_mean,~,~,~]                                   = h_new_behav_eval(suj,list_ix_cue,list_ix_dis,list_ix_tar);
    
    list_ix_dis                                                     = 2;
    [dis2_median,dis2_mean,~,~,~]                                   = h_new_behav_eval(suj,list_ix_cue,list_ix_dis,list_ix_tar);
    
    
    allsuj_behav{sb,1}                                              = dis2_median - dis1_median;
    allsuj_behav{sb,2}                                              = dis2_mean - dis1_mean;
    
end

clearvars -except allsuj_* 

cfg                                                                 = [];
cfg.method                                                          = 'montecarlo';
cfg.statistic                                                       = 'ft_statfun_correlationT';

cfg.correctm                                                        = 'cluster';
cfg.clusterstatistics                                               = 'maxsum';

cfg.clusteralpha                                                    = 0.05;
cfg.tail                                                            = 0;
cfg.clustertail                                                     = 0;
cfg.alpha                                                           = 0.025;
cfg.numrandomization                                                = 1000;
cfg.ivar                                                            = 1;

cfg.type                                                            = 'Spearman';

nsuj                                                                = size(allsuj_behav,1);

for nbehav = 1:2
    for nbsl = 1:2
        
        cfg.design(1,1:nsuj)                                        = [allsuj_behav{:,nbehav}];
        stat{nbehav,nbsl}                                           = ft_sourcestatistics(cfg, allsuj_avg{:,nbsl});
        
        [min_p(nbehav,nbsl),p_val{nbehav,nbsl}]                     = h_pValSort(stat{nbehav,nbsl});
        
    end
end

clearvars -except allsuj_* stat min_p p_val