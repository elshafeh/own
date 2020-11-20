function h_elan2fieldtrip_intra(infIN,time_pre,time_post,infOUT)

% infIN is a struct with these fields:
% eegName : name of elan file
% posName  : name of pos file
% code : codes you want
% time_pre : number of seconds before the event (always positive!)
% time_post : number of seconds after event (always positive!)
% Fs : sampling frequency
%
% infOUT is struct with .name field for the ouput file
%
% require eeg2mat.m
%
% last edit by Bastien 10 Nov 2017


elan_file       = infIN.eegName;
pos_orig        = load(infIN.posName);

% choose events

pos_orig        = pos_orig(pos_orig(:,3)==0,:); % takes only non-rejected events

% pos_orig        = pos_orig(floor(pos_orig(:,2)/1000)==lock,1:2); % locks on a certaing event (cue 1 ; dis 2; target 3; bp 9; fdis 6)
% pos_orig(:,3)   = pos_orig(:,2) - (lock*1000); % gets event code
% pos_orig(:,4)   = floor(pos_orig(:,3)/100); % determines cue condition
% pos_orig(:,5)   = floor((pos_orig(:,3)-100*pos_orig(:,4))/10);     % Determine distractor latency


tmp = [];

for n = 1:length(infIN.code)
    tmp  = [tmp;pos_orig(pos_orig(:,2) == infIN.code(n),:)]; % takes only trials with chosen codes
end

pos         = sortrows(tmp,1); clear tmp ;


% cfg         = [];
% cfg.dataset = infIN.DsName ;
% cfg.channel = 'MEG';
% data_elan   = ft_preprocessing(cfg);

Fs          = infIN.Fs ;
nsmp_before = Fs * time_pre  ;
nsmp_after  = Fs * time_post - 1 ;

% replace fieldtirp data with elan

data_elan.sampleinfo = [];
data_elan.trial      = {};
data_elan.time       = {};

data_elan.cfg.trl    = [pos(:,1)-nsmp_before pos(:,1)+nsmp_after repmat(-(Fs*time_pre),size(pos,1),1) pos(:,3)];
data_elan.sampleinfo = [pos(:,1)-nsmp_before pos(:,1)+nsmp_after];

data_elan.trialinfo = pos(:,2);

% h = waitbar(0,'Converting data...');

for n = 1:size(pos,1)
    
    fprintf('Converting Trials %d out of %d\n',n,size(pos,1))
    
    data_elan.time{n}                   =  [-time_pre:1/Fs:time_post];
    data_elan.time{n}                   =  data_elan.time{n}(1:end-1);
    idx_start                           =  data_elan.sampleinfo(n,1);
    idx_end                             =  data_elan.sampleinfo(n,2);
    [data_elan.trial{n},~,chan_list]    =  eeg2mat(elan_file,idx_start,idx_end,infIN.elan_chan);
    
end

data_elan.label = chan_list;

fprintf('Saving: %s\n',infOUT.name);
save(infOUT.name,'data_elan','-v7.3')
fprintf('%s\n','Done!');

