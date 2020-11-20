function cfg = h_addbehavior(subjectName,cfg)

% exctracts behavior form .log files and 
% copies that into data.trialinfo

if ispc
    start_dir = 'P:\';
    file_list   = dir([start_dir '3015079.01/meg_data/' subjectName '/*mat']);
    for nfile = 1:length(file_list)
        copyfile([file_list(nfile).folder filesep file_list(nfile).name],[start_dir '3015079.01/data/' subjectName '/log/' filesep file_list(nfile).name]);
    end
else
    start_dir = '/project/';
    system(['cp /project/3015079.01/meg_data/' subjectName '/*mat /project/3015079.01/data/' subjectName '/log/.']);
end

fname           = [start_dir '/3015079.01/data/' subjectName '/log/' subjectName '_JYcent_block_Logfile.mat'];
load(fname)

ix_stop         = cell2mat(Info.TrialInfo.repButton);
allInfo         = Info.TrialInfo(1:length(ix_stop),:);

h_plotbehavior(allInfo);

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

for ntrial = 1:length(trialinfo)
    what_block                  = trialinfo(ntrial,12);
    trialinfo(ntrial,16)        = Info.MappingList(what_block); clear what_block; % 16
end

if strcmp(subjectName,'sub004')
    nw                          = [trialinfo(1:440,:) ; trialinfo(442:end,:)];
    trialinfo                   = nw;
end

% - % this part removes trials IF trigger was not sent in CTF system

dbl_chk                         = trialinfo(:,[7 6]);
dbl_chk(:,3)                    = 0;

dbl_chk(dbl_chk(:,1) == 1 & dbl_chk(:,2) == 1,3)    = 11;
dbl_chk(dbl_chk(:,1) == 1 & dbl_chk(:,2) == 2,3)    = 12;
dbl_chk(dbl_chk(:,1) ~= 1 ,3)                       = 13;

if length(trialinfo) ~= length(cfg.trl)
    
    miss_trig                   = [];
    
    for n = 1:length(cfg.trl)
        if cfg.trl(n,4) ~= dbl_chk(n,3)
            miss_trig           = [miss_trig;n];
        end
    end
    
    trialinfo(miss_trig(1),:)   = [];
    
end

trialinfo       = [trialinfo [1:length(trialinfo)]']; % 17

% - % this part removes trials IF trigger was not sent in CTF system

cfg.trl         = [cfg.trl trialinfo];