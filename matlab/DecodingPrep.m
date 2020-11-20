clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));


for sub = 5:21
    
    mat_name        = ['/Volumes/hesham_megabup/pat22_fieldtrip_data/yc' num2str(sub) '.nDT.mat'];
    
    %--
    % load mat file
    %--
    
    fprintf('Loading %s\n',mat_name);
    load(mat_name);
    
    %--
    % select one second ? the target onset
    %--
    
    cfg             = [];
    cfg.latency     = [-1 1];
    data_elan       = ft_selectdata(cfg,data_elan);
    
    dir_out         = ['/Users/heshamelshafei/Dropbox/untitled folder/ADE/raw/sub' num2str(sub) '/'];
    mkdir(dir_out);
    
    %     --
    %     save channel list , type , time axis and events
    %     --
    
    chan_list               = data_elan.label;
    
    for nchan = 1:length(data_elan.label)
        chan_type{nchan}     = 'grad';
    end
    
    time_axis               = data_elan.time{1};
    
    where_zer               = 1:length(data_elan.trialinfo);
    zer_matrix              = zeros(length(data_elan.trialinfo),1);
    
    new_code                = mod((data_elan.trialinfo-3000),10);
    
    data_events             = [where_zer' zer_matrix new_code];
    data_sfreq              = data_elan.fsample;
    
    save([dir_out 'sub' num2str(sub) '.datasetInfo.mat'],'chan_list','chan_type','time_axis','data_sfreq','data_events');
    
    clearvars -except sub dir_out data_elan;
    
    data                    = data_elan.trial;
    data                    = cat(3,data{:});
    data_raw                = permute(data,[3,1,2]); clear data;
    
    %     --
    %     save data by channel ; in order to optimize python reading 
    %     --
    
    for nchan = 1:size(data_raw,2)
        
        fprintf('Loading %s\n',[dir_out 'sub' num2str(sub) '.dataset.chan' num2str(nchan) '.mat']);
        
        data_sub            = data_raw(:,nchan,:);
        
        save([dir_out 'sub' num2str(sub) '.dataset.chan' num2str(nchan) '.mat'],'data_sub');
        
        clear data_sub
        
    end
    
    clearvars -except sub
    
end