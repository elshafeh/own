function [data_out,list_out] = taco_redefinetrial(cfg_in,clean_cfg,data_orig)

i                               = 0;

for nlock = cfg_in.list_lock
    
    i                           = i + 1;
    origtrials              	= data_orig.trialinfo(:,end);
    keeptrials                  = [];
    slctrials                   = [];
    
    for ntrial = 1:length(origtrials)
        flg                     = find(clean_cfg.trl{nlock}(:,end) == origtrials(ntrial));
        if ~isempty(flg)
            keeptrials        	= [keeptrials;flg];
            slctrials        	= [slctrials;ntrial];
        end
    end
    
    if length(origtrials) ~= length(slctrials)
        
        cfg                     = [];
        cfg.trials              = slctrials;
        data_in                 = ft_selectdata(cfg,data_orig);
        
        % if some triggers went missing
        mtrx                    = data_in.trialinfo(:,end);
        ref_point             	= clean_cfg.trl{1}(mtrx,1) + abs(clean_cfg.trl{1}(mtrx,3));
        trl_index             	= clean_cfg.trl{nlock}(keeptrials,:);
        
    end
    
    
    distance_sample             = (trl_index(:,1)+abs(trl_index(:,3))) - ref_point; 
    distance_time               = distance_sample ./ clean_cfg.orig_fsample;
    distance_resampled          = round(distance_time .* data_in.fsample);
    
    current_zero                = data_in.sampleinfo(:,1)   + (abs(data_in.time{1}(1)) .* data_in.fsample);
    new_event_zero              = current_zero + distance_resampled;
    
    beg_sample                  = new_event_zero - (cfg_in.prestim.*data_in.fsample);
    end_sample                  = new_event_zero + (cfg_in.poststim.*data_in.fsample);
    
    neg_sample                  = -(cfg_in.prestim.*data_in.fsample);
    neg_sample                  = repmat(neg_sample,length(beg_sample),1);
    
    new_trl                     = [beg_sample end_sample neg_sample trl_index(:,4)];
    
    cfg                         = [];
    cfg.trl                     = new_trl;
    redefinedata                = ft_redefinetrial(cfg, data_in);
    redefinedata.trialinfo      = [redefinedata.trialinfo trl_index(:,5:end)];
    
    data_out{i}                 = redefinedata;
    list_out{i}                 = clean_cfg.list{nlock};
    
    keep i nlock clean_cfg data_out data_orig cfg_in list_out 
    
end
