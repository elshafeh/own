clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');
suj_group{1}    = allsuj(2:15,1);
suj_group{2}    = allsuj(2:15,2);

% [~,suj_group{1},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
% suj_group{1}        = suj_group{1}(2:22);

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj             = suj_list{sb};
        suj_list        = suj_group{ngroup};
        
        fname_in        = ['../data/' suj '/field/' suj '.CnD.waveletPOW.1t20Hz.m3000p3000.KeepTrials.mat'];
        
        if ~exist(fname_in)
            fname_in    = ['../data/' suj '/field/' suj '.CnD.waveletPOW.1t20Hz.m3000p3000.KeepTrials..mat'];
        end
        
        fprintf('Loading %50s\n',fname_in);
        load(fname_in);
        
        freq            = rmfield(freq,'check_trialinfo');
        
        load(['../data/' suj '/field/' suj '.CnD.AgeContrast80Slct.RLNRNL.mat']);
        
        cfg             = [];
        cfg.trials      = [trial_array{:}];
        freq            = ft_selectdata(cfg,freq);
        
        [~,~,strl_rt]   = h_new_behav_eval(suj);
        strl_rt         = strl_rt([trial_array{:}]); % temps reaction
        
        fprintf('Baseline Correction for %s\n',suj)
        
        lmt1            = find(round(freq.time,3) == round(-0.6,3));
        lmt2            = find(round(freq.time,3) == round(-0.2,3));
        
        bsl             = mean(freq.powspctrm(:,:,:,lmt1:lmt2),4);
        bsl             = repmat(bsl,[1 1 1 size(freq.powspctrm,4)]);
        
        freq.powspctrm  = freq.powspctrm ./ bsl ; clear bsl ;
        
        for ix_cue          = 1:3
            
            ix_trial        = h_chooseTrial(freq,ix_cue-1,0,1:4);
            new_strl_rt     = strl_rt(ix_trial);
            
            time_window     = 0.1;
            time_list       = 0:time_window:1.1;
            freq_window     = 0 ;
            freq_list       = 5:15 ;
            
            allsuj_data{ngroup}{sb,ix_cue,1}.powspctrm = [];
            allsuj_data{ngroup}{sb,ix_cue,1}.dimord    = 'chan_freq_time';
            
            allsuj_data{ngroup}{sb,ix_cue,1}.freq      = freq_list;
            allsuj_data{ngroup}{sb,ix_cue,1}.time      = time_list;
            allsuj_data{ngroup}{sb,ix_cue,1}.label     = freq.label;
            
            fprintf('Calculating Correlation for %s\n',suj)
            
            for nfreq = 1:length(freq_list)
                for ntime = 1:length(time_list)
                    
                    lmt1    = find(round(freq.time,3) == round(time_list(ntime),3));
                    lmt2    = find(round(freq.time,3) == round(time_list(ntime) + time_window,3));
                    
                    lmf1    = find(round(freq.freq) == round(freq_list(nfreq)));
                    lmf2    = find(round(freq.freq) == round(freq_list(nfreq)+freq_window));
                    
                    data    = squeeze(freq.powspctrm(ix_trial,:,lmf1:lmf2,lmt1:lmt2));
                    data    = mean(data,3);
                    
                    [rho,p] = corr(data,new_strl_rt , 'type', 'Spearman');
                    
                    mask    = p<0.05;
                    %                     rho     = mask .* rho ; %% !!!!
                    
                    rhoF    = .5.*log((1+rho)./(1-rho)); % z - transformation
                    
                    allsuj_data{ngroup}{sb,ix_cue,1}.powspctrm(:,nfreq,ntime) = rho ; clear rho p data ;
                    
                end
            end
            
            allsuj_data{ngroup}{sb,ix_cue,2}               = allsuj_data{ngroup}{sb,1};
            allsuj_data{ngroup}{sb,ix_cue,2}.powspctrm(:)  = 0;
            
        end
        
        clear freq
        
    end
end

clearvars -except allsuj_data ;

nsubj                   = 14;

[~,neighbours]          = h_create_design_neighbours(nsubj,allsuj_data{1}{1},'meg','t'); clc;

cfg                     = [];
cfg.clusterstatistic    = 'maxsum';
cfg.method              = 'montecarlo';
cfg.statistic           = 'indepsamplesT';
cfg.correctm            = 'cluster';
cfg.neighbours          = neighbours;
cfg.clusteralpha        = 0.05;
cfg.alpha               = 0.025;
cfg.minnbchan           = 4;
cfg.tail                = 0;
cfg.clustertail         = 0;
cfg.numrandomization    = 1000;
cfg.design              = [ones(1,nsubj) ones(1,nsubj)*2];
cfg.ivar                = 1;
% cfg.latency             = [0 1.2];

for ncue = 1:size(allsuj_data{1},2)
    stat{ncue}            = ft_freqstatistics(cfg, allsuj_data{2}{:,ncue,1},allsuj_data{1}{:,ncue,1});
end

for ncue = 1:size(stat,2)
    [min_p(ncue), p_val{ncue}]  = h_pValSort(stat{ncue}) ;
end

i = 0 ;

list_cue = {'CnD'};

for ncue = 1:size(stat,2)
    
    plimit                  = 0.4;
    stat2plot               = h_plotStat(stat{ncue},0.000000000000000000000000000001,plimit);
    
    figure;
    
    i = i + 1;
    
    cfg         = [];
    cfg.layout  = 'CTF275.lay';
    cfg.zlim    = [-0.5 0.5];
    cfg.marker  = 'off';
    cfg.comment = 'no';
    ft_topoplotTFR(cfg,stat2plot);
    
end