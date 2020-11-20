clear; clc ; dleiftrip_addpath ;

for sb = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))];
    ext_essai   = 'CnD.SomaGammaNoAVG.CoV.m800p2000ms.freq.1t120Hz.mat';
    
    fname_in = [suj '.' ext_essai];
    fprintf('\nLoading %50s \n\n',fname_in);
    load(['../data/pe/' fname_in]);
    
    nw_chn  = [61 62 149 150;63 64 151 152];
    nw_lst  = {'aud Left','aud Right'};
    
    for l = 1:size(nw_chn,1)
        cfg             = [];
        cfg.channel     = nw_chn(l,:);
        cfg.avgoverchan = 'yes';
        nwfrq{l}        = ft_selectdata(cfg,virtsens);
        nwfrq{l}.label  = nw_lst(l);
    end
    
    cfg             = [];
    cfg.parameter   = 'powspctrm';cfg.appenddim   = 'chan';
    virtsens        = ft_appenddata(cfg,nwfrq{:}); clear nwfrq
    
    cfg             = [];
    cfg.method      = 'wavelet';
    cfg.output      = 'fourier';
    cfg.toi         = -1:0.01:2;
    cfg.foi         = 1:1:100;
    freq            = ft_freqanalysis(cfg, virtsens);
    freq            = rmfield(freq,'cfg');
    
    itc             = [];
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
    
    clear F N
    
    fprintf('\nSaving %s\n',suj);
    
    save(['../data/tfr/' suj '.m1000p2000.1t100Hz.fourier.mat'],'freq');
    save(['../data/tfr/' suj '.m1000p2000.1t100Hz.itc.mat'],'itc');

    clearvars -except sb
    
end