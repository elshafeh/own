function data = bil_changelock_onlyresp(subjectName,new_time_window,data_in)

if isunix
    project_dir = '/project/3015079.01/';
else
    project_dir = 'P:/3015079.01/';
end

dir_data                                = [project_dir 'data/' subjectName '/preproc/'];

% fname                                   = [dir_data subjectName '_firstCueLock_ICAlean_finalrej.mat'];
% fprintf('Loading %s\n',fname);
% load(fname);

fname                                   = [dir_data subjectName '_allTrialInfo.mat'];
fprintf('Loading %s\n',fname);
load(fname);

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
chk                                     = unique(data_in.trialinfo(:,1) - [trial_struct.first_cue_code]);

if length(chk) > 1
    error('something wrong');
end

[offset,code]                           = h_adjustrial(data_in,trial_struct);

cfg                                     = [];
cfg.window                              = new_time_window;
cfg.begsample                           = offset.response;
[data,keep_trial]                       = h_redefinetrial_response(cfg,data_in);

data.trialinfo                          = [data.trialinfo repmat(1,length(data.trialinfo),1) code.response(keep_trial)];