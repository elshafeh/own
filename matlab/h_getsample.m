function [sample_diff] = h_getsample(subjectName,new_lock)

switch new_lock
    case 'target'
        lock_2              = 3;
    case 'button'
        lock_2              = 9;
end

pos_in                      = load(['~/Dropbox/project_me/data/pam/pos/' subjectName '.pat22.rec.behav.fdis.bad.epoch.rej.fin.fdis.pos']);
pos_in                      = pos_in(pos_in(:,3) == 0,[1 2]);
pos_in(:,3)                 = floor(pos_in(:,2) / 1000);

pos_in                      = pos_in(pos_in(:,3) == 1 | pos_in(:,3) == lock_2,:); % keep targets and presses

pos_in(:,4)                 = pos_in(:,2) - pos_in(:,3)*1000; % get code
pos_in(:,5)                 = floor(pos_in(:,4)/100); % get cue
pos_in(:,6)                 = floor((pos_in(:,4)-100*pos_in(:,5))/10); % dis
pos_in(:,7)                 = mod(pos_in(:,4),10); % target

pos_in                      = pos_in(pos_in(:,6) == 0,:); % keep no dis only

% choose cues and responses within same trial
pos_final                   = [];

for n = 1:length(pos_in)
    if pos_in(n,3) == 1 && pos_in(n+1,3) == lock_2
        if pos_in(n,4) == pos_in(n+1,4)
            pos_final       = [pos_final;pos_in(n:n+1,:)];
        end
    end
end

% get samples of cue and response
sample_cue                  = pos_final(pos_final(:,3) == 1,1);
sample_response             = pos_final(pos_final(:,3) == lock_2,1);

sample_diff                 = sample_response - sample_cue;