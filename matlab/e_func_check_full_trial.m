function [stim,nb_pulses,resp_summary]  = e_func_check_full_trial(events)

codes.button                = [4 8];
codes.cue                   = [64 128];
codes.stim                  = [1 2];
codes.feedback              = [16 48 80];

% 32 is fixation

ntrial                      = 0;
trl_tot                     = {};
stim                        = [];

nb_pulses                   = [];
resp_summary                = [];

for n = 1:length(events)
    
    chk_cue                 = find(codes.cue == events(n,1));
    
    if ~isempty(chk_cue)
        
        flg                 = 0;
        i                   = n + 1;
        ntrial              = ntrial+1;
        
        while flg == 0 && i <= length(events)% find feddback
            
            chk_feed        = find(codes.feedback == events(i,1));
            
            if isempty(chk_feed)
                i           = i + 1;
            else
                flg         = 1;
            end
            
        end
        
        trl                 = [events(n:i,:)];
        stim_on             = find(ismember(trl(:,1),[1 2]));
        
        if ~isempty(stim_on)
            stim            = [stim;trl(stim_on(end),2)]; % ! ! 
            nb_pulses       = [nb_pulses length(stim_on)];
        end
        
        trl_tot{ntrial,1}   = trl;
        trl_tot{ntrial,2}   = length(trl_tot{ntrial,1});
        
        on_resp             = find(ismember(trl(:,1),codes.button));
        on_feed             = find(ismember(trl(:,1),codes.feedback));
        
        if isempty(on_resp) || length(on_resp) > 1
            on_resp         = -1;
            time_stamp      = NaN;
        else
            time_stamp      = trl(on_resp,2);
            on_resp         = trl(on_resp,1);
        end
        
        if isempty(on_feed)
            on_feed         = -1;
        else
            on_feed         = trl(on_feed,1);
        end
        
        resp_summary        = [resp_summary; on_resp on_feed time_stamp];
        
    end
end