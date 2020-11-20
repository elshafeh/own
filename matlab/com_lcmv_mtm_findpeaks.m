clear;

suj_list                    = [1:4 8:17] ;
data_list                   = {'meg','eeg'};

for nsuj = 1:length(suj_list)
    
    suj                     = ['yc' num2str(suj_list(nsuj))] ;
    
    for ndata = 1:2
        
        ext_name                = [suj '.CnD.brainnetome.' data_list{ndata}];
        
        fname_in                = ['../data/tf/' ext_name '.1t40Hz.1HzStep.AvgTrials.mat'];
        fprintf('\nLoading %50s\n',fname_in);
        load(fname_in);
        
        peak_window             = [-1 0];
        peak_name               = [];
        
        for nt = 1:2
            if peak_window(nt) > 0
                peak_name       = [peak_name 'p' num2str(abs(peak_window(nt)*1000))];
            else
                peak_name       = [peak_name 'm' num2str(abs(peak_window(nt)*1000))];
            end
        end
        
        peak_name               = [peak_name 'ms'];
        
        cfg                     = [];
        cfg.latency             = peak_window; 
        cfg.avgovertime         = 'yes';
        cfg.nanmean             = 'yes';
        cfg.frequency           = [7 14];
        freq                    = ft_selectdata(cfg,freq);
        freq                    = rmfield(freq,'cfg');
        freq.dimord             = 'chan_freq';
        
        allpeaks                = [];
        
        for nchan = 1:length(freq.label)
            
            tmp                 = freq;
            tmp.powspctrm       = tmp.powspctrm(nchan,:,:);
            tmp.label           = tmp.label(nchan);
            
            cfg                 = [];
            cfg.method          = 'maxabs' ;
            apeak               = alpha_peak(cfg,tmp);
            
            %             apeak               = apeak(1);
            %             tmp.freq            = round(tmp.freq);
            %             cfg                 = [];
            %             cfg.method          = 'linear' ;
            %             cfg.foi             = [15 30];
            %             bpeak               = alpha_peak(cfg,tmp);
            %             bpeak               = bpeak(1);
            %             allpeaks(nchan,2)   = bpeak; clear bpeak;
            
            allpeaks(nchan,:)   = apeak; clear apeak tmp;
            
        end
        
        fname                   = ['../data/tf/' ext_name '.' peak_name '.alphapeak.mat'];
        fprintf('Saving %s\n',fname);
        save(fname,'allpeaks','-v7.3');
        
    end
end