clear ; clc ; dleiftrip_addpath ;

clear;clc;dleiftrip_addpath;

for sb = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))];
    
    ext1        =   'CnD.SomaGammaNoAVGCoVm800p2000msfreq1t120Hz.all.wav.pow.4t120Hz.m3000p3000.mat';
    fname_in    =   ['../data/tfr/' suj '.'  ext1];
    
    fprintf('\nLoading %50s \n',fname_in);
    load(fname_in)
    
    if isfield(freq,'hidden_trialinfo')
        freq    = rmfield(freq,'hidden_trialinfo');
    end
    
    nw_chn  = [61 62 149 150;63 64 151 152];
    nw_lst  = {'aud Left','aud Right'};
    
    for l = 1:size(nw_chn,1)
        cfg             = [];
        cfg.channel     = nw_chn(l,:);
        cfg.avgoverchan = 'yes';
        nwfrq{l}        = ft_selectdata(cfg,freq);
        nwfrq{l}.label  = nw_lst(l);
    end
    
    cfg                 = [];
    cfg.parameter       = 'powspctrm';cfg.appenddim   = 'chan';
    freq                = ft_appendfreq(cfg,nwfrq{:}); clear nwfrq
    
    cfg                 = [];
    cfg.baseline        = [-0.6 -0.2];
    cfg.baselinetype    = 'relchange';
    freq                = ft_freqbaseline(cfg,freq);
    
    act_period          = {[0.32 0.42],[0.58 0.78]};
    
    for ntest = 1:length(act_period)
        cfg             = [];
        cfg.frequency   = [9 11];
        cfg.latency     = act_period{ntest};
        cfg.avgoverfreq = 'yes';
        cfg.avgovertime = 'yes';
        tmp             = ft_selectdata(cfg,freq);
        
        corr_mtrx(sb,ntest,:) = tmp.powspctrm';
        
    end
    
    clear freq ;
    
end

clearvars -except corr_mtrx

save ../data/yctot/corr/alphapow4p2pcorrelation.mat;