function data = bil_changelock_onlysecondcue(subjectName,new_time_window,data_in)

if isunix
    subject_folder = ['/project/3015079.01/data/' subjectName '/preproc/'];
else
    subject_folder = ['P:/3015079.01/data/' subjectName '/preproc/'];
end

% load original data
% fname                                   = [subject_folder subjectName '_firstCueLock_ICAlean_finalrej.mat'];
% fprintf('\nloading %s\n',fname);
% load(fname);

trial_struct                            = bil_CutEventsIntoTrials(subjectName);

if strcmp(subjectName,'sub004') % some triggers were missing for these trials
    cfg                                 = [];
    cfg.trials                          = [1:380 383:length(data_in.trial)];
    data_in                             = ft_selectdata(cfg,data_in);
elseif strcmp(subjectName,'sub023') % one trigger was missing for these trials
    cfg                                 = [];
    cfg.trials                          = [1:280 282:length(data_in.trial)];
    data_in                             = ft_selectdata(cfg,data_in);
end

trial_struct                            = trial_struct(data_in.trialinfo(:,18),:);

% make sure that trials are matching across the board
fnd                                     = data_in.trialinfo(:,1) - [trial_struct.first_cue_code];
chk                                     = unique(fnd);

if length(chk) > 4
    error('something wrong..');
end

[offset,code]                       	= h_adjustrial(data_in,trial_struct);

cfg                                     = [];
cfg.window                              = new_time_window;

cfg.begsample                           = offset.scnd_cue;
newdata{1}                              = h_redefinetrial(cfg,data_in);
newdata{1}.trialinfo                    = [newdata{1}.trialinfo repmat(1,length(newdata{1}.trialinfo),1) code.scnd_cue];

nd                                      = 1;
data                                    = newdata{nd};