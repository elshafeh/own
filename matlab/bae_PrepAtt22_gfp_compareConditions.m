clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

% [~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');
%
% suj_group{1}    = allsuj(2:15,1);
% suj_group{2}    = allsuj(2:15,2);
%
% [~,suj_group{3},~]  = xlsread('../documents/PrepAtt2_PreProcessingIndex.xlsx','B:B');
% suj_group{3}        = suj_group{3}(2:22);
%
% lst_group       = {'Old','Young','allyoung'};

load ../data_fieldtrip/index/age_group_performance_split.mat

for ngrp = 1:length(suj_group)
    
    suj_list = suj_group{ngrp};
    
    for sb = 1:length(suj_list)
        
        suj                 = suj_list{sb};
        cond_main           = 'CnD';
        cond_sub            = {'R.80Slct','L.80Slct','N.80Slct','V.80Slct'};
        
        for ncue = 1:length(cond_sub)
            
            if strcmp(cond_main,'CnD')
                fname_in            = ['../data/' suj '/field/' suj '.' cond_sub{ncue} cond_main '.bpOrder2Filt0.2t20Hz.pe.mat'];
            else
                fname_in            = ['../data/' suj '/field/' suj '.' cond_sub{ncue} cond_main '.bpOrder2Filt0.5t20Hz.pe.mat'];
            end
            
            fprintf('Loading %s\n',fname_in);
            
            load(fname_in);
            
            cfg                                 = [];
            cfg.baseline                        = [-0.1 0];
            data_pe                             = ft_timelockbaseline(cfg,data_pe);
            
            cfg                                 = [];
            cfg.method                          = 'amplitude';
            data_gfp                            = ft_globalmeanfield(cfg,data_pe);
            
            
            cfg                                 = [];
            cfg.time_start                      = data_gfp.time(1);
            cfg.time_end                        = data_gfp.time(end);
            cfg.time_step                       = 0.02;
            cfg.time_window                     = 0.02;
            data_gfp                            = h_smoothTime(cfg,data_gfp);
            
            allsuj_data{ngrp}{sb,ncue}          = data_gfp;
            
            clear data_pe
            
        end
        
    end
    
    for ncue = 1:size(allsuj_data{ngrp},2)
        gavg_data{ngrp,ncue} = ft_timelockgrandaverage([],allsuj_data{ngrp}{:,ncue});
    end
    
end

clearvars -except *_data cond_sub lst_group;

for ngroup = 1:length(allsuj_data)
    
    ix_test                     = [1 2; 1 3; 2 3; 4 3];
    
    for ntest = 1:size(ix_test,1)
        
        
        cfg                     = [];
        cfg.latency             = [0.5 1.2];
        cfg.statistic           = 'ft_statfun_depsamplesT';
        cfg.method              = 'montecarlo';
        cfg.correctm            = 'cluster';
        cfg.clusteralpha        = 0.05;
        cfg.clusterstatistic    = 'maxsum';
        cfg.minnbchan           = 0;
        cfg.tail                = 0;
        cfg.clustertail         = 0;
        cfg.alpha               = 0.025;
        cfg.numrandomization    = 1000;
        cfg.uvar                = 1;
        cfg.ivar                = 2;
        
        nbsuj                   = length(allsuj_data{ngroup});
        [design,~]              =  h_create_design_neighbours(nbsuj,allsuj_data{1}{1},'gfp','t');
        
        cfg.design              = design;
        stat{ngroup,ntest}      = ft_timelockstatistics(cfg, allsuj_data{ngroup}{:,ix_test(ntest,1)}, allsuj_data{ngroup}{:,ix_test(ntest,2)});
        
    end
end


% load ../data_fieldtrip/stat/gfp_nDT_123OldYoungAllYoung_RNR.LNL.VN.mat
% load ../data_fieldtrip/stat/gfp_cnd_123OldYoungAllYoung_RNR.LNL.VN.mat


for ngroup = 1:size(stat,1)
    for ntest = 1:size(stat,2)
        [min_p(ngroup,ntest),p_val{ngroup,ntest}]           = h_pValSort(stat{ngroup,ntest}) ;
    end
end

cond_sub  = {'Inf R','Inf L','UnF','InF'} ; %'Inf L','Unf L','Inf','Unf'};
lst_group = {'Old','Young'};
i         =  0 ;

for ngroup = 1:size(stat,1)
    for ntest = 1:size(stat,2)
        
        i = i + 1;
        
        subplot(size(stat,1),size(stat,2),i)
        
        cfg                 = [];
        cfg.p_threshold     = 0.05;
        cfg.lineWidth       = 3;
        cfg.time_limit      = [-0.1 1.2];
        cfg.z_limit         = [0 60];
        cfg.fontSize        = 18;
        
        h_plotSingleERFstat(cfg,stat{ngroup,ntest},gavg_data{ngroup,ix_test(ntest,1)},gavg_data{ngroup,ix_test(ntest,2)});
        
        legend({cond_sub{ix_test(ntest,1)},cond_sub{ix_test(ntest,2)}})
        title([lst_group{ngroup} ' min p = ' num2str(round(min_p(ngroup,ntest),5))])
        
        set(gca,'fontsize', 18)
        
    end
end