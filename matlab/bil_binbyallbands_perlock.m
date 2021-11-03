clear ; clc;

load ../data/bil_goodsubjectlist.27feb20.mat

if isunix
    project_dir             = '/project/3015079.01/';
    start_dir               = '/project/';
else
    project_dir             = 'P:/3015079.01/';
    start_dir               = 'P:/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName             = suj_list{nsuj};
    
    dir_data              	= ['/project/3015079.01/data/' subjectName '/tf/'];
    fname                	= [dir_data subjectName '.firstcuelock.alphabetapeak.fft.mat'];
    load(fname);
    allpeaks(nsuj,1)        = [apeak];
    allpeaks(nsuj,2)        = [bpeak];
    
end

allpeaks(:,3)               = 4;

keep suj_list allpeaks ; clc;

i                           = 0;

for nsuj = 1:length(suj_list)
    
    subjectName             = suj_list{nsuj};
    
    if isunix
        subject_folder      = ['/project/3015079.01/data/' subjectName '/'];
    else
        subject_folder      = ['P:/3015079.01/data/' subjectName '/'];
    end
    
    list_band               = {'theta' 'alpha' 'beta'};
    list_width              = [1 1 2];
    
    erf_ext_name            = 'gratinglock.demean.erfComb.max20chan.p0p200ms';
    fname                   = [subject_folder '/erf/' subjectName '.' erf_ext_name '.postOnset.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    fname                   = [subject_folder 'preproc/' subjectName '_firstCueLock_ICAlean_finalrej.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    list_lock               = {'1stcue' '2ndcue' '1stgab' '2ndgab'};
    
    t1                     	= 1;
    t2                    	= 1.5;
    time_win             	= [t1 t2];
    
    cfg                  	= [];
    cfg.latency         	= [-t1 t2];
    data_axial{1}       	= ft_selectdata(cfg,dataPostICA_clean);
    data_axial{2}        	= bil_changelock_onlysecondcue(subjectName,time_win,dataPostICA_clean);
    
    data_axial{3}        	= bil_changelock_1stgab(subjectName,time_win,dataPostICA_clean); 
    data_axial{4}        	= bil_changelock_2ndgab(subjectName,time_win,dataPostICA_clean); 
    
    for nlock = 1:length(list_lock)
        
        if strcmp(list_lock{nlock},'1stcue')
            % pre cue
            find_trials   	= find(data_axial{nlock}.trialinfo(:,1) < 13);
        elseif strcmp(list_lock{nlock},'2ndcue')
            % retro
            find_trials   	= find(data_axial{nlock}.trialinfo(:,1) > 12);
        else
            find_trials   	= 1:length(data_axial{nlock}.trialinfo);
        end
        
        cfg                 = [];
        cfg.trials          = find_trials;
        cfg.latency         = [-0.9967 0];
        data                = ft_selectdata(cfg,data_axial{nlock});
        
        data_planar         = h_ax2plan(data);
            
        if length(data_planar.time{1}) ~= 300
            error('trials too short');
        end
        
        cfg                 = [] ;
        cfg.pad           	= 1;
        cfg.output        	= 'pow';
        cfg.method         	= 'mtmfft';
        cfg.keeptrials      = 'yes';
        cfg.foi             = 1:1:40;
        cfg.taper           = 'hanning';
        cfg.tapsmofrq       = 1;
        freq_planar         = ft_freqanalysis(cfg,data_planar);
        
        cfg                 = [];
        cfg.method          = 'sum';
        freq_comb           = ft_combineplanar(cfg,freq_planar);
        
        for nband = 1:length(list_band)
            
            cfg             = [];
            cfg.channel     = max_chan;
            freq_slct       = ft_selectdata(cfg,freq_comb);
            [bin_summary]  	= h_preparebins(freq_slct,allpeaks(nsuj,nband),5,list_width(nband));
            
            ext_binning     = 'allbandbinning.newpeaks';
            
            fname_out     	= [subject_folder 'tf/' subjectName '.' list_lock{nlock} '.lock.' ext_binning '.' ...
                list_band{nband} '.band.prestim.window.mat'];
            fprintf('saving %s\n',fname_out);
            save(fname_out,'bin_summary'); 
            
            bin_index       = bin_summary.bins;
            
            fname_out     	= [subject_folder 'tf/' subjectName '.' list_lock{nlock} '.lock.' ext_binning '.' ...
                list_band{nband} '.band.prestim.window.index.mat'];
            fprintf('save %s\n',fname_out);
            save(fname_out,'bin_index'); clear bin_summary fname_out;
            
        end
    end
end