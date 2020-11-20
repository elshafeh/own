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
    
    data_axial                              	= dataPostICA_clean; clear dataPostICA_clean;
    data_planar                                 = h_ax2plan(data_axial); clear data_axial;
    
    % col7 -> task
    % col8 -> cue
    
    erf_ext_name                                = 'gratinglock.demean.erfComb.max20chan.p0p200ms';
    fname                                       = [project_dir 'data/' subjectName '/erf/' subjectName '.' erf_ext_name '.postOnset.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    time_win1                                   = -0.1;
    time_win2                                   = 6.5;
    
    cfg                                         = [];
    cfg.output                                  = 'fourier';
    cfg.method                                  = 'mtmconvol';
    cfg.taper                                   = 'hanning';
    cfg.foi                                     = 2:1:7;
    cfg.toi                                     = time_win1:0.05:time_win2;
    cfg.t_ftimwin                               = ones(length(cfg.foi),1).*0.5;   % 5 cycles
    cfg.trials                              	= find(data_planar.trialinfo(:,16) == 1); % choose correct trials [keep that in mind for later
    cfg.keeptrials                              = 'yes';
    cfg.pad                                     = 10;
    cfg.channel                                 = 'M*O*';
    freq_planar                                 = ft_freqanalysis(cfg,data_planar);
    
    cfg                                         = []; cfg.method = 'svd';
    freq_comb                                   = ft_combineplanar(cfg,freq_planar);
    freq_comb                                   = rmfield(freq_comb,'cfg');
    
    cfg                                         = [];
    cfg.channel                                 = max_chan;
    freq_comb                                   = ft_selectdata(cfg,freq_comb);
    freq_comb                                   = rmfield(freq_comb,'cfg');
    
    pre_ori_trials                              = find(freq_comb.trialinfo(:,7) == 1 & freq_comb.trialinfo(:,8) == 1);
    pre_frq_trials                              = find(freq_comb.trialinfo(:,7) == 1 & freq_comb.trialinfo(:,8) == 2);
    rtr_ori_trials                              = find(freq_comb.trialinfo(:,7) == 2 & freq_comb.trialinfo(:,8) == 1);
    rtr_frq_trials                              = find(freq_comb.trialinfo(:,7) == 2 & freq_comb.trialinfo(:,8) == 2);
    
    pre_ori_trials                              = pre_ori_trials(randperm(length(pre_ori_trials)));
    pre_frq_trials                              = pre_frq_trials(randperm(length(pre_frq_trials)));
    rtr_ori_trials                              = rtr_ori_trials(randperm(length(rtr_ori_trials)));
    rtr_frq_trials                              = rtr_frq_trials(randperm(length(rtr_frq_trials)));
    
    for perc = 0.1:0.1:1
        
        trl_vct                                 = [];
        trl_vct                                 = [trl_vct; pre_ori_trials([1:round(length(pre_ori_trials)*perc)])];
        trl_vct                                 = [trl_vct; pre_frq_trials([1:round(length(pre_frq_trials)*perc)])];
        trl_vct                                 = [trl_vct; rtr_ori_trials([1:round(length(rtr_ori_trials)*perc)])];
        trl_vct                                 = [trl_vct; rtr_frq_trials([1:round(length(rtr_frq_trials)*perc)])];
        
        cfg                                     = [];
        cfg.trials                              = trl_vct;
        sub_freq                                = ft_selectdata(cfg,freq_comb);
        
        all_rt                                  = [[1:length(sub_freq.trialinfo)]'  sub_freq.trialinfo(:,14)];
        all_rt                                  = sortrows(all_rt,2);
        
        [indx]                                  = calc_tukey(all_rt(:,2));
        all_rt                                  = all_rt(indx,:);
        
        nb_bin                                  = 5;
        bin_size                                = floor(length(all_rt)/nb_bin);
        
        for nb = 1:nb_bin
            
            lm1                                 = 1+bin_size*(nb-1);
            lm2                                 = bin_size*nb;
            
            cfg                                 = [];
            cfg.indexchan                       = 'all';
            
            cfg.index                           = all_rt(lm1:lm2,1);
            cfg.alpha                           = 0.05;
            cfg.time                            = [-0.1 6.5];
            cfg.freq                            = [2 7];
            
            tmp                                 = mbon_PhaseLockingFactor(sub_freq, cfg);
            
            tmp                                 = rmfield(tmp,'rayleigh');
            tmp                             	= rmfield(tmp,'p');
            tmp                                 = rmfield(tmp,'sig');
            tmp                                 = rmfield(tmp,'mask');
            
            tmp.powspctrm                       = nanmean(tmp.powspctrm,1);
            tmp.label                           = {'avg 20 occ chan'};
            tmp.med_rt                          = median(all_rt(lm1:lm2,2));
            tmp.index                           = cfg.index;
            
            phase_lock{nb}                      = tmp; clear tmp;
            
        end
        
        ext_name                                = [num2str(perc) 'perc'];
        fname                                   = [project_dir 'data/' subjectName '/tf/' subjectName '.cuelock.itc.' num2str(nb_bin) 'bin' ext_name '.mat'];
        fprintf('\nSaving %s\n',fname);
        tic;save(fname,'phase_lock','-v7.3');toc;
        clear phase_lock sub_freq
        
    end
end