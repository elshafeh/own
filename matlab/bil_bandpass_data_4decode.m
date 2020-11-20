clear ; clc;

load ../data/bil_goodsubjectlist.27feb20.mat

if isunix
    project_dir                     = '/project/3015079.01/';
    start_dir                       = '/project/';
else
    project_dir                     = 'P:/3015079.01/';
    start_dir                       = 'P:/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName                     = suj_list{nsuj};
    
    fname                           = [project_dir 'data/' subjectName '/tf/' subjectName '.firstcuelock.freqComb.alphaPeak.m1000m0ms.gratinglock.demean.erfComb.max20chan.p0p200ms.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    allpeaks(nsuj,1)                = [apeak];
    
    fname                           = [project_dir 'data/' subjectName '/tf/' subjectName '.firstcuelock.1overf.orig.alphabetaPeak.' ...
        'm1000m0ms.mat'];
    load(fname);
    allpeaks(nsuj,2)                = [bpeak_orig];
    
end

allpeaks(isnan(allpeaks(:,2)),2)    = nanmean(allpeaks(:,2));
allpeaks                            = round(allpeaks);

keep suj_list allpeaks ; clc;

for nsuj = 1:length(suj_list)
    
    subjectName                     = suj_list{nsuj};
    subject_folder                  = ['P:/3015079.01/data/' subjectName '/'];
    
    list_foi{1}                     = [3 5];
    list_foi{2}                     = [allpeaks(nsuj,1)-1 allpeaks(nsuj,1)+1];
    list_foi{3}                     = [allpeaks(nsuj,2)-2 allpeaks(nsuj,2)+2];
    list_foi{4}                     = [60 99];
    
    fname                           = [subject_folder 'preproc/' subjectName '_firstCueLock_ICAlean_finalrej.mat'];
    fprintf('\nloading %s\n',fname);
    load(fname);
    
    cfg                         	= [];
    cfg.resamplefs                  = 200;
    cfg.detrend                  	= 'no';
    cfg.demean                  	= 'no';
    data_nofilt                   	= ft_resampledata(cfg, dataPostICA_clean); clear dataPostICA_clean;
    
    for nfoi = 1:length(list_foi)
        
        cfg                         = [];
        cfg.bpfilter                = 'yes';
        cfg.bpfreq                  = list_foi{nfoi};
        cfg.bpfiltord               = 3;
        cfg.padding                 = 10;
        dataPostICA_clean        	= ft_preprocessing(cfg,data_nofilt);
        
        time_win                	= [2 7;1 5.2; 5 2;5 0.5];
        
        data_axial{1}           	= dataPostICA_clean;
        data_axial{2}           	= bil_changelock_onlyprobe(subjectName,time_win(2,:),dataPostICA_clean);
        data_axial{3}            	= bil_changelock_onlytarget(subjectName,time_win(3,:),dataPostICA_clean);
        data_axial{4}             	= bil_changelock_onlyresp(subjectName,time_win(4,:),dataPostICA_clean); 
        
        clear dataPostICA_clean;
        
        list_name               	= {'theta','alpha','beta','gamma'};
        list_lock                	= {'1stcue','1stgab','2ndgab','response'};
        
        for nlock = 1:length(data_axial)
            
            % choose correct trials (not for response locked)
            if strcmp(list_lock{nlock},'response')
                data                = data_axial{nlock};
            else
                cfg              	= [];
                cfg.trials       	= find(data_axial{nlock}.trialinfo(:,16) == 1);
                data             	= ft_selectdata(cfg,data_axial{nlock});
            end
            
            data                    = rmfield(data,'cfg');
            index                   = data.trialinfo;
            
            ext_name                = ['F:/bil/preproc/' subjectName '.' list_lock{nlock} '.lock.' list_name{nfoi} '.bandpassed'];
            
            fname_out               = [ext_name '.mat'];
            fprintf('Saving %s\n',fname_out);
            save(fname_out,'data','-v7.3');
            
            fname_out               = [ext_name '.trialinfo.mat'];
            fprintf('Saving %s\n',fname_out);
            tic;save(fname_out,'index');toc;
            
            clear index freq_comb freq_planar
            
        end
        
    end
end