function [all_cfg] = taco_func_definetrial(dsFileName)

% define trials locked to all cues and all targets and responses
% adds in behavioral results as well

cfg                             = [];
cfg.dataset                     = dsFileName;
cfg.trialfun                    = 'ft_trialfun_general';
cfg.trialdef.eventtype          = 'UPPT001';

cfg.trialdef.eventvalue         = [111   112   121   122];
cfg.trialdef.prestim            = 1.5;
cfg.trialdef.poststim           = 12;
first_cue                       = ft_definetrial(cfg);

cfg.trialdef.prestim            = 0;
cfg.trialdef.poststim           = 2;

cfg.trialdef.eventvalue         = [11 12];
first_samp                      = ft_definetrial(cfg);

cfg.trialdef.eventvalue         = [21  22];
second_samp                     = ft_definetrial(cfg);

cfg.trialdef.eventvalue         = [211   212   221   222];
second_cue                      = ft_definetrial(cfg);

cfg.trialdef.eventvalue         = [31 32];
probe                           = ft_definetrial(cfg);

cfg.trialdef.eventvalue         = 77;
mapping                         = ft_definetrial(cfg);

cfg.trialdef.eventvalue         = [71 72 73 74 75];
cfg.trialdef.prestim            = 2;
cfg.trialdef.poststim           = 2;
localizer                       = ft_definetrial(cfg);

cfg.trialdef.eventtype          = 'UPPT002';
cfg.trialdef.eventvalue         = [1 8];
cfg.trialdef.prestim            = 0;
cfg.trialdef.poststim           = 2;
response                        = ft_definetrial(cfg);

all_cfg.trl{1}                  = first_cue.trl;
all_cfg.trl{2}                  = first_samp.trl;
all_cfg.trl{3}                  = second_samp.trl;
all_cfg.trl{4}                  = second_cue.trl;
all_cfg.trl{5}                	= probe.trl;
all_cfg.trl{6}               	= mapping.trl;
all_cfg.trl{7}                  = response.trl;
all_cfg.trl{8}                  = localizer.trl;

all_cfg.list                    = {'firstcue' 'firstsamp' 'secondsamp' 'secondcue' 'probe' 'mapping' 'response' 'localizer'};