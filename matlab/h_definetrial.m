function [all_cfg] = h_definetrial(dsFileName)

% define trials locked to all cues and all targets and responses
% adds in behavioral results as well

cfg                             = [];
cfg.dataset                     = dsFileName;
cfg.trialfun                    = 'ft_trialfun_general';
cfg.trialdef.eventtype          = 'UPPT001';

cfg.trialdef.eventvalue         = [11 12 13];
cfg.trialdef.prestim            = 1;
cfg.trialdef.poststim           = 7;
all_cfg.first_cue               = ft_definetrial(cfg);

cfg.trialdef.prestim            = 0;
cfg.trialdef.poststim           = 2;

cfg.trialdef.eventvalue         = [21   22   23];
all_cfg.second_cue              = ft_definetrial(cfg);
all_cfg.second_cue              = all_cfg.second_cue.trl;

cfg.trialdef.eventvalue         = [111   112   113   114 121   122   123   124];
all_cfg.target                  = ft_definetrial(cfg);
all_cfg.target                  = all_cfg.target.trl;

cfg.trialdef.eventvalue         = [211   212   213   214 221   222   223   224];
all_cfg.probe                   = ft_definetrial(cfg);
all_cfg.probe                   = all_cfg.probe.trl;

cfg.trialdef.eventtype          = 'UPPT002';
cfg.trialdef.eventvalue         = [1 8];
all_cfg.response                = ft_definetrial(cfg);
all_cfg.response                = all_cfg.response.trl;

subjectName                     = strsplit(dsFileName,'/');
subjectName                     = subjectName{end};
subjectName                     = subjectName(1:6);

old_sj_list                     = {'pil01','pil02','pil03','pil05'};
ix                              = find(strcmp(subjectName,old_sj_list)==1);

if isempty(ix)
    all_cfg.first_cue           = h_addbehavior(subjectName,all_cfg.first_cue);
else
    all_cfg.first_cue           = h_addbehavior_old(subjectName,all_cfg.first_cue);
end