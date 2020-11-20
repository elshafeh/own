clear;

% clear;

list_suj                      	= {};
for j = 1:9
    list_suj{j,1}              	= ['sub00', num2str(j)];
end
for k = [10:12,17,18,20:22,24:30]
    j                          	= j+1;
    list_suj{j,1}            	= ['sub0', num2str(k)];
end

keep list_suj

for nsuj = 1:length(list_suj)
    
    suj_name                            = list_suj{nsuj};
    
    for ext_lock = {'stimLock' 'cueLock'}
        
        % load data in
        fname                               = ['I:\eyes\preproc\' suj_name '.' ext_lock{:} '.dwn70.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        
        index                               = data.trialinfo;
        clear data
        
        % Save data
        fname                               = ['I:\eyes\preproc\' suj_name '.' ext_lock{:} '.trialinfo.mat'];
        fprintf('saving %s\n',fname);
        save(fname,'index');
        
    end
end