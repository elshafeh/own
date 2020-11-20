clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

% [~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');
% suj_group{1}    = allsuj(2:15,1);
% suj_group{2}    = allsuj(2:15,2);

[~,suj_group{1},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_group{1}        = suj_group{1}(2:22);

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        lst_dis = {'1fDIS','1DIS'};
        
        for cnd_dis = 1:2
            
            suj                 = suj_list{sb};
            
            %             fname_in            = ['../data/' suj '/field/' suj '.' lst_dis{cnd_dis} '.AudBroadSchaefFront.50t120Hz.m200p800msCov.waveletPOW.50t119Hz.m1000p1000.KeepTrialsMinEvoked.mat'];
            %             fprintf('Loading %s\n',fname_in);
            %
            %             load(fname_in)
            %
            %             if isfield(freq,'check_trialinfo')
            %                 freq = rmfield(freq,'check_trialinfo');
            %             end
            %
            %             freq           = ft_freqdescriptives([],freq);
            %
            %             new_chan_index = {[1 3 5],[2 4 6],7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33};
            %             new_chan_list  = {'audL' 'audR'};
            %             new_chan_list  = [new_chan_list freq.label(7:33)'];
            %
            %             freq            = h_transform_freq(freq,new_chan_index,new_chan_list);
            %             freq            = rmfield(freq,'cfg');
            
            fname_in       = ['../data/' suj '/field/' suj '.' lst_dis{cnd_dis} '.AudBroadSchaefFront.50t120Hz.m200p800msCov.waveletPOW.50t120Hz.m1000p1000.AvgTrialsMinEvoked10MStep.mat'];
            
            fprintf('Loading %s\n',fname_in);
            load(fname_in)
            
            list_ix_cue    = {''};
            
            for ncue = 1:length(list_ix_cue)
                allsuj_activation{ngroup}{sb,ncue,cnd_dis}            = freq;                
            end
        end
    end
end

clearvars -except allsuj_*;

for ngroup = 1:length(allsuj_activation)
    
    nsuj                    = size(allsuj_activation{ngroup},1);
    [design,neighbours]     = h_create_design_neighbours(nsuj,allsuj_activation{1}{1},'virt','t'); clc;
    
    for ncue = 1:size(allsuj_activation{ngroup},2)
        
        cfg                     = [];
        cfg.clusterstatistic    = 'maxsum';
        cfg.method              = 'montecarlo';
        cfg.statistic           = 'depsamplesT';
        cfg.correctm            = 'cluster';
        
        cfg.latency             = [-0.1 0.6];
        cfg.frequency           = [50 110];
        
        cfg.clusteralpha        = 0.05;
        cfg.alpha               = 0.025;
        
        cfg.neighbours          = neighbours;
        cfg.minnbchan           = 0;
        
        cfg.tail                = 0; ! 
        cfg.clustertail         = 0; !
        
        cfg.numrandomization    = 1000;
        cfg.design              = design;
        cfg.uvar                = 1;
        cfg.ivar                = 2;
        
        stat{ngroup,ncue}      = ft_freqstatistics(cfg, allsuj_activation{ngroup}{:,ncue,2},allsuj_activation{ngroup}{:,ncue,1});
        stat{ngroup,ncue}      = rmfield(stat{ngroup,ncue},'cfg');
    end
end

for ngroup = 1:size(stat,1)
    for ncue = 1:size(stat,2)
        [min_p(ngroup,ncue),p_val{ngroup,ncue}] = h_pValSort(stat{ngroup,ncue});
    end
end

i = 0 ;

for ngroup = 1:size(stat,1)
    for ncue = 1:size(stat,2)
        
        stat{ngroup,ncue}.mask  = stat{ngroup,ncue}.prob < 0.05;
        
        for nchan = [1 2 11:17 24:29 3:10 18:23];

            i = i + 1;
            
            subplot(6,5,i)
            
            cfg                 = [];
            cfg.channel         = nchan;
            cfg.parameter       = 'stat';
            cfg.maskparameter   = 'mask';
            cfg.maskstyle       = 'outline';
            cfg.zlim            = [-5 5];
            cfg.colorbar        = 'no';
            ft_singleplotTFR(cfg,stat{ngroup,ncue});
            
            list_ix            = {''};
            list_grp           = {'AllYun'};
            
            title(stat{ngroup,ncue}.label{nchan})
            
        end
    end
end