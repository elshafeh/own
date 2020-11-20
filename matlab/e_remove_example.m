function [new_events,cue]   = e_remove_example(events)

codes.button                = [4 8];
codes.cue                   = [64 128];
codes.stim                  = [1 2];
codes.feedback              = [16 48 80];

cue.good                    = [];
cue.bad                     = [];

big_flag                    = 0;
n                           = 1;

new_events                  = [];
ntrial                      = 0;

while n <= length(events)
    
    chk_cue                 = find(codes.cue == events(n,1));
    
    if ~isempty(chk_cue)
        
        flg                 = 0;
        i                   = n + 1;
        
        while flg == 0 && i <= length(events)% find feddback
            
            chk_feed        = find(codes.cue == events(i,1));
            
            if isempty(chk_feed)
                i           = i + 1;
            else
                flg         = 1;
            end
            
        end
        
        ntrial              = ntrial + 1;
        
        trl                 = [events(n:i-1,:)];
        
        find_resp           = find(trl(:,1) == codes.button);
        find_feed           = find(trl(:,1) == codes.feedback);
        
        if ~isempty(find_feed) % ~isempty(find_resp) && 
            new_events      = [new_events; trl];clear trl;
            cue.good        = [cue.good; ntrial];
        else
            cue.bad         = [cue.bad; ntrial];
        end
        
    end
    
    n                       = n +1;
    
end