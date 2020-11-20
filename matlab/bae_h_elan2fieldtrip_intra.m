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

tmp = [];

for n = 1:length(infIN.code)
    tmp  = [tmp;pos_orig(pos_orig(:,2) == infIN.code(n),:)]; % takes only trials with chosen codes
    if isempty(tmp)
        disp(['Codes ' num2str(infIN.code(n)) ' not found in .pos file']),
    end
end

pos      = sortrows(tmp,1); clear tmp ;

Fs          = infIN.Fs ;
nsmp_before = Fs * time_pre  ;
nsmp_after  = Fs * time_post - 1 ;

% replace fieldtirp data with elan

data_elan.sampleinfo = [];
data_elan.trial      = {};
data_elan.time       = {};

% data_elan.cfg.trl    = [pos(:,1)-nsmp_before pos(:,1)+nsmp_after repmat(-(Fs*time_pre),size(pos,1),1) pos(:,3)];
data_elan.sampleinfo = [pos(:,1)-nsmp_before pos(:,1)+nsmp_after];

data_elan.trialinfo = pos(:,2);

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

