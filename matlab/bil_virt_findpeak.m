clear ; clc;

if isunix
    start_dir             = '/project/';
else
    start_dir             = 'P:/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    %% load in data
    ext_virt                = 'wallis';
    
    subjectName             = suj_list{nsuj};
    subject_folder          = 'I:/bil/virt/'; 
    fname                   = [subject_folder subjectName '.virtualelectrode.' ext_virt '.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    lmt                     = -1 + (1/data.fsample);
    peak_window             = [lmt 0];
    
    %     peak_name               = [];
    %     for nt = 1:2
    %         if peak_window(nt) > 0
    %             peak_name       = [peak_name 'p' num2str(abs(peak_window(nt)*1000))];
    %         else
    %             peak_name       = [peak_name 'm' num2str(abs(peak_window(nt)*1000))];
    %         end
    %     end
    %     peak_name               = [peak_name 'ms'];
    
    cfg                     = [];
    cfg.latency             = peak_window;
    sub_data             	= ft_selectdata(cfg, data); % select corresponding data
    
    %% find alpha peak
    
    cfg                     = [] ;
    cfg.output              = 'pow';
    cfg.method              = 'mtmfft';
    cfg.keeptrials          = 'yes';
    cfg.foi                 = 7:15;
    cfg.taper               = 'hanning';
    cfg.tapsmofrq           = 0 ;
    freq_alpha            	= ft_freqanalysis(cfg,data);
    
    allpeaks                = [];
    
    for nchan = 1:length(freq_alpha.label)
        
        tmp                 = freq_alpha;
        tmp.powspctrm       = tmp.powspctrm(:,nchan,:);
        tmp.label           = tmp.label(nchan);
        
        cfg                 = [];
        cfg.method          = 'maxabs' ;
        cfg.foi             = [7 15];
        apeak               = alpha_peak(cfg,tmp);
        
        allpeaks(nchan,1)   = apeak(1); clear apeak tmp;
        
    end
    
    clear freq_alpha
    
    %% find beta peak
    
    cfg                     = [] ;
    cfg.output              = 'pow';
    cfg.method              = 'mtmfft';
    cfg.keeptrials          = 'yes';
    cfg.foi                 = 15:35;
    cfg.taper               = 'hanning';
    cfg.tapsmofrq           = 1;
    freq_beta            	= ft_freqanalysis(cfg,data);
        
    for nchan = 1:length(freq_beta.label)
        
        tmp                 = freq_beta;
        tmp.powspctrm       = tmp.powspctrm(:,nchan,:);
        tmp.label           = tmp.label(nchan);
        
        cfg             	= [];
        cfg.method      	= 'linear' ;
        cfg.foi           	= [15 35];
        bpeak            	= alpha_peak(cfg,tmp);
        
        allpeaks(nchan,2)   = bpeak(1); clear apeak tmp;
        
    end
    
    clear freq_beta
    
    %% save data
    
    fname                   = ['D:\Dropbox\project_me\data\bil\virt\' subjectName '.' ext_virt '.alpha.beta.peak.mat'];
    fprintf('Saving %s\n',fname);
    save(fname,'allpeaks');
    
end