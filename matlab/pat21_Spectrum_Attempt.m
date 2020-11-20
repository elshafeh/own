clear;clc;

suj_list = [1:4 8:17];
maxIAF   = zeros(14,6);

for sb = 1:14
    
    suj = ['yc' num2str(suj_list(sb))];
    
    load(['../data/pe/' suj '.CnD.MaxAudVizMotor.BigCov.VirtTimeCourse.mat']);
    
    cfg             = [];
    %     cfg.channel     = 1:6;
    cfg.latency     = [0.6 1.1];
    virtsens        = ft_selectdata(cfg,virtsens);
    
    cfg             = [];
    cfg.method      = 'mtmfft';
    cfg.output      = 'pow';
    cfg.foilim      = [5 15];
    cfg.tapsmofrq   = 2;
    cfg.taper       = 'dpss';
    freq            = ft_freqanalysis(cfg,virtsens);
    
    for chn = 1:length(freq.label)
        mtrx                = freq.powspctrm(chn,:);
        ix                  = find(mtrx==max(mtrx));
        maxIAF(sb,chn)      = freq.freq(ix);
        clear ix mtrx;
    end
    
    clear freq suj virtsens
    
end