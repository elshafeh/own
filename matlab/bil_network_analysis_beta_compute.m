clear ; clc;

if isunix
    project_dir                                         = '/project/3015079.01/';
    start_dir                                           = '/project/';
else
    project_dir                                         = 'P:/3015079.01/';
    start_dir                                           = 'P:/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName                                         = suj_list{nsuj};
    fname                                               = [project_dir 'data/' subjectName '/tf/' subjectName '.firstcuelock.1overf.orig.alphabetaPeak.' ...
        'm1000m0ms.mat'];
    load(fname);
    allpeaks(nsuj,1)                                    = [bpeak_orig];
    
end

allpeaks(find(isnan(allpeaks)))                         = round(nanmean(allpeaks));

for nsuj = 1:length(suj_list)
    
    subjectName                                         = suj_list{nsuj};
    
    fname                                               = ['I:/hesham/bil/head/' subjectName '.volgridLead.1cm.withNas.mat'];
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
    
    list_freq                                           = [round(allpeaks(nsuj))];
    list_smooth                                         = [2];
    
    for nf = 1:length(list_freq)
        
        % -- create common filter
        cfg                                             = [];
        cfg.toilim                                      = [-2 6];
        data                                            = ft_redefinetrial(cfg, dataPostICA_clean);
        
        % -- use same freq parameters for both common filter and single sources
        cfg_freq                                        = [];
        cfg_freq.method                                 = 'mtmfft';
        cfg_freq.foi                                    = list_freq(nf);
        cfg_freq.tapsmofrq                              = list_smooth(nf);
        cfg_freq.output                                 = 'fourier';
        cfg_freq.taper                                  = 'hanning';
        cfg_freq.pad                                    = 'nextpow2';
        freq_com_filter                                 = ft_freqanalysis(cfg_freq,data);
        
        cfg                                             = [];
        cfg.method                                      = 'pcc';
        cfg.frequency                                   = freq_com_filter.freq;
        cfg.sourcemodel                                 = leadfield;
        cfg.headmodel                                   = vol;
        cfg.pcc.keepfilter                              = 'yes';
        cfg.pcc.fixedori                                = 'yes';
        cfg.pcc.projectnoise                             = 'yes';
        cfg.pcc.lambda                                  = '5%';
        source                                          = ft_sourceanalysis(cfg, freq_com_filter);
        com_filter                                      = source.avg.filter; clear source freq_com_filter data;
        
        % pre v retro
        pkg_source(3).indx_trials{1}                    = find(trialinfo(:,3) == 1 & trialinfo(:,2) == 1);
        pkg_source(3).indx_trials{2}                    = find(trialinfo(:,3) == 1 & trialinfo(:,2) == 2);
        pkg_source(3).name_cond                         = {'correct.pre','correct.retro'};
        pkg_source(3).time_win                          = [-1 0; 0.5 1.5; 2 3; 3.5 4.5; 5 6];
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
                    
                    cfg_freq.keeptrials                 = 'yes';
                    freq_source                         = ft_freqanalysis(cfg_freq,data);
                    
                    cfg                                 = [];
                    cfg.method                          = 'pcc';
                    cfg.frequency                       = freq_source.freq;
                    cfg.sourcemodel                     = leadfield;
                    cfg.sourcemodel.filter              = com_filter;
                    cfg.headmodel                       = vol;
                    cfg.pcc.projectnoise                = 'yes';
                    cfg.pcc.lambda                      = '5%';
                    cfg.keeptrials                      = 'yes';
                    source                              = ft_sourceanalysis(cfg, freq_source); clear data freq_source;
                    
                    cfg                                 = [];
                    cfg.method                          = 'coh';
                    source_conn                        	= ft_connectivityanalysis(cfg, source);
                    
                    cfg                                 = [];
                    cfg.method                          = 'degrees';
                    cfg.parameter                       = 'cohspctrm';
                    cfg.threshold                       = .1;
                    network_full                        = ft_networkanalysis(cfg,source_conn);
                    
                    network_full                        = rmfield(network_full,'cfg');
                    source_conn                         = rmfield(source_conn,'cfg');
                    
                    if t1 < 0
                        ext_ext= 'm';
                    else
                        ext_ext='p';
                    end
                    
                    ext_time_source                     = [ext_ext num2str(abs(t1*1000)) ext_ext num2str(abs((t2)*1000))];
                    
                    fname_out                           = ['I:\bil\source\' subjectName '.' num2str(f1) 't' num2str(f2) 'Hz.'  ... 
                        ext_time_source '.' pkg_source(npkg).name_cond{ncond} '.BetaRecon.coh.mat'];
                    fprintf('saving %s\n',fname_out);
                    save(fname_out,'source_conn','network_full','-v7.3'); 
                    clear plf t1 t2 f1 f2 ext_time_source source data freq_source source_conn network_full;
                    
                end
            end
        end
    end
    
    clear com_filter dataPostICA_clean
    
end