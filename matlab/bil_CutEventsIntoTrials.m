function trial_struct = bil_CutEventsIntoTrials(subjectName)

if isunix
    project_dir = '/project/3015079.01/';
else
    project_dir = 'P:/3015079.01/';
end

if strcmp(subjectName,'sub007')
    dir_data            = '/home/mrphys/hesels/';
elseif strcmp(subjectName,'sub037')
    dir_data         	= [project_dir 'raw/sub-037/ses-meg01/meg/'];
else
    dir_data            = [project_dir 'raw/'];
end

dsFileName              = dir([dir_data subjectName '*.ds']);
dsFileName              = [dsFileName.folder '/' dsFileName.name];

flg_sep                 = strfind(dsFileName,'\');
if ~isempty(flg_sep)
    dsFileName(flg_sep) = '/';
end

allevents               = ft_read_event(dsFileName,'headerformat','ctf_old','dataformat','ctf_old');
hdr                     = ft_read_header(dsFileName,'headerformat','ctf_old','dataformat','ctf_old');

tmp                     = [];

% remove front-pannel triggers
for nt = 1:length(allevents)
    if strcmp(allevents(nt).type,'UPPT001') || strcmp(allevents(nt).type,'UPPT002')
        tmp             = [tmp;allevents(nt)];
    end
end

allevents               = tmp; clear tmp;

trial_struct            = [];
ntrial                  = 0;

for nt = 1:length(allevents)
    
    if ismember(allevents(nt).value,[11 12 13])
        
        ntrial          = ntrial + 1;
        flg             = 0;
        jmp             = 1;
        
        while flg == 0
            if (ismember(allevents(nt+jmp).value,[11 12 13])) || (nt+jmp == length(allevents))
                flg     = 1;
            else
                jmp     = jmp+1;
            end
        end
        
        trl                         = allevents(nt:nt+jmp-1);
        
        ix                          = find(ismember([trl.value],[11 12 13]));
        trl_info.first_cue_code     = trl(ix).value;
        trl_info.first_cue_smpl     = trl(ix).sample;
        
        ix                          = find(ismember([trl.value],[21 22 23]));
        
        if isempty(ix)
            trl_info.secnd_cue_code     = 0;
            trl_info.secnd_cue_smpl     = 0;
        else
            trl_info.secnd_cue_code     = trl(ix).value;
            trl_info.secnd_cue_smpl     = trl(ix).sample;
        end
        
        ix                          = find(ismember([trl.value],[111   112   113   114 121   122   123   124]));
        
        if isempty(ix)
            trl_info.first_gab_code = 0; % on very rare occasions triggers were missing
            trl_info.first_gab_smpl = 0;
        else
            trl_info.first_gab_code = trl(ix).value;
            trl_info.first_gab_smpl = trl(ix).sample;
        end
        
        ix                          = find(ismember([trl.value],[211   212   213   214 221   222   223   224]));
        
        if isempty(ix)
            trl_info.secnd_gab_code     = 0;
            trl_info.secnd_gab_smpl     = 0;
        else
            trl_info.secnd_gab_code     = trl(ix).value;
            trl_info.secnd_gab_smpl     = trl(ix).sample;
        end
        
        ix                          = find(ismember([trl.value],[1 8]));
        
        if isempty(ix)
            trl_info.response_code  = 0; % on very rare occasions triggers were missing OR subject pressed wrong button
            trl_info.response_smpl  = 0;
        else
            trl_info.response_code  = trl(ix).value;
            trl_info.response_smpl  = trl(ix).sample;
        end
        
        trl_info.Fs                 = hdr.Fs;
        trl_info.nt                 = ntrial;
        
        trial_struct                = [trial_struct; trl_info]; 
        
        keep nt allevents hdr dir_data subjectName ntrial trial_struct project_dir
        
    end
end

if strcmp(subjectName,'sub029')
    miss_trig                           = h_checkchangelock(subjectName,[[trial_struct.nt]' [trial_struct.first_cue_code]']);
    trial_struct                        = struct2table(trial_struct);
    trial_struct(miss_trig,:)           = [];
else
    trial_struct                        = struct2table(trial_struct);
end

save([project_dir 'data/' subjectName '/preproc/' subjectName '.eventsIntoTrial.mat'],'trial_struct');