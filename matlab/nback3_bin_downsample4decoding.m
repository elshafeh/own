clear ; close all; global ft_default
ft_default.spmversion = 'spm12';

suj_list                                    = [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    subjectname                             = ['sub' num2str(suj_list(nsuj))];
    
    % load peak
    fname                                   = ['/Volumes/heshamshung/nback/peak/' subjectname '.alphabeta.peak.package.0back.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    allpeaks(nsuj,1)                        = 3;
    allpeaks(nsuj,2)                        = apeak; clear apeak;
    allpeaks(nsuj,3)                        = bpeak; clear bpeak;
    allpeaks(nsuj,4)                        = 50;
    allpeaks(nsuj,5)                        = 70;
    
    where_beta                              = 3;
    
end

allpeaks(isnan(allpeaks(:,where_beta)),where_beta) 	= round(nanmean(allpeaks(:,where_beta)));

keep suj_list allpeaks ; clc ;

%%

for nsuj = 1:length(suj_list)
    
    bin_summary                             = [];
    i                                       = 0;
    
    for nsess = 1:2
        
        % load peak
        fname                               = ['/Volumes/heshamshung/nback/peak/sub' num2str(suj_list(nsuj)) '.alphabeta.peak.package.0back.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        
        fname                               = ['/Volumes/heshamshung/nback/nback_' num2str(nsess) '/data_sess' num2str(nsess) '_s' num2str(suj_list(nsuj)) '.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        
        %-%-% exclude trials with a previous response
        cfg                                 = [];
        cfg.trials                          = find(data.trialinfo(:,5) == 0 & data.trialinfo(:,1) ~= 4);
        data                                = ft_selectdata(cfg,data);
        sess_carr{nsess}                    = data; clear data;
        
    end
    
    %-%-% appenddata across
    data_concat                           	= ft_appenddata([],sess_carr{:}); clear sess_carr
    
    %-%-% downsample for decoding
    cfg                                     = [];
    cfg.resamplefs                          = 100;
    cfg.detrend                             = 'no';
    cfg.demean                              = 'yes';
    data_downsample                         = ft_resampledata(cfg, data_concat);
    data_downsample                         = rmfield(data_downsample,'cfg');
    
end