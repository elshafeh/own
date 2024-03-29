clear ; clc;

if isunix
    start_dir             = '/project/';
else
    start_dir             = 'P:/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

clear ; clc;

if isunix
    project_dir                 = '/project/3015079.01/';
    start_dir                   = '/project/';
else
    project_dir                 = 'P:/3015079.01/';
    start_dir                   = 'P:/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName                 = suj_list{nsuj};
    fname                       = [project_dir 'data/' subjectName '/tf/' subjectName '.firstcuelock.1overf.orig.alphabetaPeak.' ...
        'm1000m0ms.mat'];
    load(fname);
    
    allpeaks(nsuj,1)            = [apeak_orig];
    allpeaks(nsuj,2)            = [bpeak_orig];
    
end

allpeaks(find(isnan(allpeaks(:,2))),2)  = round(nanmean(allpeaks(:,2)));

keep suj_list allpeaks start_dir

for nsuj = 1:length(suj_list)
    
    subjectName                                         = suj_list{nsuj};
    
    fname                                               = ['I:/bil/head/' subjectName '.volgridLead.0.5cm.withNas.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    fname                                               = [start_dir '3015079.01/data/' subjectName '/preproc/' subjectName '_firstCueLock_ICAlean_finalrej.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    indx_rt                                             = dataPostICA_clean.trialinfo(:,14);
    indx_rt(indx_rt(:,1) < median(indx_rt(:,1)),2) = 1; % 1 = fast
    indx_rt(indx_rt(:,1) > median(indx_rt(:,1)),2) = 2; % 2 = slow
    
    trialinfo                                           = dataPostICA_clean.trialinfo;
    trialinfo(trialinfo(:,16) == 0,16)                  = 2; % change correct to 1(corr) and 2(incorr)
    trialinfo                                           = trialinfo(:,[7 8 16]); % 1st column is task , 2nd is cue and 3 correct
    trialinfo                                           = [trialinfo indx_rt(:,2)]; % col.4 is RT
    
    % -- sub-select channls from leadfield: to avoid conflict with common filter
    cfg                                                 = [];
    cfg.channel                                         = dataPostICA_clean.label;
    leadfield                                           = ft_selectdata(cfg,leadfield);
    
    % -- load peak 
    %     fname                                               = [start_dir '3015079.01/data/' subjectName '/tf/' subjectName ....
    %         '.firstcuelock.freqComb.alphaPeak.m1000m0ms.gratinglock.demean.erfComb.max20chan.p0p200ms.mat'];
    %     fprintf('loading %s\n',fname);
    %     load(fname);
    
    list_freq                                           = [4 round(allpeaks(nsuj,1)) round(allpeaks(nsuj,2))];
    list_smooth                                         = [1 1 2];
    list_band_name                                      = {'ThetaReconDics' 'AlphaReconDics' 'BetaReconDics'}; 
    
    for nfreq = 1:length(list_freq)
        
        % -- create common filter
        cfg                                             = [];
        cfg.toilim                                      = [-2 6];
        data                                            = ft_redefinetrial(cfg, dataPostICA_clean);
        
        % -- use same freq parameters for both common filter and single sources
        cfg_freq                                        = [];
        cfg_freq.method                                 = 'mtmfft';
        cfg_freq.foi                                    = list_freq(nfreq);
        cfg_freq.tapsmofrq                              = list_smooth(nfreq);
        cfg_freq.output                                 = 'fourier';
        cfg_freq.taper                                  = 'hanning';
        cfg_freq.pad                                    = 'nextpow2';
        freq_com_filter                                 = ft_freqanalysis(cfg_freq,data);
        
        cfg                                             = [];
        cfg.method                                      = 'dics';
        cfg.frequency                                   = freq_com_filter.freq;
        cfg.sourcemodel                                 = leadfield;
        cfg.headmodel                                   = vol;
        cfg.dics.keepfilter                             = 'yes';
        cfg.dics.fixedori                               = 'yes';
        cfg.dics.projectnoise                           = 'yes';
        cfg.dics.lambda                                 = '5%';
        source                                          = ft_sourceanalysis(cfg, freq_com_filter);
        com_filter                                      = source.avg.filter; clear source freq_com_filter data;
        
        % correct: slow v fast
        %         pkg_source(1).indx_trials{1}                    = find(trialinfo(:,3) == 1 & trialinfo(:,4) ==1);
        %         pkg_source(1).indx_trials{2}                    = find(trialinfo(:,3) == 1 & trialinfo(:,4) ==2);
        %         pkg_source(1).name_cond                         = {'correct.fast','correct.slow'};
        %         pkg_source(1).time_win                          = [5.3 6.3]; %[-1.2 -0.2; -0.6 -0.2; 4 5; 1.3 1.8; 0.18 1.16];
        %         pkg_source(1).pad_lim                           = 1;
        
        %         % RETRO correct v incorrect
        %         pkg_source(2).indx_trials{1}                    = find(trialinfo(:,2) == 2 & trialinfo(:,3) == 1);
        %         pkg_source(2).indx_trials{2}                    = find(trialinfo(:,2) == 2 & trialinfo(:,3) == 2);
        %         pkg_source(2).name_cond                         = {'retro.correct','retro.incorrect'};
        %         pkg_source(2).time_win                          = [-0.7 -0.2; 1.5 2];
        %         pkg_source(1).pad_lim                           = 1;
        
        % pre v retro
        pkg_source(1).indx_trials{1}                    = find(trialinfo(:,3) == 1 & trialinfo(:,2) == 1);
        pkg_source(1).indx_trials{2}                    = find(trialinfo(:,3) == 1 & trialinfo(:,2) == 2);
        pkg_source(1).name_cond                         = {'correct.pre','correct.retro'};
        
        if nfreq == 1 % theta
            pkg_source(1).time_win                      = [-0.6 -0.2;3.7 4.7];
        elseif nfreq == 2 % alpha
            pkg_source(1).time_win                      = [-0.6 -0.2;0.35 1; 3 4];
        elseif nfreq == 3 % beta
            pkg_source(1).time_win                      = [-0.6 -0.2;0.34 0.77;2.6 3.6;3.8 4.4];
        end
            
        pkg_source(1).pad_lim                           = 1;
        
        for npkg = 1:length(pkg_source)
            for ncond = 1:length(pkg_source(npkg).name_cond)
                for ntime = 1:size(pkg_source(npkg).time_win,1)
                    
                    t1                                  =  pkg_source(npkg).time_win(ntime,1);
                    t2                                  =  pkg_source(npkg).time_win(ntime,2);
                    
                    f1                                  = cfg_freq.foi-cfg_freq.tapsmofrq;
                    f2                                  = cfg_freq.foi+cfg_freq.tapsmofrq;
                    
                    % -- separate sources
                    cfg                                 = [];
                    cfg.toilim                          = [t1 t2];
                    cfg.trials                          = pkg_source(npkg).indx_trials{ncond};
                    data                                = ft_redefinetrial(cfg, dataPostICA_clean);
                    
                    if abs(abs(t2) - abs(t1)) < pkg_source(npkg).pad_lim
                        cfg_freq.pad                    = pkg_source(npkg).pad_lim;
                    else
                        if isfield(cfg_freq,'pad')
                            cfg_freq                    = rmfield(cfg_freq,'pad');
                        end
                    end
                    
                    freq_source                         = ft_freqanalysis(cfg_freq,data);
                    
                    cfg                                 = [];
                    cfg.method                          = 'dics';
                    cfg.frequency                       = freq_source.freq;
                    cfg.sourcemodel                     = leadfield;
                    cfg.sourcemodel.filter              = com_filter;
                    cfg.headmodel                       = vol;
                    cfg.dics.fixedori                   = 'yes';
                    cfg.dics.projectnoise               = 'yes';
                    cfg.dics.lambda                     = '5%';
                    source                              = ft_sourceanalysis(cfg, freq_source); clear data freq_source;
                    source                              = source.avg.pow;
                    
                    if t1 < 0
                        ext_ext= 'm';
                    else
                        ext_ext='p';
                    end
                    
                    ext_time_source                     = [ext_ext num2str(abs(t1*1000)) ext_ext num2str(abs((t2)*1000))];
                    
                    fname_out                           = [start_dir '3015079.01/data/' subjectName '/source/' subjectName '.' num2str(f1) 't' num2str(f2) 'Hz.'  ... 
                        ext_time_source '.' pkg_source(npkg).name_cond{ncond} '.' list_band_name{nfreq} '.mat'];
                    fprintf('saving %s\n',fname_out);
                    save(fname_out,'source','-v7.3'); clear plf t1 t2 f1 f2 ext_time_source source data freq_source;
                    
                end
            end
        end
    end
    
    clear com_filter dataPostICA_clean
    
end