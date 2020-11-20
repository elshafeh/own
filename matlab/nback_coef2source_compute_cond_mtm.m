clear ; close all;clc;

suj_list                                    = [1:33 35:36 38:44 46:51];
allpeaks                                    = [];

for nsuj = 1:length(suj_list)
    load(['J:/temp/nback/data/peak/sub' num2str(suj_list(nsuj)) '.alphabeta.peak.package.mat']);
    allpeaks(nsuj,1)                        = apeak; clear apeak;
    allpeaks(nsuj,2)                        = bpeak; clear bpeak;
end

allpeaks(isnan(allpeaks(:,2)),2)            = nanmean(allpeaks(:,2));

keep suj_list allpeaks

for nsuj = 1:length(suj_list)
    
    % lead headshape
    fname                                   = ['J:/temp/nback/data/source/volgrid/sub' num2str(suj_list(nsuj)) '.volgrid.0.5cm.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    for nsession = 1:2
        
        % laod data
        fname                               = ['J:/temp/nback/data/nback_' num2str(nsession) '/data_sess' num2str(nsession) '_s' num2str(suj_list(nsuj)) '.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        
        % load leadfield
        fname                               = ['J:/temp/nback/data/source/lead/sub' num2str(suj_list(nsuj)) '.session' num2str(nsession) '.leadfield.0.5cm.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        
        % down sample
        cfg                                 = [];
        cfg.resamplefs                      = 70;
        cfg.detrend                         = 'no';
        cfg.demean                          = 'no';
        data                                = ft_resampledata(cfg, data);
        
        % calculate covariance
        cfg                                 = [];
        cfg.covariance                      = 'yes';
        cfg.covariancewindow                = [-0.5 1.5];
        filter_avg                          = ft_timelockanalysis(cfg, data); clear data;
        
        % compute spatial filter
        spatialfilter                       = h_ramaComputeFilter(filter_avg,leadfield,vol);
        
        %         list_cond{1}                        = {'0back','all.4cond'};
        %         list_cond{2}                        = {'1back','all.4cond'};
        %         list_center                         = {'alpha1Hz','beta2Hz'};
        %         list_peak                           = [allpeaks(nsuj,1) allpeaks(nsuj,2)];
        %         list_width                          = [1 2];
        
        list_cond{1}                        = {'0back','target.4stim'};
        list_cond{2}                        = {'1back','target.4stim'};
        list_cond{3}                        = {'2back','target.4stim'};
        
        list_center_name                 	= {'8Hz'}; %{'5Hz','6Hz','7Hz'};
        list_peak                           = [8]; %[5 6 7];
        list_width                          = [0];
        
        for ncond = 1:length(list_cond)
            for ncenter = 1:length(list_center_name)
                
                f1                          = round(list_peak(ncenter)-list_width(ncenter));
                f2                          = round(list_peak(ncenter)+list_width(ncenter));
                freq_list                   = f1:1:f2;
                
                chk                         = ['J:/temp/nback/data/coef_mtm/sub' num2str(suj_list(nsuj)) '.sess' num2str(nsession) '.' ...
                    list_cond{ncond}{1} '.10Hz.' list_cond{ncond}{2} '.coef.mat'];
                
                if exist(chk)
                    
                    tmp                     = [];
                    
                    for nfreq = 1:length(freq_list)
                        fname               = ['J:/temp/nback/data/coef_mtm/sub' num2str(suj_list(nsuj)) '.sess' num2str(nsession) '.' ...
                            list_cond{ncond}{1} '.' num2str(freq_list(nfreq)) 'Hz.' list_cond{ncond}{2} '.coef.mat'];
                        fprintf('loading %s\n',fname);
                        load(fname);
                        tmp(nfreq,:,:)      = scores; clear scores;
                    end
                    
                    fname_out           	= ['J:/temp/nback/data/coef_mtm/sub' num2str(suj_list(nsuj)) '.sess' num2str(nsession) '.' ...
                        list_center_name{ncenter} '.' list_cond{ncond}{1} '.' list_cond{ncond}{2} '.coef.lcmv.mat'];
                    
                    data                 	= [];
                    data.avg            	= squeeze(mean(tmp,1))' * [spatialfilter]'; clear tmp;
                    data.avg              	= data.avg';
                    data.dimord          	= 'chan_time';
                    data.label            	= cellstr(num2str([1:size(spatialfilter,1)]'));
                    data.time             	= time_axis;
                    
                    fprintf('saving %50s\n',fname_out);
                    save(fname_out,'data');
                    clear data
                    
                end
            end
        end
    end
end