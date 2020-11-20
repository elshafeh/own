function new_data = h_transform_data(data,chan_index,chan_list)

for nroi = 1:length(chan_list) 
    
    cfg             = [];
    cfg.avgoverchan = 'yes';
    cfg.channel     = chan_index{nroi};
    tmp{nroi}       = ft_selectdata(cfg,data);
    tmp{nroi}.label = {chan_list{nroi}};
    
end

new_data            = ft_appenddata([],tmp{:});

if isfield(data,'trialinfo')
    new_freq.trialinfo  = data.trialinfo;
end