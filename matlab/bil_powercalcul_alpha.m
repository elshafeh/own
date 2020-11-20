clear ; close all;

if isunix
    project_dir = '/project/3015079.01/';
else
    project_dir = 'P:/3015079.01/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

for ns = 1:length(suj_list)
    
    subjectName                             	= suj_list{ns};
    chk                                      	= [];
    
    fname                                       = [project_dir 'data/' subjectName '/preproc/' subjectName '_firstCueLock_ICAlean_finalrej.mat'];
    fprintf('\nloading %s\n',fname);
    load(fname);
    
    cfg                                         = [];
    cfg.latency                                 = [-0.9967 0];
    data_axial                                  = ft_selectdata(cfg,dataPostICA_clean);
    data_planar                                 = h_ax2plan(data_axial); clear data_axial dataPostICA_clean
    
    cfg                                         = [] ;
    cfg.output                                  = 'pow';
    cfg.method                                  = 'mtmfft';
    cfg.keeptrials                              = 'yes';
    cfg.pad                                     = 1;
    cfg.tapsmofrq    	                        = 0;
    cfg.foi                                     = 5:1:20;
    cfg.taper                                   = 'hanning';
    freq_planar                                 = ft_freqanalysis(cfg,data_planar);
    
    cfg                                         = [];
    cfg.method                                  = 'sum';
    freq_comb                                   = ft_combineplanar(cfg,freq_planar);
    
    pre_ori_trials                              = find(freq_comb.trialinfo(:,7) == 1 & freq_comb.trialinfo(:,8) == 1);
    pre_frq_trials                              = find(freq_comb.trialinfo(:,7) == 1 & freq_comb.trialinfo(:,8) == 2);
    rtr_ori_trials                              = find(freq_comb.trialinfo(:,7) == 2 & freq_comb.trialinfo(:,8) == 1);
    rtr_frq_trials                              = find(freq_comb.trialinfo(:,7) == 2 & freq_comb.trialinfo(:,8) == 2);
    
    pre_ori_trials                              = pre_ori_trials(randperm(length(pre_ori_trials)));
    pre_frq_trials                              = pre_frq_trials(randperm(length(pre_frq_trials)));
    rtr_ori_trials                              = rtr_ori_trials(randperm(length(rtr_ori_trials)));
    rtr_frq_trials                              = rtr_frq_trials(randperm(length(rtr_frq_trials)));
    
    % -- load max chan
    erf_ext_name                                = 'gratinglock.demean.erfComb.max20chan.p0p200ms';
    fname                                       = [project_dir 'data/' subjectName '/erf/' subjectName '.' erf_ext_name '.postOnset.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    for perc = 0.1:0.1:1
        
        trl_vct                                 = [];
        trl_vct                                 = [trl_vct; pre_ori_trials([1:round(length(pre_ori_trials)*perc)])];
        trl_vct                                 = [trl_vct; pre_frq_trials([1:round(length(pre_frq_trials)*perc)])];
        trl_vct                                 = [trl_vct; rtr_ori_trials([1:round(length(rtr_ori_trials)*perc)])];
        trl_vct                                 = [trl_vct; rtr_frq_trials([1:round(length(rtr_frq_trials)*perc)])];
        
        cfg                                     = [];
        cfg.trials                              = trl_vct;
        cfg.channel                             = max_chan;
        cfg.avgoverchan                         = 'yes';
        sub_freq                                = ft_selectdata(cfg,freq_comb);
        sub_freq.label                          = {'avg 20 occ chan'};
        
        cfg                                 	= [];
        cfg.method                              = 'maxabs' ;
        cfg.foi                             	= [7 15];
        apeak                                	= alpha_peak(cfg,sub_freq);
        apeak                                 	= apeak(1);
        
        [bin_summary]                           = h_preparebins(sub_freq,apeak,5,1);
        
        ext_name                                = [num2str(perc) 'perc'];
        fname                                   = [project_dir 'data/' subjectName '/tf/' subjectName '.cuelock.alpha.5bin' ext_name '.mat'];
        fprintf('\nSaving %s\n',fname);
        tic;save(fname,'bin_summary','apeak','-v7.3');toc;
        clear bin_summary sub_freq apeak
        
    end
end