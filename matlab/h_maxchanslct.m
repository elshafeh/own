function [max_chan] = h_maxchanslct(avg,modality,time_window,lmt)

max_chan                                        = [];
list_chan                                       = 'LR';

for nhemi   = 1:2
    
    cfg                                         = [];
    cfg.latency                                 = time_window;
    cfg.avgovertime                             = 'yes';
    
    if strcmp(modality,'aud')
        cfg.channel                             = {['M*' list_chan(nhemi) '*T*'],['M*' list_chan(nhemi) '*P*']};
    elseif strcmp(modality,'vis')
        cfg.channel                             = {['M*' list_chan(nhemi) '*O*'],['M*' list_chan(nhemi) '*P*']};
    end
    
    data_avg                                    = ft_selectdata(cfg,avg);
    
    vctr                                        = [[1:length(data_avg.avg)]' data_avg.avg];
    vctr_sort                                   = sortrows(vctr,2,'descend'); % sort from high to low
    
    max_chan                                    = [max_chan;data_avg.label(vctr_sort(1:lmt,1))];
    
end