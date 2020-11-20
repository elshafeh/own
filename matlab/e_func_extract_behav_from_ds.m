function [trl,cue]      = e_func_extract_behav_from_ds(ds_name,bloc_order,bloc_length)

% input : 
% ds_name           : ds file name to read in with directory
% bloc_order        : 8x1 vector with condition -> use 1 for eye-open and 2 for eye-closed
% bloc_length       : 76 (trials) + 4 (example) = 80

% ouput: 7-column table with summary for each trial:
% column1           : trial number 
% column2           : block number
% column3           : block type (1 open , 2 closed)
% column4           : trial isi
% column5           : trial cue
% column6           : target type (1 = low, 2 = high);
% column7           : nb_pulses of target
% column8           : response (1:hit 0:miss -1:incorrect NaN: example)
% column9           : reaction time (example trials contain NaN)

cfg                     = [];
cfg.dataset             = ds_name;
cfg.trialdef.eventtype  = '?';
cfg                     = ft_definetrial(cfg);

% % get the relevant events % %
event = [];

for i=1:length(cfg.event)
    if strcmp(cfg.event(i).type, 'UPPT001')
        event = [event; cfg.event(i).value cfg.event(i).sample];
    end
end


% find first cue after examples
[event,cue]                                     = e_remove_example(event);

% - % get stim onsets :) 
[stim,nb_pulses,resp_summary]                   = e_func_check_full_trial(event);

% % get the cues % %
trl.cue=[];
for i=1:length(event)
    if ismember(event(i,1), [64 128]) % cue onset code
        trl.cue=[trl.cue; event(i,1)];
    end
end

% % get the isi % %
% find the pre-stim interval onsets
prestim=[];
for i=1:length(event)
    if event(i,1)==32 % pre-stim interval
        prestim=[prestim; event(i,2)];
    end
end

trl.n       = [1:length(trl.cue)]'; % [1:(length(bloc_order)*bloc_length)]'; % trial number

nb_blocks   = length(trl.n)/bloc_length;
bloc_order  = bloc_order(1:nb_blocks);

trl.eyes    = [];
for i = 1:length(bloc_order)
    trl.eyes    = [trl.eyes; repmat(i,bloc_length,1) repmat(bloc_order(i),bloc_length,1)];
end

if length(trl.cue)~=trl.n(end), error('trial number disagreement'), end
if length(prestim)~=trl.n(end), error('trial number disagreement'), end
if length(stim)~=trl.n(end), error('trial number disagreement'), end

% isi = stim - prestim
trl.isi = (stim - prestim)/1200;

% % get the responses % %

trl.resp    = [];

for i=1:length(resp_summary)
    
    chk1            = resp_summary(i,1);
    chk2            = resp_summary(i,2);
    
    if chk2 == -1
      trl.resp(i)       = NaN; % example
    elseif chk2 == 16
        trl.resp(i)     = 1;  % hit
    elseif chk2 == 48
        trl.resp(i)     = -1; % incorrect
    elseif chk2 == 80
        trl.resp(i)     = 0;  % no resp
    end
    
end

trl.resp                = trl.resp';

if length(trl.resp)~=trl.n(end), error('trial number disagreement'), end

trl.rt                  = [resp_summary(:,3) - stim] ./ 1200;

% -- classify trials into low/high -- %
stim_list               = unique(nb_pulses);
stim_type               = zeros(length(nb_pulses),1);

stim_type(nb_pulses == stim_list(1))    = 1;
stim_type(nb_pulses == stim_list(2))    = 2;

trl                     = [trl.n trl.eyes trl.isi trl.cue stim_type nb_pulses' trl.resp trl.rt];

% save(['~/project3/data/trl/meglog_', num2str(s)], 'trl')
% keep subnames filenames subs s