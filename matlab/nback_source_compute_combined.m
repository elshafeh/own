clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

suj_list                             	= [1:33 35:36 38:44 46:51]; % [] 
allpeaks                                = [];

for nsuj = 1:length(suj_list)
    load(['J:/nback/peak/sub' num2str(suj_list(nsuj)) '.alphabeta.peak.package.mat']);
    allpeaks(nsuj,1)                  	= apeak; clear apeak;
    allpeaks(nsuj,2)                    = bpeak; clear bpeak;
end

allpeaks(isnan(allpeaks(:,2)),2)    	= nanmean(allpeaks(:,2));

keep suj_list allpeaks

for nsuj = 1:length(suj_list)
    
    subjectname                     	= ['sub' num2str(suj_list(nsuj))];
    
    load(['J:/nback/grad_orig/grad' num2str(suj_list(nsuj)) '.mat']);
    
    fname                               = ['J:/nback/source/volgrid/' subjectname '.volgrid.0.5cm.mat'];
    fprintf('\nloading %s\n',fname);
    load(fname);
    
    % load leadfield
    fname                               = ['J:/nback/source/lead/sub' num2str(suj_list(nsuj)) '.combined.leadfield.0.5cm.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    for nsess = [1 2]
        fname                           = ['J:/nback/nback_' num2str(nsess) '/data_sess' num2str(nsess) '_s' num2str(suj_list(nsuj)) '.mat'];
        fprintf('\nloading %s\n',fname);
        load(fname);
        
        cfg                             = [];
        cfg.trials                      = find(data.trialinfo(:,5) == 0);
        tmp{nsess}                      = ft_selectdata(cfg,data);clear data;
        
    end
    
    data                                = ft_appenddata([],tmp{:}); clear tmp;
    data.grad                           = grad;
    
    cfg                                 = [];
    cfg.channel                         = data.label;
    leadfield                           = ft_selectdata(cfg,leadfield);
    
    vct_stim                            = [2];
    vct_freq                            = round([allpeaks(nsuj,1)]);
    vct_smooth                          = [1];
    vct_filter                          = [1];
    
    vct_time{1}                         = [-0.48 -0.2; 0.72 1]; % alpha target
    
    % create 3 common filters for 3 frequencies
    com_filter{1}                       = nbk_common_filter(data,leadfield,vol,[-1 2],allpeaks(nsuj,1),1); % alpha [+/- 1Hz]
    %     com_filter{1}                       = nbk_common_filter(data,leadfield,vol,[-1 2],5,1); % theta [4 - 6 Hz]
    %     com_filter{3}                       = nbk_common_filter(data,leadfield,vol,[-1 2],allpeaks(nsuj,2),2); % beta [[+/- 2Hz]
    
    list_cond                           = {'1back','2back'};
    list_back                           = [5 6];
    list_stim                           = {'target'};
    list_freq                           = {'alpha'};
    
    for nc = 1:length(list_cond)
        
        cfg                             = [];
        cfg.trials                      = find(data.trialinfo(:,1) == list_back(nc));
        sub_data                        = ft_selectdata(cfg,data);
        
        for nfreq = 1:length(vct_stim)
            for ntime = 1:size(vct_time{nfreq},1)
                
                t1                      = vct_time{nfreq}(ntime,1);
                t2                      = vct_time{nfreq}(ntime,2);
                
                f_filter                = com_filter{vct_filter(nfreq)};
                f_focus                 = vct_freq(nfreq);
                f_smooth                = vct_smooth(nfreq);
                
                [source,ext_name]       = nbk_dics_separate(sub_data,leadfield,vol,f_filter,[t1 t2],f_focus,f_smooth);
                
                fname_out               = ['J:/nback/source/combined/' subjectname '.' list_cond{nc} '.'];
                fname_out               = [fname_out list_stim{nfreq} '.' list_freq{nfreq} '.' ext_name  '.dicsCombined.mat'];
                fprintf('\nsaving %s\n',fname_out);
                save(fname_out,'source','-v7.3');
                
            end
        end
    end
end