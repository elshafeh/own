clear ; close all; global ft_default
ft_default.spmversion = 'spm12';

load suj_list_peak.mat

h                                           = waitbar(0,'Computing!...');

for nsuj = 32:length(suj_list)
    
    subjectname                             = ['sub' num2str(suj_list(nsuj))];
    
    waitbar(nsuj/length(suj_list),h,[subjectname ' ' num2str(nsuj) '/' num2str(length(suj_list))]);
    
    fname                                   = ['../data/source/volgrid/' subjectname '.volgrid.mat'];
    fprintf('\nloading %s\n',fname);
    load(fname);
    
    for nsession = 1:2
        
        fname                               = ['../data/prepro/stack/data_sess' num2str(nsession) '_s' num2str(suj_list(nsuj)) '_3stacked.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        
        data_orig                           = data; clear data;
        
        fname                               = ['../data/source/lead/' subjectname '.session' num2str(nsession) '.leadfield.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        
        % load peak
        fname                               = ['../data/peak/' subjectname '.alphabetapeak.m1000m0ms.mat'];
        fprintf('loading %s\n\n',fname);
        load(fname);
        
        fpeak                               = [apeak bpeak];
        bnwidth                             = [1 3];
        peak_name                           = {'alpha1Hz','beta3Hz'};
        
        for nfreq = 1:length(fpeak)
            
            f1                              = fpeak(nfreq) - bnwidth(nfreq);
            f2                              = fpeak(nfreq) + bnwidth(nfreq);
            
            cfg                             = [];
            cfg.bpfilter                    = 'yes';
            cfg.bpfreq                      = [f1 f2];
            cfg.continuous                  = 'yes';
            cfg.padding                     = 10;
            cfg.bpfiltord                   = 4;
            filt_data                       = ft_preprocessing(cfg,data_orig);
            
            spatialfilter                   = nk_virt_common_filter(filt_data,[-1 5],leadfield,vol);
            data                            = nk_virt_compute(filt_data,'../data/template/brainnetome_roi1cm.mat',spatialfilter);
            
            cfg                             = [];
            cfg.resamplefs                  = 100;
            cfg.detrend                     = 'no';
            cfg.demean                      = 'no';
            data                            = ft_resampledata(cfg, data);
            data                            = rmfield(data,'cfg');
            
            fname_out                       = ['../data/source/virtual/' subjectname '.session' num2str(nsession) '.brain.' peak_name{nfreq} '.virt.mat'];
            fprintf('\nsaving %s\n',fname_out);
            save(fname_out,'data','-v7.3'); clc;
            
            clear data spatialfilter filt_data f1 f2
            
        end
        
        clear apeak bpeak data_orig leadfield
        
    end
end

close(h);