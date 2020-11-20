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
    subject_folder                  = ['P:/3015079.01/data/' subjectName '/'];
    
    fname                           = [subject_folder 'preproc/' subjectName '_firstCueLock_ICAlean_finalrej.mat'];
    fprintf('\nloading %s\n',fname);
    load(fname);
    
    time_win                        = [2 7;1 5.2; 5 2;5 0.5];
    
    %     data_axial{1}                   = dataPostICA_clean;
    data_axial{2}                   = bil_changelock_onlyprobe(subjectName,time_win(2,:),dataPostICA_clean);
    %     data_axial{3}                   = bil_changelock_onlytarget(subjectName,time_win(3,:),dataPostICA_clean);
    %     data_axial{4}                   = bil_changelock_onlyresp(subjectName,time_win(4,:),dataPostICA_clean); clear dataPostICA_clean;
    
    list_lock                       = {'1stcue','1stgab','2ndgab','response'};
    
    for nlock = 2
        
        data_planar                 = h_ax2plan(data_axial{nlock});
        freq_list                	= [1:50 50:5:100];
        
        for nfoi = 1:length(freq_list)
            
            cfg                     = [] ;
            cfg.output              = 'pow';
            cfg.method              = 'mtmconvol';
            cfg.keeptrials          = 'yes';
            cfg.pad                 = 'maxperlen';
            cfg.foi                 = freq_list(nfoi);
            cfg.t_ftimwin           = ones(length(cfg.foi),1).*0.5;
            cfg.toi                 = -time_win(nlock,1) : 0.05 : time_win(nlock,2);
            cfg.taper               = 'hanning';
            cfg.tapsmofrq           = 0.1 *cfg.foi;
            freq_planar             = ft_freqanalysis(cfg,data_planar);
            
            cfg = []; cfg.method    = 'sum';
            freq_comb               = ft_combineplanar(cfg,freq_planar);
            freq_comb               = rmfield(freq_comb,'cfg');
            
            data                    = [];
            data.label              = freq_comb.label;
            %             data.grad               = freq_comb.grad;
            %             data.elec               = freq_comb.elec;
            data.trialinfo        	= freq_comb.trialinfo;
            data.fsample            = 1/0.05;
            data.trial              = {};
            data.time               = {};
            
            for xi = 1:length(freq_comb.trialinfo)
                data.trial{xi}      = squeeze(freq_comb.powspctrm(xi,:,:,:));
                data.time{xi}       = freq_comb.time;
            end
            
            index                   = freq_comb.trialinfo;
            
            fname_out               = ['F:/bil/preproc/' subjectName '.' list_lock{nlock} '.lock.' num2str(freq_list(nfoi)) 'Hz.centered.mat'];
            fprintf('Saving %s\n',fname_out);
            save(fname_out,'data','-v7.3');
            
            fname_out               = ['F:/bil/preproc/' subjectName '.' list_lock{nlock} '.lock.' num2str(freq_list(nfoi)) 'Hz.centered.trialinfo.mat'];
            fprintf('Saving %s\n',fname_out);
            tic;save(fname_out,'index');toc;
            
            clear index freq_comb freq_planar
            
        end
    end
end