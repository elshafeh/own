clear ; clc ;

cfg = [];

cfg.dataset = '../../../PAT_MEG2/Fieldtripping/data/ds/yc1.pat2.b1.ds';

cfg.trialdef.eventtype  = 'UPPT001';
cfg.trialdef.eventvalue = 101 ;
cfg.trialdef.prestim    =  2;
cfg.trialdef.poststim   =  2;

cfg          = ft_definetrial(cfg);
cfg.channel  ='EEG';

data         = ft_preprocessing(cfg);
avg          = ft_timelockanalysis([],data);

