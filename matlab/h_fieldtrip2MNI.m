function h_fieldtrip2MNI(data,sb,dir_out,file_extension)

chan_list              = data.label;

for nchan = 1:length(data.label)
    chan_type{nchan}   = 'grad';
end

time_axis               = data.time{1};

where_zer               = 1:length(data.trialinfo);
zer_matrix              = zeros(length(data.trialinfo),1);

new_code                = mod((data.trialinfo-3000),10);

data_events             = [where_zer' zer_matrix new_code];
data_sfreq              = data.fsample;

save([dir_out 'sub' num2str(sb) '.' file_extension '.datasetInfo.mat'],'chan_list','chan_type','time_axis','data_sfreq','data_events');

data                    = data.trial;
data                    = cat(3,data{:});
data                    = permute(data,[3,1,2]);

for nchan = 1:size(data,2)
    
    fname_out           = [dir_out 'sub' num2str(sb) '.' file_extension '.dataset.chan' num2str(nchan) '.mat'];
    
    fprintf('Saving %s\n',fname_out);
    
    data_sub            = data(:,nchan,:);
    
    save(fname_out,'data_sub');
    
    clear data_sub
    
end