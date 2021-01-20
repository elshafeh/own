clear ; close all; global ft_default
ft_default.spmversion = 'spm12';

suj_list                                            = [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    subjectname                                     = ['sub' num2str(suj_list(nsuj))];
    
    % load peak
    fname                                           = ['/Volumes/heshamshung/nback/peak/' subjectname '.alphabeta.peak.package.0back.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    allpeaks(nsuj,1)                                = 3; 
    allpeaks(nsuj,2)                                = apeak; clear apeak;
    allpeaks(nsuj,3)                                = bpeak; clear bpeak;
    allpeaks(nsuj,4)                                = 50;
    allpeaks(nsuj,5)                                = 70;
    
    where_beta                                      = 3;
    
end

allpeaks(isnan(allpeaks(:,where_beta)),where_beta) 	= round(nanmean(allpeaks(:,where_beta)));

keep suj_list allpeaks ; clc  ;

%%

for nsuj = 1:length(suj_list)
    
    bin_summary                                     = [];
    i                                               = 0;
    for nsess = 1:2
        
        % load peak
        fname                                       = ['/Volumes/heshamshung/nback/peak/sub' num2str(suj_list(nsuj)) '.alphabeta.peak.package.0back.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        
        fname                                       = ['/Volumes/heshamshung/nback/nback_' num2str(nsess) '/data_sess' num2str(nsess) '_s' num2str(suj_list(nsuj)) '.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        
        %-%-% exclude trials with a previous response
        cfg                                         = [];
        cfg.trials                                  = find(data.trialinfo(:,5) == 0);
        data                                        = ft_selectdata(cfg,data);
        data                                        = megrepair(data);
        
        list_back                                   = [5 6];
        list_name                                   = {'1back','2back'};
        list_stim                                   = {'first','target'};
        list_band                                   = {'slow' 'alpha' 'beta' 'gamma1' 'gamma2'};
        list_width                                  = [2 1 2 10 10];
        
        for ncond = 1:length(list_name)
            for nstim = 1:length(list_stim)
                
                flg_trials                          = find(data.trialinfo(:,1) == list_back(ncond) & data.trialinfo(:,3) == nstim);
                
                if ~isempty(flg_trials)
                    
                    cfg                             = [];
                    cfg.toilim                      = [-0.498 0];
                    data_slct                       = ft_redefinetrial(cfg,data);
                    
                    cfg                             = [] ;
                    cfg.output                      = 'pow';
                    cfg.method                      = 'mtmfft';
                    cfg.keeptrials                  = 'yes';
                    cfg.pad                         = 1;
                    cfg.taper                       = 'hanning';
                    cfg.foi                         = [1:48 52:90];
                    cfg.tapsmofrq                   = 0.1 *cfg.foi;
                    cfg.trials                      = flg_trials;
                    freq                            = ft_freqanalysis(cfg,data_slct);
                    freq                            = rmfield(freq,'cfg');
                    freq_comb                       = ft_combineplanar([],freq); clear freq;
                    
                    % select peak-window
                    cfg                             = [];
                    cfg.channel                     = max_chan;
                    freq                            = ft_selectdata(cfg,freq_comb); clear freq_comb;
                    
                    for nband = 1:length(list_band)
                        
                        [tmp_summary]               = nback_func_preparebin(freq,allpeaks(nsuj,nband),2,list_width(nband));
                        
                        for nbin = [1 2]
                                    
                            i                       = i+1;
                            
                            bin_summary(i).sub      = ['sub' suj_list(nsuj)];
                            bin_summary(i).band     = list_band{nband};
                            bin_summary(i).stim     = list_stim{nstim};
                            bin_summary(i).cond     = list_name{ncond};
                            bin_summary(i).bin  	= ['b' num2str(nbin)];
                            
                            bin_summary(i).acc      = tmp_summary.perc_corr(nbin);
                            bin_summary(i).rt       = tmp_summary.med_rt(nbin);
                            
                            bin_summary(i).sess     = ['s' num2str(nsess)];
                            bin_summary(i).index 	= tmp_summary.bins(:,nbin);
                            
                            
                        end
                    end
                end
            end
        end
    end
    
    ext_bin_name        = 'excludemotor500pre';
    fname_out         	= ['/Volumes/heshamshung/nback/bin/sub' num2str(suj_list(nsuj)) '.' ext_bin_name '.binsummary.mat'];
    fprintf('saving %s\n',fname_out);
    save(fname_out,'bin_summary');
    
    keep nsuj suj_list allpeaks ext_bin_name
    
end

nback3_bin2R(ext_bin_name);