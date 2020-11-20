function [suj_activation,suj_baselineRep]  = h_prepareBaseline(freq,lst_bsl,lst_frq,lst_act,prcss)

cfg                         = [];
cfg.frequency               = lst_frq;
freq                        = ft_selectdata(cfg, freq);

cfg= [];
cfg.latency                 = lst_act;
suj_activation              = ft_selectdata(cfg, freq);

cfg                         = [];
cfg.latency                 = lst_bsl;
cfg.avgovertime             = 'yes';
suj_baselineAvg             = ft_selectdata(cfg, freq);
suj_baselineRep             = suj_activation;
suj_baselineRep.powspctrm   = repmat(suj_baselineAvg.powspctrm,1,1,size(suj_activation.powspctrm,3));

if strcmp(prcss,'makezero')
   suj_baselineRep.powspctrm(:,:,:) = 0; 
end

clear  suj_baselineAvg