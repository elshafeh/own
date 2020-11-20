clear;

suj_list                    = {'sub003'};

for n = 1:length(suj_list)
    
    suj                     = suj_list{n};
    
    dir_data                = ['../data/' suj '/preproc/'];
    
    fname                   = [dir_data suj '_gratingLock_dwnsample100Hz.mat'];
    fprintf('Loading %s\n',fname);
    load(fname);
    
    confound_data           = data; clear data;
    
    fname                   = [dir_data suj '_gratingLock_hc_data.mat'];
    fprintf('Loading %s\n',fname);
    load(fname);
    
    data                    = h_remove_hc_confound(headpos,confound_data); clear headpos;
    
    confound_data.trial     = data.trial;
    data                    = confound_data;
    
    clear confound_data headpos;
    
    fname                   = [dir_data suj '_gratingLock_dwnsample100Hz_headincorp.mat'];
    fprintf('Saving %s\n',fname);
    save(fname,'data','-v7.3');
    
end