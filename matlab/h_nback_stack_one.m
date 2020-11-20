function new_data = h_nback_stack_one(data)

new_data                             	= data;
new_data                                = rmfield(new_data,'sampleinfo');

new_data.trial                       	= {};
new_data.time                           = {};
new_data.trialinfo                  	= [];

trial_vctor                             = 1:2:length(data.trial);

for nt = 1:length(trial_vctor)
    
    tmp_info                         	= [];
    % find first stim till onset of following one
    lu                                  = trial_vctor(nt);
    ix1                                 = 1;
    ix2                                 = find(round(data.time{lu},3) == round(2,3));
    data_stim1                          = data.trial{lu}(:,ix1:ix2);
    
    tmp_info                            = [tmp_info 1001 data.trialinfo(lu,:)];
    
    % take next stim from onset till next onset
    lu                                  = lu+1;
    ix1                                 = find(round(data.time{lu},3) == round(0,3));
    ix2                                 = length(data.time{lu});% find(round(data.time{lu},2) == round(2.5,2));
    data_stim2                          = data.trial{lu}(:,ix1:ix2);
    
    tmp_info                            = [tmp_info 1002 data.trialinfo(lu,:)];
    
    new_data.trial{nt}                  = [data_stim1 data_stim2];
    
    time_res                            = data.time{nt}(2) - data.time{nt}(1);
    time_axs                            = data.time{nt}(1);
    
    for hi = 2:size(new_data.trial{nt},2)
        time_axs(hi)                    = time_axs(hi-1)+time_res;
    end
    
    new_data.time{nt}                   = time_axs;
    new_data.trialinfo                  = [new_data.trialinfo; tmp_info];
    
end