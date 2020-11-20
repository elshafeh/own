clear ; clc ;

addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));
addpath('../scripts.m/');

[~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');

suj_group{1}    = allsuj(2:15,1);
suj_group{2}    = allsuj(2:15,2);

% [~,suj_group{3},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
% suj_group{3}        = suj_group{3}(2:22);

lst_group       = {'Old','Young'};

for ngroup = 1:length(lst_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj                     = suj_list{sb};
        cond_main               = 'CnD';
        
        fname_in                = ['../data/' suj '/field/' suj '.' cond_main '.waveletPOW.1t20Hz.m3000p3000.KeepTrials.mat'];
        fprintf('\nLoading %50s \n',fname_in);
        load(fname_in)
        
        if isfield(freq,'check_trialinfo')
            freq = rmfield(freq,'check_trialinfo');
        end
        
        list_ix_cue        = {0:2};
        list_ix_tar        = {1:4};
        list_ix_dis        = {0};
        list_ix            = {''};
        
        for ncue = 1:length(list_ix_cue)
            
            cfg                             = [];
            cfg.trials                      = h_chooseTrial(freq,list_ix_cue{ncue},list_ix_dis{ncue},list_ix_tar{ncue});
            new_freq                        = ft_selectdata(cfg,freq);
            new_freq                        = ft_freqdescriptives([],new_freq);
            
            cfg                             = [];
            cfg.baseline                    = [-0.6 -0.2];
            cfg.baselinetype                = 'relchange';
            new_freq                        = ft_freqbaseline(cfg,new_freq);
            
            [med_rt,mean_rt,perc_corr,~,~]  = h_behav_eval(suj,list_ix_cue{ncue},list_ix_dis{ncue},list_ix_tar{ncue});
            
            allsuj_data{ngroup}{sb,ncue}    = new_freq;
            allsuj_behav{ngroup}{sb,ncue,1} = med_rt;
            allsuj_behav{ngroup}{sb,ncue,2} = mean_rt;
            allsuj_behav{ngroup}{sb,ncue,3} = perc_corr;
            
            
        end
    end
end

clearvars -except allsuj_data allsuj_behav lst_group list_ix

[~,neighbours]          = h_create_design_neighbours(14,allsuj_data{1}{1},'meg','t'); clc;

for ngroup = 1:length(allsuj_data)
    for ncue = 1:size(allsuj_behav{ngroup},2)
        for ntest = 1:size(allsuj_behav{ngroup},3)
            
            cfg                                 = [];
            cfg.latency                         = [0 2];
            cfg.frequency                       = [7 15];
            cfg.method                          = 'montecarlo';
            cfg.statistic                       = 'ft_statfun_correlationT';
            cfg.correctm                        = 'cluster';
            cfg.clusterstatistics               = 'maxsum';
            cfg.clusteralpha                    = 0.005; % !! !! !!
            cfg.minnbchan                       = 4;
            cfg.neighbours                      = neighbours;
            cfg.tail                            = 0;
            cfg.clustertail                     = 0;
            cfg.alpha                           = 0.025;
            cfg.numrandomization                = 1000;
            cfg.ivar                            = 1;
            
            cfg.type                            = 'Spearman';
            
            nsuj                                = size(allsuj_behav{ngroup},1);
            cfg.design(1,1:nsuj)                = [allsuj_behav{ngroup}{:,ncue,ntest}];
            
            lst_behav                           = {'medianRT','meanRT','perCorrect'};
            stat{ngroup,ncue,ntest}             = ft_freqstatistics(cfg, allsuj_data{ngroup}{:,ncue});
            
        end
    end
end

clearvars -except allsuj_data allsuj_behav lst_group list_ix stat lst_behav

for ngroup = 1:size(stat,1)
    for ncue = 1:size(stat,2)
        for ntest = 1:size(stat,3)
            
            [min_p(ngroup,ncue,ntest),p_val{ngroup,ncue,ntest}] = h_pValSort(stat{ngroup,ncue,ntest});
            
        end
    end
end
            
for ngroup = 1:size(stat,1)
    
    figure;
    i = 0 ;
    
    for ncue = 1:size(stat,2)
        for ntest = 1:size(stat,3)
            
            stoplot                 = stat{ngroup,ncue,ntest};
            stoplot.mask            = stoplot.prob < 0.11;
            
            corr2plot.label         = stoplot.label;
            corr2plot.freq          = stoplot.freq;
            corr2plot.time          = stoplot.time;
            corr2plot.powspctrm     = stoplot.rho .* stat{ngroup,ncue,ntest}.mask;
            corr2plot.dimord        = stoplot.dimord;
            
            i                       = i+1 ;
            
            subplot(size(stat,2),size(stat,3),i)
            
            cfg                     = [];
            cfg.comment             = 'no';
            cfg.marker              = 'off';
            cfg.layout              = 'CTF275.lay';
            cfg.zlim                = [-0.3 0.3];
            ft_topoplotTFR(cfg,corr2plot);
            
            title([lst_group{ngroup} ' ' list_ix{ncue} ' ' lst_behav{ntest}])
            
        end
    end
end