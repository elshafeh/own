
clear ;

suj_list                    = {'sub001','sub003','sub008','sub009','sub010'};

for ns = 1:length(suj_list)
    
    subjectName             = suj_list{ns};
    
    dir_data                = ['../data/' subjectName '/preproc/'];
    
    orig_name               = 'firstCueLock_ICAlean_finalrej'; % 'gratingLock_dwnsample100Hz'; %
    
    fname                   = [dir_data subjectName '_' orig_name '.mat'];
    fprintf('Loading %s\n',fname);
    load(fname);
    
    data_axial              = dataPostICA_clean; clear dataPostICA_clean;
    data_planar             = h_ax2plan(data_axial);
    
    list_time               = [-0.6 0 1.5 3 4.5];
    
    for nt   = 1:length(list_time)
        
        if list_time(nt) >= 0
            ax1             = list_time(nt)+0.4;
            ax2             = ax1+1;
        else
            ax1             = list_time(nt);
            ax2             = ax1+0.4;
        end
        
        cfg                 = [];
        cfg.latency         = [ax1 ax2];
        data                = ft_selectdata(cfg, data_planar); % select corresponding data
        
        disp([data.time{1}(1) data.time{1}(end)]);
        
        cfg                 = [] ;
        cfg.output          = 'pow';
        cfg.method          = 'mtmfft';
        cfg.keeptrials      = 'yes';
        
        if list_time(nt) < 0
            cfg.pad         = 1;
            cfg.foi         = 1:1/cfg.pad:100;
        else
            cfg.foi         = 1:1:100;
        end
        
        cfg.taper           = 'hanning';
        cfg.tapsmofrq       = 0 ;
        
        freq                = ft_freqanalysis(cfg,data);
        
        cfg                 = []; cfg.method     = 'sum';
        freq_comb           = ft_combineplanar(cfg,freq);
        
        nm_prt              = strsplit(orig_name,'_');
        ext_name            = [lower(nm_prt{1}) '.fft.comb.window' num2str(nt)];
        
        dir_data            = ['../data/' subjectName '/tf/'];
        mkdir(dir_data);
        
        fname           = [dir_data subjectName '.' ext_name '.mat'];
        fprintf('Saving %s\n',fname);
        
        save(fname,'freq_comb','-v7.3'); clear freq data;
        
        fprintf('\ndone\n\n');
        
    end
end