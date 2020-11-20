clear ; clc ; dleiftrip_addpath ;

for sb = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))];
    
    ext1        =   'CnD.MaxAudVizMotor.BigCov.VirtTimeCourse';
    fname_in    =   ['../data/tfr/' suj '.'  ext1 '.all.wav.1t20Hz.m3000p3000..mat'];
    
    fprintf('\nLoading %50s \n',fname_in); load(fname_in); freq        = rmfield(freq,'hidden_trialinfo');
    
    cfg                 = [];
    cfg.baseline        = [-0.6 -0.2]; cfg.baselinetype    = 'relchange'; freq                = ft_freqbaseline(cfg,freq);
    
    nw_chn              = [1 1;2 2;3 5; 4 6];
    nw_lst              = {'occ.L','occ.R','aud.L','aud.R'};
    
    for l = 1:size(nw_chn,1)
        cfg             = [];
        cfg.channel     = nw_chn(l,:);
        cfg.avgoverchan = 'yes';
        nwfrq{l}        = ft_selectdata(cfg,freq);
        nwfrq{l}.label  = nw_lst(l);
    end
    
    cfg             = []; cfg.parameter   = 'powspctrm';cfg.appenddim   = 'chan'; freq            = ft_appendfreq(cfg,nwfrq{:}); clear nwfrq
    
    cfg             = [];
    cfg.frequency   = [7 15];
    cfg.latency     = [0.6 1];
    cfg.avgovertime = 'yes';
    freq            = ft_selectdata(cfg,freq);
    
    for chn = 1:length(freq.label)
        data = squeeze(freq.powspctrm(chn,:));
        if chn < 3;val = find(data == max(data));else val = find(data == min(data));end
        iaf(sb,chn)     = round(freq.freq(val));
    end
    
end

clearvars -except iaf

boxplot(iaf(:,[1 3 2 4]),'Labels',{'occ.L','aud.L','occ.R','aud.R'});ylim([6 16])