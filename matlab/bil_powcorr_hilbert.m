clear ; clc;

load ../data/bil_goodsubjectlist.27feb20.mat

if isunix
    project_dir                     = '/project/3015079.01/';
    start_dir                       = '/project/';
else
    project_dir                     = 'P:/3015079.01/';
    start_dir                       = 'P:/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName                     = suj_list{nsuj};
    
    fname                           = [project_dir 'data/' subjectName '/tf/' subjectName '.firstcuelock.freqComb.alphaPeak.m1000m0ms.gratinglock.demean.erfComb.max20chan.p0p200ms.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    allpeaks(nsuj,1)                = [apeak];
    
    fname                           = [project_dir 'data/' subjectName '/tf/' subjectName '.firstcuelock.1overf.orig.alphabetaPeak.' ...
        'm1000m0ms.mat'];
    load(fname);
    allpeaks(nsuj,2)                = [bpeak_orig];
    
end

allpeaks(isnan(allpeaks(:,2)),2)    = nanmean(allpeaks(:,2));
allpeaks                            = round(allpeaks);

keep suj_list allpeaks ; clc;

for nsuj = 1:length(suj_list)
    
    subjectName                     = suj_list{nsuj};
    subject_folder                  = ['P:/3015079.01/data/' subjectName '/'];
    
    list_foi{1}                     = [2 6];
    list_foi{2}                     = [2 6];
    list_foi{3}                     = [allpeaks(nsuj,1)-2 allpeaks(nsuj,1)+2];
    list_foi{4}                     = [allpeaks(nsuj,2)-2 allpeaks(nsuj,2)+2];
    
    list_name                       = {'theta phase' 'theta pow' 'alpha pow' 'beta pow'};
    
    fname                           = [subject_folder 'preproc/' subjectName '_firstCueLock_ICAlean_finalrej.mat'];
    fprintf('\nloading %s\n',fname);
    load(fname);
    
    fname                           = ['P:/3015079.01/data/' subjectName '/erf/' subjectName ...
        '.gratinglock.demean.erfComb.max20chan.p0p200ms.postOnset.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    cfg                             = [];
    cfg.trials                      = find(dataPostICA_clean.trialinfo(:,16) == 1);
    cfg.avgoverchan                 = 'yes';
    cfg.channel                     = max_chan;
    dataPostICA_clean             	= ft_selectdata(cfg,dataPostICA_clean);

    
    for nfreq = 1:length(list_foi)
        
        cfg                         = [];
        
        if nfreq == 1
            cfg.hilbert = 'angle';
        else
            cfg.hilbert         	= 'abs';
        end
        
        cfg.bpfilter                = 'yes';
        cfg.bpfreq                  = list_foi{nfreq};
        data_bp{nfreq}          	= ft_preprocessing(cfg, dataPostICA_clean);
        data_bp{nfreq}.label{1}     = list_name{nfreq}; 
        
    end
        
    data                            = ft_appenddata([], data_bp{:});
    data                            = rmfield(data,'cfg');
    
    fname_out                       = ['F:/bil/preproc/' subjectName '.maxchan_4signals.mat'];
    fprintf('Saving %s\n',fname_out);
    save(fname_out,'data','-v7.3');
    
    %     cfg                 	= [];
    %     cfg.covariance          = 'yes';
    %     cfg.keeptrials          = 'no';
    %     cfg.removemean          = 'yes';
    %     timelock                = ft_timelockanalysis(cfg,data);
    %
    %     cov                     = timelock.cov; % all trials
    %     d = sqrt(diag(cov)); % SD, diagonal is variance per channel
    %     r = cov ./ (d*d');
    %     figure; imagesc(1:4,1:4,r);xticks(1:4);yticks(1:4);xticklabels(timelock.label);yticklabels(timelock.label)
    
end