clear ; clc;

suj_list                                = {};
for j = 1:9
    suj_list{j,1}                       = ['sub00', num2str(j)];
end
for k = [10:12,17,18,20:37,39]
    j                                   = j+1;
    suj_list{j,1}                       = ['sub0', num2str(k)];
end


for nsuj = 1:length(suj_list)
    
    subjectName                     = suj_list{nsuj};
    
    fname                           = ['P:/3015039.05/data/' subjectName '/source/' subjectName '_volgridLead.0.5cm.withNas.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    fname                           = ['P:/3015039.05/data/' subjectName '/preproc/' subjectName '_StimLock_ICAlean_finalrej.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    fnd_trl                         = find(dataPostICA_clean.trialinfo(:,9) == 1);
    cfg                             = [];
    cfg.trials                      = fnd_trl;
    data                            = ft_selectdata(cfg,dataPostICA_clean); clear fnd_trl;
    %data                            = ft_appenddata([],data_eyes{:}); clear data_eyes;
    
    cfg                            	= [];
    cfg.channel                   	= data.label;
    leadfield                    	= ft_selectdata(cfg,leadfield);

    cfg_f                           = [];
    cfg_f.covariance_window         = [-0.15 0.15];
    cfg_f.leadfield                 = leadfield;
    cfg_f.vol                       = vol;
    spatialfilter                   = h_create_lcmv_common_filter(cfg_f,data);
    
    fnd_trl = find(data.trialinfo(:,6) == 128);
    cfg = [];
    cfg.trials = fnd_trl;
    data_right = ft_selectdata(cfg,data); clear fnd_trl;
    
    fnd_trl = find(data.trialinfo(:,6) == 64);
    cfg = [];
    cfg.trials = fnd_trl;
    data_left = ft_selectdata(cfg,data); clear fnd_trl;
    
    data_conds = {data_right,data_left};
    
    list_time                       = [-0.1 0; 0 0.14]; % windows of interest
    
    for ntime = 1:size(list_time,1)
        
        cfg_s                       = [];
        cfg_s.leadfield             = leadfield;
        cfg_s.vol                   = vol;
        cfg_s.spatialfilter         = spatialfilter;
        cfg_s.time_of_interest      = list_time(ntime,:);
        [source,source_name]        = h_lcmv_separate(cfg_s,data_right);

        fname_out                   = ['P:/3015039.05/data/' subjectName '/source/' subjectName '_somato.' source_name '.lcmvsource.0.5cmWithNas.mat'];
        fprintf('saving %s\n',fname_out);
        %save(fname_out,'source','-v7.3');
        
    end
    
end