function miss_trig = h_checkchangelock(subjectName,trial_struct)

if ~ispc
    system(['cp /project/3015079.01/meg_data/' subjectName '/*mat /project/3015079.01/data/' subjectName '/log/.']);
end

if ~ispc
    fname     	= ['/project/3015079.01/data/' subjectName '/log/' subjectName '_JYcent_block_Logfile.mat'];
else
    fname     	= ['P:/3015079.01/data/' subjectName '/log/' subjectName '_JYcent_block_Logfile.mat'];
end

load(fname)

ix_stop         = cell2mat(Info.TrialInfo.repButton);
allInfo         = Info.TrialInfo(1:length(ix_stop),:);

trialinfo       = [];
trialinfo       = [trialinfo [allInfo.target]]; % 1 2
trialinfo       = [trialinfo [allInfo.probe]]; % 3 4
trialinfo       = [trialinfo [allInfo.match]]; % 5
trialinfo       = [trialinfo [allInfo.task]]; % 6
trialinfo       = [trialinfo [allInfo.cue]]; % 7
trialinfo       = [trialinfo [allInfo.DurTar]]; % 8
trialinfo       = [trialinfo [allInfo.MaskCon]]; % 9
trialinfo       = [trialinfo [allInfo.DurCue]]; % 10
trialinfo       = [trialinfo [allInfo.color]]; % 11
trialinfo       = [trialinfo [allInfo.nbloc]]; % 12
trialinfo       = [trialinfo cell2mat([allInfo.repRT])]; % 13
trialinfo       = [trialinfo cell2mat([allInfo.repButton])]; % 14
trialinfo       = [trialinfo cell2mat([allInfo.repCorrect])]; % 15

if strcmp(subjectName,'sub004')
    nw                          = [trialinfo(1:440,:) ; trialinfo(442:end,:)];
    trialinfo                   = nw;
end

trialinfo       = [trialinfo [1:length(trialinfo)]']; % 17

% - % this part removes trials IF trigger was not sent in CTF system

dbl_chk                         = trialinfo(:,[7 6]);
dbl_chk(:,3)                    = 0;

dbl_chk(dbl_chk(:,1) == 1 & dbl_chk(:,2) == 1,3)    = 11;
dbl_chk(dbl_chk(:,1) == 1 & dbl_chk(:,2) == 2,3)    = 12;
dbl_chk(dbl_chk(:,1) ~= 1 ,3)                       = 13;

if length(trialinfo) ~= length(trial_struct)
    
    miss_trig                   = [];
    
    for n = 1:min(length(trial_struct),length(trialinfo))
        if trial_struct(n,2) ~= dbl_chk(n,3)
            miss_trig           = [miss_trig;n];
        end
    end
    
end

miss_trig                       = miss_trig(1);