function nw_trialinfo   = h_create_cuetrialinfo(trialinfo,cue_nb)

nw_trialinfo                = [];
nw_trialinfo                = [nw_trialinfo trialinfo(:,18)]; % add trial number

for nt = 1:length(nw_trialinfo)
    
    nt_task                 = trialinfo(nt,7); % orien-frq
    nt_type                 = trialinfo(nt,8);
    
    nt_order                = [0 0];
    nt_order(nt_type)       = nt_task;
    nt_order(nt_order == 0) = 3;
    
    nt_order                = nt_order(cue_nb);
    
    nw_trialinfo(nt,2)      = nt_order; % cue type (ori-freq-uninf)
    nw_trialinfo(nt,3)      = cue_nb;   % cue order
    nw_trialinfo(nt,4)      = trialinfo(nt,16);   % correct or not
    
end
    
    
