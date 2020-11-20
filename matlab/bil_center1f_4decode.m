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

for nsuj = 1:16 %length(suj_list)
    
    subjectName                     = suj_list{nsuj};
    subject_folder                  = ['/project/3015079.01/data/' subjectName '/'];
    
    list_foi{1}                     = [3:1:5];
    list_foi{2}                     = [allpeaks(nsuj,1)-1 : 1 : allpeaks(nsuj,1)+1];
    list_foi{3}                     = [allpeaks(nsuj,2)-2 : 1 : allpeaks(nsuj,2)+2];
    list_foi{4}                     = [60:5:100];
    
    fname                           = [subject_folder 'preproc/' subjectName '_firstCueLock_ICAlean_finalrej.mat'];
    fprintf('\nloading %s\n',fname);
    load(fname);
    
    time_win                        = [2 7;1 5.2; 5 2;5 0.5];
    
    cfg                             = [];
    cfg.derivative                  = 'yes';
    dataPostICA_clean            	= ft_preprocessing(cfg,dataPostICA_clean);
    
    data_axial{1}                   = dataPostICA_clean;
    data_axial{2}                   = bil_changelock_1stgab(subjectName,time_win(2,:),dataPostICA_clean);
    data_axial{3}                   = bil_changelock_2ndgab(subjectName,time_win(3,:),dataPostICA_clean); clear dataPostICA_clean;
    %     data_axial{4}                   = bil_changelock_onlyresp(subjectName,time_win(4,:),dataPostICA_clean);
    
    list_name                       = {'theta.minus1f','alpha.minus1f','beta.minus1f','gamma.minus1f'};
    list_lock                       = {'1stcue','1stgab','2ndgab','response'};
    
    for nlock = 1:length(data_axial)
        
        data_planar                 = h_ax2plan(data_axial{nlock});
        
        for nfoi = 1:length(list_foi)
            
            cfg                     = [] ;
            cfg.output              = 'pow';
            cfg.method              = 'mtmconvol';
            cfg.keeptrials          = 'yes';
            cfg.pad                 = 'maxperlen';
            cfg.foi                 = list_foi{nfoi};
            cfg.t_ftimwin           = ones(length(cfg.foi),1).*0.5;
            cfg.toi                 = -time_win(nlock,1) : 0.05 : time_win(nlock,2);
            cfg.taper               = 'hanning';
            cfg.tapsmofrq           = 0.1 *cfg.foi;
            freq_planar             = ft_freqanalysis(cfg,data_planar);
            
            cfg = []; cfg.method    = 'sum';
            freq_comb               = ft_combineplanar(cfg,freq_planar);
            freq_comb               = rmfield(freq_comb,'cfg');
            
            cfg                     = [];
            cfg.avgoverfreq         = 'yes';
            cfg.nanmean             = 'yes';
            freq_comb               = ft_selectdata(cfg,freq_comb);
            
            data                    = [];
            data.label              = freq_comb.label;
            data.trialinfo        	= freq_comb.trialinfo;
            data.fsample          	= 1/0.05;
            
            data.trial              = {};
            data.time               = {};
            
            for xi = 1:length(freq_comb.trialinfo)
                data.trial{xi}      = squeeze(freq_comb.powspctrm(xi,:,:,:));
                data.time{xi}       = freq_comb.time;
            end
            
            index                   = freq_comb.trialinfo;
            
            fname_out               = [subject_folder 'preproc/' subjectName '.' list_lock{nlock} '.lock.' list_name{nfoi} '.centered.mat'];
            fprintf('Saving %s\n',fname_out);
            save(fname_out,'data','-v7.3');
            
            fname_out               = [subject_folder 'preproc/' subjectName '.' list_lock{nlock} '.lock.' list_name{nfoi} '.centered.trialinfo.mat'];
            fprintf('Saving %s\n',fname_out);
            tic;save(fname_out,'index');toc;
            
            clear index freq_comb freq_planar
            
        end
        
    end
end