clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

suj_list                             	= [1:33 35:36 38:44 46:51]; % []
allpeaks                                = [];

for nsuj = 1:length(suj_list)
    
    dir_data                           	= '~/Dropbox/project_me/data/nback/peak/';
    ext_peak                         	= 'alphabeta.peak.package.0back.equalhemi';
    fname_in                         	= [dir_data 'sub' num2str(suj_list(nsuj)) '.' ext_peak '.mat'];
    fprintf('loading %s\n',fname_in);
    load(fname_in);
    
    allpeaks(nsuj,1)                  	= apeak; clear apeak;
    allpeaks(nsuj,2)                    = bpeak; clear bpeak;
    
end

for nsuj = 1:length(suj_list)
    
    subjectname                     	= ['sub' num2str(suj_list(nsuj))];
    
    load(['~/Dropbox/project_me/data/nback/grad_orig/grad' num2str(suj_list(nsuj)) '.mat']);
    
    dir_data                            = '~/Dropbox/project_me/data/nback/source/';
    fname                               = [dir_data 'volgrid/' subjectname '.volgrid.0.5cm.mat'];
    fprintf('\nloading %s\n',fname);
    load(fname);
    
    % load leadfield
    fname                               = [dir_data 'lead/sub' num2str(suj_list(nsuj)) '.combined.leadfield.0.5cm.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    for nsess = [1 2]
        
        fname                           = ['~/Dropbox/project_me/data/nback/prepro/nback_' num2str(nsess) '/data_sess' num2str(nsess) '_s' num2str(suj_list(nsuj)) '.mat'];
        fprintf('\nloading %s\n',fname);
        load(fname);
        
        cfg                             = [];
        cfg.trials                      = find(data.trialinfo(:,5) == 0 & data.trialinfo(:,1) ~= 4 & mod(data.trialinfo(:,6),2) ~= 0);
        tmp{nsess}                      = ft_selectdata(cfg,data);clear data;
        
    end
    
    % add grad info to make ft_sourcecompute happ
    data                                = ft_appenddata([],tmp{:}); clear tmp;
    data.grad                           = grad;
    
    cfg                                 = [];
    cfg.channel                         = data.label;
    leadfield                           = ft_selectdata(cfg,leadfield);
    
    list_freq                           = {'alpha' 'beta'};
    vct_freq                            = round(allpeaks(nsuj,:));
    vct_smooth                          = [1 2];
    
    vct_time                            = [0.8 1.5; 1.7 1.9; 0.2 2; 0.6 1.1];
    
    % first go by time window
    for ntime = 1:size(vct_time,1)
        
        t1                            	= vct_time(ntime,1);
        t2                              = vct_time(ntime,2);
        
        % then by frequency
        for nfreq = 1:length(vct_freq)
            
            f_focus                  	= vct_freq(nfreq);
            f_smooth                  	= vct_smooth(nfreq);
            
            % create common filter
            com_filter                  = nbk_common_filter(data,leadfield,vol,[t1 t2],allpeaks(nsuj,1),1); % alpha [+/- 1Hz]
            
            % separate for each condition
            for nback = [1 2]
                
                cfg                  	= [];
                cfg.trials            	= find(data.trialinfo(:,1) == nback + 4);
                sub_data              	= ft_selectdata(cfg,data);
                
                [source,ext_name]       = nbk_dics_separate(sub_data,leadfield,vol,com_filter,[t1 t2],f_focus,f_smooth);
                
                fname_out               = ['~/Dropbox/project_me/data/nback/source/load/' subjectname '.' num2str(nback) 'back.'];
                fname_out               = [fname_out 'allstim.' list_freq{nfreq} '.' ext_name  '.dicsCombined.mat'];
                fprintf('\nsaving %s\n',fname_out);
                save(fname_out,'source','-v7.3');
                
            end
        end
    end
end