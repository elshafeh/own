function [suj_activation,suj_baselineRep]  = h_prepareBaseline(freq,lst_frq,lst_bsl,lst_act,prcss)

cfg                         = [];
cfg.frequency               = lst_frq;
freq                        = ft_selectdata(cfg, freq);

cfg                         = [];
cfg.latency                 = lst_bsl;
cfg.avgovertime             = 'yes';
cfg.nanmean                 = 'yes';
suj_baselineAvg             = ft_selectdata(cfg, freq);

cfg                         = [];
cfg.latency                 = lst_act;
suj_activation              = ft_selectdata(cfg, freq);

suj_baselineRep             = suj_activation;

if length(size(suj_activation.powspctrm)) == 3
    suj_baselineRep.powspctrm   = repmat(suj_baselineAvg.powspctrm,1,1,size(suj_activation.powspctrm,3));
else
    suj_baselineRep.powspctrm   = repmat(suj_baselineAvg.powspctrm,1,1,1,size(suj_activation.powspctrm,4));
end

if strcmp(prcss,'makezero')
   suj_baselineRep.powspctrm(:,:,:) = 0; 
end

clear  suj_baselineAvg