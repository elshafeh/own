clear ; clc;

if isunix
    start_dir             = '/project/';
else
    start_dir             = 'P:/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName             = suj_list{nsuj};
    subject_folder          = ['/project/3015079.01/data/' subjectName '/'];
    fname                   = [subject_folder 'preproc/' subjectName '_firstCueLock_ICAlean_finalrej.mat'];
    fprintf('\nloading %s\n',fname);
    load(fname);
    
    % IMPORTANT!! ->  we don't exclude blocks with perfoamces either at chance
    % or celing
    % data_axial         	= h_excludebehav(dataPostICA_clean,13,16); clear dataPostICA_clean;
    
    data_axial              = dataPostICA_clean;
    data_planar             = h_ax2plan(data_axial);
    
    indx_rt                 = data_axial.trialinfo(:,14);
    indx_rt(indx_rt(:,1) < median(indx_rt(:,1)),2) = 1;
    indx_rt(indx_rt(:,1) > median(indx_rt(:,1)),2) = 2;
    
    trialinfo               = data_axial.trialinfo;
    trialinfo(trialinfo(:,16) == 0,16)     = 2; % change correct to 1(corr) and 2(incorr)
    trialinfo               = trialinfo(:,[7 8 16]); % 1st column is task , 2nd is cue and 3 correct
    trialinfo               = [trialinfo indx_rt(:,2)]; % col.4 is RT
    trialinfo               = [trialinfo [1:length(trialinfo)]']; % col 5 in index 
    
    list_task               = {'ori','freq'};
    list_cue                = {'pre','retro'};
    list_corr               = {'correct','incorrect'};
    list_rt                 = {'fast','slow'};
    
    for ntask = 1:2
        for ncue = 1:2
            for ncorrect = 1:2
                for nrt = 1:2
                    
                    cfg                 = [] ;
                    cfg.output          = 'pow';
                    cfg.method          = 'mtmconvol';
                    cfg.keeptrials      = 'no';
                    cfg.pad             = 'maxperlen';
                    cfg.foi             = [1:1:40 42:2:100];
                    cfg.t_ftimwin       = ones(length(cfg.foi),1).*0.5;
                    cfg.toi             = -1:0.02:7;
                    cfg.taper           = 'hanning';
                    cfg.tapsmofrq    	= 0.1 *cfg.foi;
                    cfg.trials          = trialinfo(trialinfo(:,1) == ntask & trialinfo(:,2) == ncue & trialinfo(:,3) == ncorrect & trialinfo(:,4) == nrt,5);
                    
                    if ~isempty(cfg.trials)
                    ext_freq            = h_freqparam2name(cfg);
                    freq_planar         = ft_freqanalysis(cfg,data_planar);
                    
                    cfg = []; cfg.method = 'sum';
                    freq_comb           = ft_combineplanar(cfg,freq_planar);
                    freq_comb           = rmfield(freq_comb,'cfg');
                    
                    ext_fname           = [list_task{ntask} '.' list_cue{ncue} '.' list_corr{ncorrect} '.' list_rt{nrt}];
                    
                    dir_data            = '/project/3015039.06/hesham/bil/tf/';
                    fname               = [dir_data subjectName '.cuelock.' ext_freq '.'  ext_fname '.mat'];
                    fprintf('\nSaving %s\n',fname);
                    save(fname,'freq_comb','-v7.3'); clear freq_comb;
                    end
                    
                end
            end
        end
    end
end