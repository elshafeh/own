for sb = 1:14
    
    suj_list = [1:4 8:17];
    
    suj = ['yc' num2str(suj_list(sb))];
    
    fname = ['../data/' suj '/tfr/' suj '.CnD.postConn.TimeCourse.kt.wav.5t18Hz.m3p3.mat'];
    
    fprintf('Loading %30s\n',fname);
    load(fname);
    
    cfg                 = [];
    cfg.channel         = 1:6;
    freq_temp           = ft_selectdata(cfg,freq);
    
    clear freq ; 
    
    fname = ['../data/' suj '/tfr/' suj '.CnD.Motor.TimeCourse.KeepTrial.wav.5t18Hz.m4p4.mat'];
    fprintf('Loading %30s\n',fname);
    load(fname);
    
    cfg             = [];
    cfg.latency     = [-3 3];
    freq            = ft_selectdata(cfg,freq);
    
    cfg                 = [];
    cfg.parameter       = 'powspctrm';
    cfg.appenddim       = 'chan';
    freq                = ft_appendfreq(cfg,freq,freq_temp);
    
    clear freq_temp
    
    cfg                         = [];
    cfg.baseline                = [-0.6 -0.2];
    cfg.baselinetype            = 'relchange';
    big_data{sb,1}              = ft_freqbaseline(cfg,freq);
    big_data{sb,2}              = freq;
    
end

clearvars -except big_data
