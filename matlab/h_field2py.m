function h_field2py(data_in,file_name_out)

data                = data_in.trial;
data                = cat(3,data{:});
data_raw            = permute(data,[3,1,2]); clear data;

data_ch_names       = data_in.label;

for nchan = 1:length(data_ch_names)
    data_ch_type{nchan}     = 'grad';
end


data_time_axe       = data_in.time{1};

where_zer           = find(round(data_time_axe,4) == round(0,4));
where_zer           = 1:length(data_in.trialinfo); % repmat(where_zer,length(data_in.trialinfo),1);

zer_matrix          = zeros(length(data_in.trialinfo),1);

data_events         = [where_zer' zer_matrix data_in.trialinfo];
data_sfreq          = data_in.fsample;

save(file_name_out,'data_raw','data_ch_names','data_ch_type','data_events'... 
    ,'data_sfreq','data_time_axe');