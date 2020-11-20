clear ; close all; global ft_default
ft_default.spmversion = 'spm12';

load suj_list_peak.mat

h                                           = waitbar(0,'Computing!...');

for nsuj = 3:length(suj_list)
    
    subjectname                             = ['sub' num2str(suj_list(nsuj))];
    
    waitbar(nsuj/length(suj_list),h,[subjectname ' ' num2str(nsuj) '/' num2str(length(suj_list))]);
    
    fname                                   = ['../../data/source/volgrid/' subjectname '.volgrid.0.5cm.mat'];
    fprintf('\nloading %s\n',fname);
    load(fname);
    
    for nsession = 1:2
        
        fname                               = ['../../data/prepro/stack/data_sess' num2str(nsession) '_s' num2str(suj_list(nsuj)) '_3stacked.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        
        cfg                                 = [];
        cfg.resamplefs                      = 100;
        cfg.detrend                         = 'no';
        cfg.demean                          = 'no';
        data_orig                           = ft_resampledata(cfg, data); clear data;
        data_orig                           = rmfield(data_orig,'cfg');
        
        fname                               = ['../../data/source/lead/' subjectname '.session' num2str(nsession) '.leadfield.0.5cm.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        
        % load peak
        %         fname                               = ['../../data/peak/' subjectname '.alphabetapeak.m1000m0ms.mat'];
        %         fprintf('loading %s\n\n',fname);
        %         load(fname);
        %         fpeak                               = [bpeak];
        %         bnwidth                             = [2];
        %         peak_name                           = {'beta2Hz'};
        
        for nfreq = 1%:length(fpeak)
            
            f1                              = 1; % fpeak(nfreq) - bnwidth(nfreq);
            f2                              = 40;% fpeak(nfreq) + bnwidth(nfreq);
            
            cfg                             = [];
            cfg.bpfilter                    = 'yes';
            cfg.bpfreq                      = [f1 f2];
            cfg.continuous                  = 'yes';
            cfg.padding                     = 10;
            cfg.bpfiltord                   = 4;
            filt_data                       = ft_preprocessing(cfg,data_orig);
            
            spatialfilter                   = nk_virt_common_filter(filt_data,[-0.1 5],leadfield,vol);
            data                            = nk_virt_compute(filt_data,'../../data/template/com_btomeroi_select.mat',spatialfilter);
            
            fname_out                       = ['../../data/source/virtual/0.5cm/' subjectname '.session' num2str(nsession) '.brain0.5.broadband.dwn80.virt.mat'];
            fprintf('\nsaving %s\n',fname_out);
            save(fname_out,'data','-v7.3'); clc;
            
            clear data spatialfilter filt_data f1 f2
            
        end
        
        clear apeak bpeak data_orig leadfield
        
    end
end

close(h);