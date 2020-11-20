clear; clc ; dleiftrip_addpath ;

for sb = 1:14
    
    suj_list = [1:4 8:17];
    suj = ['yc' num2str(suj_list(sb))];
    
    cnd_list = {'V','N'};
    
    for cnd = 1:length(cnd_list)
        
        fname_in = ['../data/tfr/' suj '.' cnd_list{cnd}  'DIS' '.all.wav.1t90Hz.m1500p1500.mat'];
        fprintf('\nLoading %50s \n',fname_in);
        load(fname_in)
        
        cfg                 = [];
        cfg.baseline        = [-0.4 -0.2];
        cfg.baselinetype    = 'relchange';
        freq                = ft_freqbaseline(cfg,freq);
        
        tmp{1} = freq ; clear freq ;
        
        fname_in = ['../data/tfr/' suj '.' cnd_list{cnd} 'fDIS' '.all.wav.1t90Hz.m1500p1500.mat'];
        fprintf('\nLoading %50s \n',fname_in);
        load(fname_in)
        
        cfg                 = [];
        cfg.baseline        = [-0.4 -0.2];
        cfg.baselinetype    = 'relchange';
        freq                = ft_freqbaseline(cfg,freq);
        
        tmp{2} = freq ; clear freq ;
        
        cfg                 = [];
        cfg.parameter       = 'powspctrm';
        cfg.operation       = 'x1-x2' ; % '(x1-x2)./x2';
        allsuj{sb,cnd}      = ft_math(cfg,tmp{1},tmp{2}); clear tmp ;
        
        cfg             = [];
        cfg.frequency   = [8 10];
        cfg.latency     = [0.3 0.6];
        cfg.avgoverfreq = 'yes';
        cfg.avgovertime = 'yes';
        allsuj{sb,cnd}  = ft_selectdata(cfg,allsuj{sb,cnd});
        
        toboplot(sb,cnd,:) = squeeze(allsuj{sb,cnd}.powspctrm);
        
    end
end

clearvars -except toboplot

for chn = 1:2
    subplot(1,2,chn);
    boxplot(squeeze(toboplot(:,:,chn)),'labels',{'V','N'});ylim([-1.5 0.5]);
end