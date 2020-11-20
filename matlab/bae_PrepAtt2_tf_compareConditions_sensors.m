clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

% [~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');

% suj_group{1}    = allsuj(2:15,1);
% suj_group{2}    = allsuj(2:15,2);

[~,suj_group{1},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_group{1}        = suj_group{1}(2:22);

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj                 = suj_list{sb};
        
        fname_in            = ['../data/' suj '/field/' suj '.CnD.waveletPOW.10t60Hz.m1000p2000.10Mstep.KeepTrials.MinEvoked.mat'];
        
        fprintf('Loading %s\n',fname_in);
        
        load(fname_in)
        
        if isfield(freq,'check_trialinfo')
            freq = rmfield(freq,'check_trialinfo');
        end
        
        big_freq                    = freq; clear freq ;
        
        list_ix_cue                 = {'R','L','N'};
        list_ix_cue_code            = {2,1,0};
        list_ix_dis_code            = {0,0,0};
        list_ix_tar_code            = {1:4,1:4,1:4};
        
        for ncue = 1:length(list_ix_cue)
            
            cfg                         = [];
            cfg.trials                  = h_chooseTrial(big_freq,list_ix_cue_code{ncue},list_ix_dis_code{ncue},list_ix_tar_code{ncue});
            freq                        = ft_selectdata(cfg,big_freq);
            
            freq                        = ft_freqdescriptives([],freq);
            freq                        = rmfield(freq,'cfg');
            
            save(['../data/' suj '/field/' suj '.' list_ix_cue{ncue} 'CnD.waveletPOW.10t60Hz.m1000p2000.10Mstep.AvgTrials.MinEvoked.mat'],'freq','-v7.3')
            
            cfg                         = [];
            cfg.baseline                = [-0.5 -0.2];
            cfg.baselinetype            = 'relchange';
            freq                        = ft_freqbaseline(cfg,freq);
            
            cfg                         = [];
            cfg.frequency               = [15 50];
            cfg.latency                 = [-0.1 1.2];
            freq                        = ft_selectdata(cfg,freq);
            
            allsuj_data{ngroup}{sb,ncue} = freq ; 
            
            clear freq ;
            
        end
        
        
        cfg                           = [];
        cfg.parameter                 = 'powspctrm';
        cfg.operation                 = 'x1-x2';
        allsuj_data{ngroup}{sb,4}     = ft_math(cfg,allsuj_data{ngroup}{sb,1},allsuj_data{ngroup}{sb,3});
        allsuj_data{ngroup}{sb,5}     = ft_math(cfg,allsuj_data{ngroup}{sb,2},allsuj_data{ngroup}{sb,3});
        
    end
end

clearvars -except allsuj_data list_ix_cue

for ngroup = 1:length(allsuj_data)
    
    ix_test                     = [1 2; 1 3; 2 3; 4 5];
    
    nsuj                        = size(allsuj_data{ngroup},1);
    [design,neighbours]         = h_create_design_neighbours(nsuj,allsuj_data{ngroup}{1},'meg','t'); clc;
    
    for ntest = 1:size(ix_test,1)
        
        cfg                     = [];
        cfg.clusterstatistic    = 'maxsum';
        
        cfg.latency             = [-0.2 1.2];
        
        %         cfg.frequency           = [7 15];
        
        cfg.method              = 'montecarlo';
        cfg.statistic           = 'depsamplesT';
        cfg.correctm            = 'cluster';
        cfg.neighbours          = neighbours;
        cfg.clusteralpha        = 0.05;
        cfg.alpha               = 0.025;
        cfg.minnbchan           = 4;
        cfg.tail                = 0;
        cfg.clustertail         = 0;
        cfg.numrandomization    = 1000;
        cfg.design              = design;
        cfg.uvar                = 1;
        cfg.ivar                = 2;
        
        stat{ngroup,ntest}      = ft_freqstatistics(cfg, allsuj_data{ngroup}{:,ix_test(ntest,1)},allsuj_data{ngroup}{:,ix_test(ntest,2)});
        stat{ngroup,ntest}      = rmfield(stat{ngroup,ntest},'cfg');
        
    end
end

clearvars -except allsuj_data list_ix_cue stat

for ngroup = 1:size(stat,1)
    for ntest = 1:size(stat,2)
        [min_p(ngroup,ntest), p_val{ngroup,ntest}]  = h_pValSort(stat{ngroup,ntest}) ;
    end
end

clearvars -except allsuj_data list_ix_cue stat min_p p_val

list_ix_group = {'allyoung'};
list_ix_test  = {'RvL','RvN','LvN','RmNvLmN'};

i  = 0 ;

for ngroup = 1:size(stat,1)
    
    %     figure;
    
    for ntest = 1:size(stat,2)
        
        plimit                  = 0.05;%(0.05)/(size(stat,1)*size(stat,2));
        
        stat2plot               = h_plotStat(stat{ngroup,ntest},0.000000000000000000000000000001,plimit);
        
        twin                    = 0.11;
        tlist                   = stat{ngroup,ntest}.time(1):twin:stat{ngroup,ntest}.time(end);
        zlimit                  = 1;
        fwin                    = 0;
        flist                   = 7:15;
        
        i = i + 1;
        
        subplot(size(stat,1),size(stat,2),i)
        
        cfg         = [];
        cfg.layout  = 'CTF275.lay';
        cfg.zlim    = [-zlimit zlimit];
        cfg.marker  = 'off';
        cfg.comment = 'no';
        ft_topoplotER(cfg,stat2plot);
        
        %         avg.time    = stat2plot.freq;
        %         avg.avg     = squeeze(mean(mean(stat2plot.powspctrm,1),3))';
        %
        %         plot(avg.time,avg.avg);
        %         ylim([-0.2 0.2]);
        %         xlim([avg.time(1) avg.time(end)])
        
        title([list_ix_group{ngroup} ' ' list_ix_test{ntest} ' min_p @ ' num2str(min_p(ngroup,ntest))]);
        
    end
end

% clearvars -except stat allsuj_data;
%
% for ngroup = 1:length(allsuj_data)
%     for ncue = 1:size(allsuj_data{ngroup},2)
%
%         grnd_average{ngroup,ncue} = ft_freqgrandaverage([],allsuj_data{ngroup}{:,ncue});
%
%     end
% end
%
% clearvars -except stat grnd_average;
%
% save('../data_fieldtrip/stat/123OldYoungAllyoung.5t15Hzm200p2000.1RNR2LNL.mat','stat','grnd_average','-v7.3');
