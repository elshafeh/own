clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

suj_list                                        = [1:33 35:36 38:44 46:51];
allpeaks                                        = [];

for nsuj = 1:length(suj_list)
    load(['J:/temp/nback/data/peak/sub' num2str(suj_list(nsuj)) '.alphabeta.peak.package.mat']);
    allpeaks(nsuj,1)                            = apeak; clear apeak;
    allpeaks(nsuj,2)                            = bpeak; clear bpeak;
end

allpeaks(isnan(allpeaks(:,2)),2)                = nanmean(allpeaks(:,2));

keep suj_list allpeaks

for nsuj = 1:length(suj_list)
    
    subjectname                                 = ['sub' num2str(suj_list(nsuj))];
        
    fname                                       = ['J:/temp/nback/data/source/volgrid/' subjectname '.volgrid.0.5cm.mat'];
    fprintf('\nloading %s\n',fname);
    load(fname);
    
    for nsession = 1:2
        
        fname                               = ['J:/temp/nback/data/nback_' num2str(nsession) '/data_sess' num2str(nsession) '_s' num2str(suj_list(nsuj)) '.mat'];
        fprintf('\nloading %s\n',fname);
        load(fname);
        
        fname                               = ['J:/temp/nback/data/source/lead/' subjectname '.session' num2str(nsession) '.leadfield.0.5cm.mat'];
        fprintf('\nloading %s\n',fname);
        load(fname);
        
        apeak                               = round(allpeaks(nsuj,1));
        com_filter                          = nbk_common_filter(data,leadfield,vol,[-1 2],apeak,1); clc;
        
        list_name                           = {'0back','1back','2back'};
        
        for nc = 1:length(list_name)
            
            cfg                             = [];
            cfg.trials                      = find(data.trialinfo(:,1) == nc+3);
            
            if ~isempty(cfg.trials)
                
                sub_data                    = ft_selectdata(cfg,data);
                list_time                   = [-1 0; 0.3 1.3];
                
                for ntime = 1:size(list_time,1)
                    
                    t1                      = list_time(ntime,1);
                    t2                      = list_time(ntime,2);
                    
                    [source,ext_name]       = nbk_dics_separate(sub_data,leadfield,vol,com_filter,[t1 t2],apeak,1);
                    
                    fname_out               = ['J:/temp/nback/data/source/alpha/' subjectname '.session' num2str(nsession) '.' list_name{nc} '.' ext_name  '.dics.mat'];
                    fprintf('\nsaving %s\n',fname_out);
                    save(fname_out,'source','-v7.3'); clc;
                    
                end
            end
            
        end
    end
end