clear;clc;

suj_list = [1:4 8:17];
maxIAF   = zeros(14,6);

for sb = 1:14
    
    suj = ['yc' num2str(suj_list(sb))];
    
    load(['../data/pe/' suj '.CnD.MaxAudVizMotor.BigCov.VirtTimeCourse.mat']);
    
    tlist           = [-0.6 0.2 0.6];
    
    for t = 1:3
        
        cfg             = [];
        cfg.channel     = 1:6;
        cfg.latency     = [tlist(t) tlist(t)+0.4];
        slct            = ft_selectdata(cfg,virtsens);
        
        cfg             = [];
        cfg.method      = 'mtmfft';
        cfg.output      = 'pow';
        cfg.foilim      = [5 15];
        cfg.tapsmofrq   = 2.5;
        cfg.taper       = 'dpss';
        freq            = ft_freqanalysis(cfg,slct);
        
        allsujpow(sb,t,:,:) = freq.powspctrm;
        tmplate_freq        = freq.freq; clear freq
    end
    
end

clearvars -except allsujpow tmplate_freq

for sb = 1:14
    for chn = 1:6
        
        t       = 3;
        
        actv    = squeeze(allsujpow(sb,t,chn,:));
        bsl     = squeeze(allsujpow(sb,1,chn,:));
        pow     = (actv-bsl)./bsl;
        
        if chn < 3
            ix                  = find(pow==max(pow));
        else
            ix                  = find(pow==min(pow));
        end
        
        maxIAF(sb,chn)      = tmplate_freq(ix); clear ix;
        
    end
end

clearvars -except allsujpow tmplate_freq maxIAF

boxplot(maxIAF);