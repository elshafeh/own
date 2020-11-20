clear ; clc ; dleiftrip_addpath;

% load lowFreq

list_bands = {'.CnD.MaxAudVizMotor.BigCov.VirtTimeCourse.all.wav.NewEvoked.1t20Hz.m3000p3000.mat',...
    '.nDT.AudFrontal.VirtTimeCourse.all.wav.50t100Hz.m2000p1000.mat'};

list_bsl   = [-0.6 -0.2; -1.4 -1.3];
list_chan  = [4 6; 1 1];
list_time  = [1.3 1.5; 0.1 0.3];
list_freq  = [7 15; 50 70];

for sb = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))];
    
    for c = 1:2
        
        load(['../data/tfr/' suj list_bands{c}]);
                
        if isfield(freq,'hidden_trialinfo')
            freq    = rmfield(freq,'hidden_trialinfo');
        end
        
        cfg                     =[];
        cfg.baseline            = list_bsl(c,:);cfg.baselinetype        = 'relchange';
        freq                    = ft_freqbaseline(cfg,freq);
        
        cfg                     = [];
        cfg.channel             = list_chan(c,:);
        cfg.frequency           = list_freq(c,:);
        cfg.latency             = list_time(c,:);
        cfg.avgovertime         = 'yes';
        cfg.avgoverfreq         = 'yes';
        cfg.avgoverchan         = 'yes';
        freq                    = ft_selectdata(cfg,freq); 
        Data2Corr(sb,c)         = freq.powspctrm;clear freq ;
    end
end

clearvars -except Data2Corr

[rho_spear,p_spear] = corr(Data2Corr(:,1),Data2Corr(:,2), 'type', 'Spearman');
[rho_pear,p_pear] = corr(Data2Corr(:,1),Data2Corr(:,2), 'type', 'Pearson');