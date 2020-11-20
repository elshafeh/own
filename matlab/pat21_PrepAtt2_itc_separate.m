clear; clc ; dleiftrip_addpath ;

for sb = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))];
    
    ext_essai   = '.m1000p2000.1t100Hz.fourier.mat';
    
    fname_in = [suj ext_essai];
    fprintf('\nLoading %50s \n\n',fname_in);
    load(['../data/tfr/' fname_in]);
    
    big_freq        = freq ; clear freq ;
    lst_cue         = {'LplusR'};
    
    for cnd = 1
        
        cfg             = [];
        cfg.trials      = h_chooseTrial(big_freq,[1 2],0,1:4);
        freq            = ft_selectdata(cfg,big_freq);
        
        
        itc             = [];
        itc.trialinfo   = freq.trialinfo;
        itc.label       = freq.label;
        itc.freq        = freq.freq;
        itc.time        = freq.time;
        itc.dimord      = 'chan_freq_time';
        
        F               = freq.fourierspctrm;  % copy the Fourier spectrum
        N               = size(F,1);           % number of trials
        
        % compute inter-trial phase coherence (itpc)
        itc.itpc        = F./abs(F);         % divide by amplitude
        itc.itpc        = sum(itc.itpc,1);   % sum angles
        itc.itpc        = abs(itc.itpc)/N;   % take the absolute value and normalize
        itc.itpc        = squeeze(itc.itpc); % remove the first singleton dimension
        
        % compute inter-trial linear coherence (itlc)
        itc.itlc        = sum(F) ./ (sqrt(N*sum(abs(F).^2)));
        itc.itlc        = abs(itc.itlc);     % take the absolute value, i.e. ignore phase
        itc.itlc        = squeeze(itc.itlc); % remove the first singleton dimension
        
        save(['../data/tfr/' suj '.' lst_cue{cnd} 'CnD.m1000p2000.1t100Hz.itc.mat'],'itc');
        
        clear F N freq itc
        
    end
    
    clearvars -except sb
    
end