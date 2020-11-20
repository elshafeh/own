function data   = h_addblocknumber(old_data)

% add # block to trialinfo by detecting trial-by-trial
% changes in condition - indexed by first column
% 4 = 0back , 5 = 1 back and 6 = 2back;

data                                    = old_data;

nblock                                  = 1;
data.trialinfo(1,10)                    = nblock;

for nt = 2:length(data.trialinfo)
    
    x                                   = data.trialinfo(nt,1);
    y                                   = data.trialinfo(nt-1,1);
    
    if (x-y) == 0
        nblock                          = nblock;
    else
        nblock                          = nblock+1;
    end
    
    data.trialinfo(nt,10)               = nblock;
    
end