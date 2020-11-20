clear ; clc;

if isunix
    start_dir             = '/project/';
else
    start_dir             = 'P:/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 18:length(suj_list)
    
    subjectName                                 = suj_list{nsuj};
    
    fname                                       = ['I:/bil/head/' subjectName '.volgridLead.0.5cm.withNas.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    fname                                       = [start_dir '3015079.01/data/' subjectName '/preproc/' subjectName '_firstCueLock_ICAlean_finalrej.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    % choose correct trials [to keep the indices right]
    %     cfg                                     	= [];
    %     cfg.trials                                  = find(dataPostICA_clean.trialinfo(:,16) == 1);
    %     dataPostICA_clean                        	= ft_selectdata(cfg,dataPostICA_clean);
    
    % -- sub-select channls from leadfield: to avoid conflict with common filter
    cfg                                         = [];
    cfg.channel                                 = dataPostICA_clean.label;
    leadfield                                   = ft_selectdata(cfg,leadfield);
    
    list_freq                                   = [3];
    list_smooth                                 = [2];
    
    for nf = 1:length(list_freq)
        
        % -- create common filter
        cfg                                     = [];
        cfg.toilim                              = [-1.5 6.5];
        data                                    = ft_redefinetrial(cfg, dataPostICA_clean);
        
        % -- use same freq parameters for both common filter and single sources
        cfg_freq                                = [];
        cfg_freq.method                         = 'mtmfft';
        cfg_freq.foi                            = list_freq(nf);
        cfg_freq.tapsmofrq                      = list_smooth(nf);
        cfg_freq.output                         = 'fourier';
        cfg_freq.taper                          = 'hanning';
        cfg_freq.pad                            = 'nextpow2';
        freq_com_filter                         = ft_freqanalysis(cfg_freq,data);
        
        cfg                                     = [];
        cfg.method                              = 'pcc';
        cfg.frequency                           = freq_com_filter.freq;
        cfg.sourcemodel                         = leadfield;
        cfg.headmodel                           = vol;
        cfg.pcc.fixedori                        = 'yes';
        cfg.pcc.projectnoise                    = 'yes';
        cfg.pcc.projectmom                      = 'yes';
        cfg.pcc.lambda                          = '5%';
        cfg.pcc.keepfilter                      = 'yes';
        source                                  = ft_sourceanalysis(cfg, freq_com_filter);
        com_filter                              = source.avg.filter; clear source freq_com_filter data;
        
        list_time                               = [-0.6 -0.2; 4.3 5.5];
        
        % make sure of what file you load!
        fname                                   = [start_dir '3015079.01/data/' subjectName '/tf/' subjectName '.cuelock.itc.5binned.withEvoked.withIncorrect.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        
        for nbin = 2:4
            for ntime = 1:size(list_time,1)
                
                % -- separate sources
                cfg                             = [];
                cfg.toilim                      = list_time(ntime,:);
                cfg.trials                      = phase_lock{nbin}.index;
                data                            = ft_redefinetrial(cfg, dataPostICA_clean);
                
                cfg_freq.pad                    = 1.5;
                freq_source                     = ft_freqanalysis(cfg_freq,data);
                
                cfg                             = [];
                cfg.method                      = 'pcc';
                cfg.frequency                   = freq_source.freq;
                cfg.sourcemodel                 = leadfield;
                cfg.sourcemodel.filter          = com_filter;
                cfg.headmodel                   = vol;
                cfg.pcc.projectnoise            = 'yes';
                cfg.pcc.projectmom              = 'yes';
                cfg.pcc.lambda                  = '5%';
                source                          = ft_sourceanalysis(cfg, freq_source); clear data freq_source;
                plf                             = mbon_PhaseLockingFactor_source(source.avg.mom); clear source;
                
                f1                              = cfg_freq.foi-cfg_freq.tapsmofrq;
                f2                              = cfg_freq.foi+cfg_freq.tapsmofrq;
                
                t1                              = list_time(ntime,1);
                t2                              = list_time(ntime,2);
                
                if t1 < 0
                    ext_ext= 'm';
                else
                    ext_ext='p';
                end
                
                ext_time_source                 = [ext_ext num2str(abs(t1*1000)) ext_ext num2str(abs((t2)*1000))];
                
                fname_out                       = [start_dir '3015079.01/data/' subjectName '/source/' subjectName '.itc.' ext_time_source '.' num2str(f1) 't' num2str(f2)];
                fname_out                       = [fname_out 'Hz.bin' num2str(nbin) '.withincorrect.pccsource.mat'];
                fprintf('saving %s\n',fname_out);
                save(fname_out,'plf','-v7.3'); clear plf t1 t2 f1 f2 ext_time_source source data freq_source;
                
            end
        end
    end
    
    clear com_filter dataPostICA_clean
    
end