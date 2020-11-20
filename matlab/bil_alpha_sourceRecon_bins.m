clear ; clc;

if isunix
    start_dir             = '/project/';
else
    start_dir             = 'P:/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName                                         = suj_list{nsuj};
    
    fname                                               = ['I:/hesham/bil/head/' subjectName '.volgridLead.0.5cm.withNas.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    fname                                               = [start_dir '3015079.01/data/' subjectName '/preproc/' subjectName '_firstCueLock_ICAlean_finalrej.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    % -- sub-select channls from leadfield: to avoid conflict with common filter
    cfg                                                 = [];
    cfg.channel                                         = dataPostICA_clean.label;
    leadfield                                           = ft_selectdata(cfg,leadfield);
    
    % -- load peak
    fname                                               = [start_dir '3015079.01/data/' subjectName '/tf/' subjectName ....
        '.firstcuelock.freqComb.alphaPeak.m1000m0ms.gratinglock.demean.erfComb.max20chan.p0p200ms.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    % -- peak freq +/- 1Hz
    list_freq                                           = [round(apeak)];
    list_smooth                                         = [1];
    
    for nf = 1:length(list_freq)
        
        % -- create common filter
        cfg                                             = [];
        cfg.toilim                                      = [-1 0];
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
        
        % -- compute common filter
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
        
        % -- load bins
        title_win                                       = 'preCue1';
        fname                                           = [start_dir '3015079.01/data/' subjectName '/tf/' subjectName '.firstcuelock.freqComb.alphaPeak.' ...
            'm1000m0ms.gratinglock.demean.erfComb.max20chan.p0p200ms.5Bins.1Hz.window.' title_win '.all.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        
        for nbin = 1:size(bin_summary.bins,2)
            
            % 1 sec pre-cue window
            t1                                          = -1;
            t2                                          =  0;
            
            f1                                          = cfg_freq.foi-cfg_freq.tapsmofrq;
            f2                                          = cfg_freq.foi+cfg_freq.tapsmofrq;
            
            % -- separate sources
            cfg                                         = [];
            cfg.toilim                                  = [t1 t2];
            cfg.trials                                  = bin_summary.bins(:,nbin);
            data                                        = ft_redefinetrial(cfg, dataPostICA_clean);
            
            freq_source                                 = ft_freqanalysis(cfg_freq,data);
            
            % -- compute single sources
            cfg                                         = [];
            cfg.method                                  = 'dics';
            cfg.frequency                               = freq_source.freq;
            cfg.sourcemodel                             = leadfield;
            cfg.sourcemodel.filter                      = com_filter;
            cfg.headmodel                               = vol;
            cfg.dics.fixedori                           = 'yes';
            cfg.dics.projectnoise                       = 'yes';
            cfg.dics.lambda                             = '5%';
            source                                      = ft_sourceanalysis(cfg, freq_source); clear data freq_source;
            source                                      = source.avg.pow;
            
            if t1 < 0
                ext_ext= 'm';
            else
                ext_ext='p';
            end
            
            ext_time_source                             = [ext_ext num2str(abs(t1*1000)) ext_ext num2str(abs((t2)*1000))];
            fname_out                                   = [start_dir '3015079.01/data/' subjectName '/source/' subjectName '.' num2str(f1) 't' num2str(f2) 'Hz.'  ...
                ext_time_source '.' title_win 'alphasorted.bin' num2str(nbin) '.AlphaReconDics.mat'];
            fprintf('saving %s\n',fname_out);
            save(fname_out,'source','-v7.3'); clear plf t1 t2 f1 f2 ext_time_source source data freq_source;
            
        end
    end
end