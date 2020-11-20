function h_field2py_decode(data_in,file_name_out)

chan_list               = data_in.label;

for nchan = 1:length(data_in.label)
    chan_type{nchan}     = 'grad';
end

time_axis               = data_in.time{1};

where_zer               = 1:length(data_in.trialinfo);
zer_matrix              = zeros(length(data_in.trialinfo),1);

new_code                = floor((data_in.trialinfo-1000)/100);
% new_code                = mod((data_in.trialinfo-1000),10);

data_events             = [where_zer' zer_matrix new_code];
data_sfreq              = data_in.fsample;

save([file_name_out '.datasetInfo.mat'],'chan_list','chan_type','time_axis','data_sfreq','data_events');

data                    = data_in.trial;
data                    = cat(3,data{:});
data_raw                = permute(data,[3,1,2]); clear data;

for nchan = 1:size(data_raw,2)
    
    fprintf('saving %s\n',[file_name_out '.dataset.chan' num2str(nchan) '.mat']);
    
    data_sub            = data_raw(:,nchan,:);
    
    save([file_name_out '.dataset.chan' num2str(nchan) '.mat'],'data_sub');
    
    clear data_sub
    
end