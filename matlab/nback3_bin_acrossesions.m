clear ; close all; global ft_default
ft_default.spmversion = 'spm12';

suj_list                                    = [16:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    subjectname                             = ['sub' num2str(suj_list(nsuj))];
    
    % load peak
    fname                                   = ['~/Dropbox/project_me/data/nback/peak/' subjectname '.alphabeta.peak.package.0back.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    allpeaks(nsuj,1)                        = 3;
    allpeaks(nsuj,2)                        = apeak; clear apeak;
    allpeaks(nsuj,3)                        = bpeak; clear bpeak;
    allpeaks(nsuj,4)                        = 50;
    allpeaks(nsuj,5)                        = 70;
    
    where_beta                              = 3;
    
end

allpeaks(isnan(allpeaks(:,where_beta)),where_beta) 	= round(nanmean(allpeaks(:,where_beta)));

keep suj_list allpeaks ; clc ;

%%

for nsuj = 1:length(suj_list)
    
    bin_summary                             = [];
    i                                       = 0;
    
    for nsess = 1:2
        
        % load peak
        fname                               = ['~/Dropbox/project_me/data/nback/peak/sub' num2str(suj_list(nsuj)) '.alphabeta.peak.package.0back.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        
        fname                               = ['~/Dropbox/project_me/data/nback/prepro/nback_' num2str(nsess) '/data_sess' num2str(nsess) '_s' num2str(suj_list(nsuj)) '.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        
        %-%-% exclude trials with a previous response + 0back
        cfg                                 = [];
        cfg.trials                          = find(data.trialinfo(:,5) == 0 & data.trialinfo(:,1) ~= 4);
        data                                = ft_selectdata(cfg,data);
        
        sess_carr{nsess}                    = megrepair(data); 
        sess_norepair{nsess}                = data; clear data; % we need this cause the non-repaired data doesn't work with MNE-python
        
    end
    
    %-%-% appenddata across
    data_concat                           	= ft_appenddata([],sess_carr{:}); clear sess_carr
    
    %-%-% low pass filtering for ERFs
    cfg                                     = [];
    cfg.demean                              = 'yes';
    cfg.baselinewindow                      = [-0.1 0];
    cfg.lpfilter                            = 'yes';
    cfg.lpfreq                              = 20;
    data_preproc                            = ft_preprocessing(cfg,data_concat);
    
    %-%-% downsample for decoding
    
    cfg_demean                              = 'no';
    
    cfg                                     = [];
    cfg.resamplefs                          = 100;
    cfg.detrend                             = 'no';
    cfg.demean                              = cfg_demean;
    data_downsample                         = ft_resampledata(cfg,  ft_appenddata([],sess_norepair{:}));
    data_downsample                         = rmfield(data_downsample,'cfg');
    
    %-%-% rearragnge trialinfo
    trialinfo(:,1)                       	= data_concat.trialinfo(:,1); % condition
    trialinfo(:,2)                       	= data_concat.trialinfo(:,3); % stim category 
    trialinfo(:,3)                        	= rem(data_concat.trialinfo(:,2),10)+1; % stim identity
    trialinfo(:,4)                       	= data_concat.trialinfo(:,6); % response
    trialinfo(:,5)                       	= data_concat.trialinfo(:,7); % rt
    trialinfo(:,6)                        	= 1:length(data_concat.trialinfo); % trial indices to match with bin
    
    %-%-% add it to all data to make sure nothing goes wrong
    data_concat.trialinfo                   = trialinfo;
    data_preproc.trialinfo                	= trialinfo;
    data_downsample.trialinfo              	= trialinfo; clear trialinfo
    
    %-%-% select window for FFT 
    cfg                                     = [];
    cfg.toilim                              = [-0.498 0];
    data_slct                               = ft_redefinetrial(cfg,data_concat);
    
    %-%-% compute FFT
    cfg                                     = [] ;
    cfg.output                              = 'pow';
    cfg.method                              = 'mtmfft';
    cfg.keeptrials                          = 'yes';
    cfg.pad                                 = 1;
    cfg.taper                               = 'hanning';
    cfg.foi                                 = [1:48 52:90];
    cfg.tapsmofrq                           = 0.1 *cfg.foi;
    freq                                    = ft_freqanalysis(cfg,data_slct);
    freq                                    = rmfield(freq,'cfg');
    freq_comb                               = ft_combineplanar([],freq); clear freq;
    
    %-%-% zoom on occipital channels
    %-%-% we zoom in afterwards (not before) due to some combine planar
    % problems
    cfg                                     = [];
    cfg.channel                             = max_chan;
    freq                                    = ft_selectdata(cfg,freq_comb); clear freq_comb;
    
    list_band                               = {'slow' 'alpha' 'beta' 'gamma1' 'gamma2'};
    list_width                              = [2 1 2 10 10];
    
    for nband = 1:length(list_band)
        
        nb_bin                              = 3;
        [tmp_summary]                       = nback_func_preparebin_sessionconcat(freq,allpeaks(nsuj,nband),nb_bin,list_width(nband));
        
        for nbin = 1:nb_bin
            
            %-%-% save information
            i                               = i+1;
            bin_summary(i).sub              = ['sub' suj_list(nsuj)];
            bin_summary(i).band             = list_band{nband};
            bin_summary(i).bin              = ['b' num2str(nbin)];
            bin_summary(i).acc              = tmp_summary.perc_corr(nbin);
            bin_summary(i).rt               = tmp_summary.med_rt(nbin);
            bin_summary(i).index            = tmp_summary.bins(:,nbin);
            bin_summary(i).trialinfo      	= freq.trialinfo(tmp_summary.bins(:,nbin),:);
            bin_summary(i).trialcount      	= [];
            
            for ncond = [1 2] % nback
                for nstim = [1 2] % first/target
                    
                    flg_trials          	= bin_summary(i).trialinfo;
                    flg_trials          	= find(flg_trials(:,1) == ncond+4 & flg_trials(:,2) == nstim);
                    bin_summary(i).trialcount(ncond,nstim)  = length(flg_trials);
                    
                end
            end
            
            %-%-% compute ERFs and save
            cfg                             = [];
            cfg.trials                      = bin_summary(i).index;
            avg                             = ft_timelockanalysis(cfg, data_preproc);
            avg_comb                        = ft_combineplanar([],avg);
            avg_comb                        = rmfield(avg_comb,'cfg'); clc;
            
            dir_out                         = '~/Dropbox/project_me/data/nback/erf/';
            fname_out                       = [dir_out 'sub' num2str(suj_list(nsuj)) '.' list_band{nband} '.' num2str(nb_bin) 'binsb' num2str(nbin) '.erfComb.mat'];
            fprintf('Saving %s\n',fname_out);
            tic;save(fname_out,'avg_comb','-v7.3');toc
            
            %-%-% Save data + trialinfo for decoding
            cfg                             = [];
            cfg.trials                      = bin_summary(i).index;
            data                            = ft_selectdata(cfg,data_downsample);
            data                            = rmfield(data,'cfg');
            index                           = data.trialinfo;
            
            dir_out                         = '~/Dropbox/project_me/data/nback/bin_decode/preproc/';
            ext_name_out                    = [dir_out 'sub' num2str(suj_list(nsuj)) '.' list_band{nband} '.' num2str(nb_bin) 'binsb' num2str(nbin) '.4binningDecoding.' cfg_demean 'demean'];
            fname_out                    	= [ext_name_out '.mat'];
            fprintf('Saving %s\n',fname_out);
            tic;save(fname_out,'data','-v7.3');toc;
            
            fname_out                     	= [ext_name_out '.trialinfo.mat'];
            fprintf('Saving %s\n',fname_out);
            tic;save(fname_out,'index');toc;
            
            clear avg avg_comb data index
            
        end
    end

    ext_bin_name        = ['exl500concat' num2str(nb_bin) 'bins'];
    fname_out         	= ['~/Dropbox/project_me/data/nback/bin/sub' num2str(suj_list(nsuj)) '.' ext_bin_name '.binsummary.mat'];
    fprintf('saving %s\n',fname_out);
    save(fname_out,'bin_summary');
    
    keep nsuj suj_list allpeaks ext_bin_name
    
end