clear ; clc; close all;

for ns = [1:33 35:36 38:44 46:51]
    
    for nses = 1:2
        
        subjectname                                 = ['s' num2str(ns)];
        fname                                       = ['../data/erf/data_sess' num2str(nses) '_' subjectname '_erfComb.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        
        tmp{nses}                                   = avg_comb; clear avg_comb;
        
    end
    
    avg                                             = ft_timelockgrandaverage([],tmp{:}); clear tmp;
    
    time_window                                     = [0.05 0.2];
    
    cfg                                             = [];
    cfg.latency                                     = time_window;
    cfg.avgovertime                                 = 'yes';
    data_avg                                        = ft_selectdata(cfg,avg); clear avg;
    
    vctr                                            = [[1:length(data_avg.avg)]' data_avg.avg];
    vctr_sort                                       = sortrows(vctr,2,'descend'); % sort from high to low
    
    lmt                                             = 10; % number of channels to take
    
    max_chan                                        = data_avg.label(vctr_sort(1:lmt,1));
    
    % adapt name of file accroding to time-window chosen
    ext_time                                        = ['p' num2str(round(time_window(1)*1000))];
    ext_time                                        = [ext_time 'p' num2str(round(time_window(2)*1000)) 'ms.postonset'];
    
    fname_out                                       = ['../data/peak/' subjectname '.max' num2str(lmt) 'chan.' ext_time '.mat'];
    fprintf('saving %s\n\n',fname_out);
    
    save(fname_out,'max_chan');
    
    keep ns
    
end


