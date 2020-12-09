function cfg_out = taco_func_addbehav(subjectName,cfg_in,hdr,events)

cfg_out                     = cfg_in;

if ispc
    start_dir               = 'D:/Dropbox/project_me/data/taco/';
else
    start_dir               = '~/Dropbox/project_me/data/taco/';
end

behav_dir                   = [start_dir 'behav/']; 
fname                       = [behav_dir subjectName '_taco_meg_block_Logfile.mat'];
load(fname);

allInfo                     = Info.TrialInfo;
cfg_out.info.block          = allInfo;

trialinfo                   = [];
trialinfo                   = [trialinfo [allInfo.samp1]]; % 1 2
trialinfo                   = [trialinfo [allInfo.samp2]]; % 3 4
trialinfo                   = [trialinfo [allInfo.target]]; % 5 6
trialinfo                   = [trialinfo [allInfo.cue]]; % 7
trialinfo                   = [trialinfo [allInfo.attend]]; % 8
trialinfo                   = [trialinfo [allInfo.ismatch]]; % 9
trialinfo                   = [trialinfo [allInfo.mapping]]; % 10
trialinfo                   = [trialinfo [allInfo.crit_soa]]; % 11
trialinfo                   = [trialinfo [allInfo.nbloc]]; % 12

for nt = 1:height(allInfo)
    
    trl_repRT               = cell2mat(allInfo(nt,:).repRT);
    trl_button            	= cell2mat(allInfo(nt,:).repButton);
    trl_correct          	= cell2mat(allInfo(nt,:).repCorrect);
    
    if isempty(trl_repRT)
        trl_repRT           = NaN;
    end
    if isempty(trl_button)
        trl_button           = NaN;
    end
    if isempty(trl_correct)
        trl_correct           = NaN;
    end
    
    trialinfo(nt,13)        = trl_repRT; clear trl_repRT;
    trialinfo(nt,14)        = trl_button;clear trl_button;
    trialinfo(nt,15)        = trl_correct; clear trl_correct;
    
    list_block              = {'early' 'late' 'jittered'};
    
    
    
end

good_events                 = [];
i                           = 0;

for nt = 1:length(events)
    if ~isempty(events(nt).value)
        if strcmp(events(nt).type,'UPPT001') || strcmp(events(nt).type,'UPPT002')
            good_events     = [good_events; events(nt).value events(nt).sample];
        end
    end
end

good_trials                 = [];
good_rt                     = [];
good_soa                    = [];

for nt = 1:length(good_events)
    
    if ismember(good_events(nt,1),[111   112   121   122])
        
        flg     = 0 ;
        ii      = 1;
        
        while flg == 0 
            
            chk     = good_events(nt+ii,1);
            
            if ismember(chk,[111   112   121   122]) || ismember(chk,[251])
                
                a               = nt;
                b               = nt+ii -1;
                trl             = good_events(a:b,:);
                
                chk_samp1       = find(ismember(trl(:,1),[11 12]));
                chk_samp2       = find(ismember(trl(:,1),[21 22]));
                chk_samp3       = find(ismember(trl(:,1),[31 32]));
                chk_cue2        = find(ismember(trl(:,1),[211   212   221   222]));
                chk_window    	= find(ismember(trl(:,1),[77]));
                
                if ~isempty(chk_samp1)  && ~isempty(chk_samp2) && ~isempty(chk_samp3) && ~isempty(chk_cue2) && ~isempty(chk_window)
                    good_trials = [good_trials; trl];
                    good_rt    	= [good_rt (trl(7,2)-trl(6,2))./hdr.Fs];
                    good_soa  	= [good_soa (trl(5,2)-trl(4,2))./hdr.Fs]; clear trl;
                else
                    ix          = 0;
                end
                    flg = 1;
                
            else
                ii = ii + 1;
            end
        end
    end
end

keep good_* cfg_* trialinfo subjectName events hdr *_dir

if strcmp(subjectName,'tac001') % had two extra trials in the beginning
    good_trials     = good_trials(15:end,:);
    good_soa        = good_soa(3:end);
    good_rt         = good_rt(3:end);
end

if (length(good_soa) ~= length(trialinfo)) || (length(good_rt) ~= length(trialinfo))
    error('trials dont match between ctf and psychtoolbox!!');
else
    disp('trial count match!');
end

trigger_indices{1} = [111   112   121   122];
trigger_indices{2} = [11 12];
trigger_indices{3} = [21 22];
trigger_indices{4} = [211   212   221   222];
trigger_indices{5} = [31 32];
trigger_indices{6} = 77;
trigger_indices{7} = [1 8];

for i = 1:length(trigger_indices)
    
    flg             = [];
    
    for y = 1:length(good_trials)
        if ismember(good_trials(y,1),trigger_indices{i})
            flg     = [flg;y];
        end
    end
    
    good_segments{i}    = good_trials(flg,:);
    
end

% tripple make sure that trialinfo and ctf-trigger match

for nt = 1:length(good_segments{1})
    
    cue_ctf         = good_segments{1}(nt);
    cue_psych       = 100 + trialinfo(nt,7)*10 + trialinfo(nt,8);
    
    if cue_ctf ~=  cue_psych
        error('trial codes do NOT match');
    end
    
end

% now match the trl matrices!

for i = 1:length(cfg_out.trl)-1
    
    samples_ideal   = good_segments{i}(:,2);
    samples_all     = cfg_out.trl{i}(:,1) + abs(cfg_out.trl{i}(:,3));
    
    samples_keep  	= [];
    
    for yi = 1:length(samples_all)
        if ismember(samples_all(yi),samples_ideal)
            samples_keep     = [samples_keep;yi];
        end
    end
    
    if i < 7
        cfg_out.trl{i}  = [cfg_out.trl{i}(samples_keep,:) trialinfo [1:length(trialinfo)]'];
    else
    
        flg             = find(~isnan(trialinfo(:,14)));
        new_trialinfo   = trialinfo(flg,:);
        cfg_out.trl{i}  = [cfg_out.trl{i}(samples_keep,:) new_trialinfo flg];
    end
end

behav_dir                   = [start_dir 'behav/']; 
fname                       = [behav_dir subjectName '_taco_meg_loca.mat'];
load(fname);

allInfo                     = Info.TrialInfo;
cfg_out.info.loca           = allInfo;

trialinfo                   = [];
trialinfo                   = [trialinfo [allInfo.samp]]; % 1 2
trialinfo                   = [trialinfo [allInfo.color]]; % 3
trialinfo                   = [trialinfo [allInfo.sampClass]]; % 4
trialinfo                   = [trialinfo [allInfo.ISI]]; % 5

if length(cfg_out.trl{8}) ~= length(trialinfo)
    error('localizer trial count does not match!');
else
    cfg_out.trl{8}          = [cfg_out.trl{8} trialinfo [1:length(trialinfo)]'];
end

cfg_out.good_trials        	= good_trials;