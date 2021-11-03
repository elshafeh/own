clear ; close all; global ft_default
ft_default.spmversion = 'spm12';

suj_list                                    = [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    subjectname                             = ['sub' num2str(suj_list(nsuj))];
    
    % load peak
    ext_peak_file                           = 'restrict';
    dir_data                                = '~/Dropbox/project_me/data/nback/peak/';
    fname                                   = [dir_data subjectname '.alphabeta.peak.package.0back.' ext_peak_file '.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    allpeaks(nsuj,1)                        = apeak; clear apeak;
    allpeaks(nsuj,2)                        = bpeak; clear bpeak;
        
    allchan{nsuj}                           = max_chan;
    
end

% where_beta                              = 2;
% allpeaks(isnan(allpeaks(:,where_beta)),where_beta) 	= round(nanmean(allpeaks(:,where_beta)));

keep suj_list all* ext_peak_file; clc ;

%%

for nsuj = 1:length(suj_list)
    
    bin_summary                             = [];
    i                                       = 0;
    
    for nsess = 1:2
        
        dir_data                            = ['~/Dropbox/project_me/data/nback/prepro/nback_' num2str(nsess) '/'];
        fname                               = [dir_data 'data_sess' num2str(nsess) '_s' num2str(suj_list(nsuj)) '.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        
        %-%-% exclude trials with a previous response + 0back
        cfg                                 = [];
        cfg.trials                          = find(data.trialinfo(:,5) == 0 & data.trialinfo(:,1) ~= 4);
        data                                = ft_selectdata(cfg,data);
        
        sess_carr{nsess}                    = megrepair(data);
        sess_norepair{nsess}                = data; clear data; % we need this cause the non-repaired data doesn't work with MNE-python
        
    end
    
    %-%-% append data across sessions
    data_concat                           	= ft_appenddata([],sess_carr{:}); clear sess_carr
    
    %-%-% rearragnge trialinfo
    trialinfo(:,1)                       	= data_concat.trialinfo(:,1); % condition
    trialinfo(:,2)                       	= data_concat.trialinfo(:,3); % stim category
    trialinfo(:,3)                        	= rem(data_concat.trialinfo(:,2),10)+1; % stim identity
    trialinfo(:,4)                       	= data_concat.trialinfo(:,6); % response
    trialinfo(:,5)                       	= data_concat.trialinfo(:,7); % rt
    trialinfo(:,6)                        	= 1:length(data_concat.trialinfo); % trial indices to match with bin
    
    %-%-% add it to data to make sure nothing goes wrong
    data_concat.trialinfo                   = trialinfo; clear trialinfo
    
    %     %-%-% low pass filtering for ERFs
    %     cfg                                     = [];
    %     cfg.demean                              = 'yes';
    %     cfg.baselinewindow                      = [-0.1 0];
    %     cfg.lpfilter                            = 'yes';
    %     cfg.lpfreq                              = 20;
    %     data_preproc                            = ft_preprocessing(cfg,data_concat);
    
    list_time_window                        = [-0.499 0]; %; 0 0.499];
    list_time_name                          = {'pre'}; % 'post'};
    
    for ntime = 1:length(list_time_name)
        
        %-%-% select window for FFT
        cfg                               	= [];
        cfg.toilim                      	= list_time_window(ntime,:);
        data_slct                         	= ft_redefinetrial(cfg,data_concat);
        
        %-%-% compute FFT
        cfg                               	= [] ;
        cfg.output                        	= 'pow';
        cfg.method                       	= 'mtmfft';
        cfg.keeptrials                   	= 'yes';
        cfg.pad                           	= 1;
        cfg.taper                       	= 'hanning';
        cfg.foi                          	= 1:40;
        cfg.tapsmofrq                     	= 0;
        freq                             	= ft_freqanalysis(cfg,data_slct);
        freq                              	= rmfield(freq,'cfg');
        freq_comb                        	= ft_combineplanar([],freq); clear freq;
        
        %-%-% zoom on occipital channels
        %-%-% we zoom in afterwards (not before) due to some combine planar
        % problems
        cfg                              	= [];
        cfg.channel                      	= allchan{nsuj};
        freq                              	= ft_selectdata(cfg,freq_comb); clear freq_comb;
        
        list_band                         	= {'alpha' 'beta'};
        list_width                       	= [1 2];
        
        for nband = 1:length(list_band)
            
            nb_bin                        	= 3;
            [tmp_summary]                 	= nback_func_preparebin_sessionconcat(freq,allpeaks(nsuj,nband),nb_bin,list_width(nband));
            
            for nbin = 1:nb_bin
                
                %-%-% save information
                i                        	= i+1;
                bin_summary(i).sub       	= ['sub' suj_list(nsuj)];
                bin_summary(i).band       	= list_band{nband};
                bin_summary(i).bin        	= ['b' num2str(nbin)];
                bin_summary(i).win          = list_time_name{ntime};
                bin_summary(i).acc       	= tmp_summary.perc_corr(nbin);
                bin_summary(i).rt        	= tmp_summary.med_rt(nbin);
                bin_summary(i).rt_correct 	= tmp_summary.med_rt_correct(nbin);
                
                bin_summary(i).index      	= tmp_summary.bins(:,nbin);
                bin_summary(i).trialinfo  	= freq.trialinfo(tmp_summary.bins(:,nbin),:);
                
                %                 %-%-% compute ERFs and save
                %                 cfg                     	= [];
                %                 cfg.trials              	= bin_summary(i).index;
                %                 avg                        	= ft_timelockanalysis(cfg, data_preproc);
                %                 avg_comb                 	= ft_combineplanar([],avg);
                %                 avg_comb                 	= rmfield(avg_comb,'cfg'); clc;
                %
                %                 dir_out                    	= '~/Dropbox/project_me/data/nback/erf/';
                %                 fname_out                 	= [dir_out 'sub' num2str(suj_list(nsuj)) '.' list_band{nband} '.' list_time_name{ntime}];
                %                 fname_out                 	= [fname_out '.' num2str(nb_bin) 'binsb' num2str(nbin) '.erfComb.mat'];
                %
                %                 fprintf('Saving %s\n',fname_out);
                %                 tic;save(fname_out,'avg_comb','-v7.3');toc
                %
                %                 clear avg avg_comb data index
                
            end
        end
    end
    
    ext_bin_name                            = ['preconcat' num2str(nb_bin) 'bins.' ext_peak_file];
    fname_out                               = ['~/Dropbox/project_me/data/nback/bin/sub' num2str(suj_list(nsuj)) '.' ext_bin_name '.binsummary.mat'];
    fprintf('saving %s\n',fname_out);
    save(fname_out,'bin_summary');
    
    keep nsuj suj_list all* ext_bin_name ext_peak_file
    
end

keep ext_bin_name

nback3_func_bin2R(ext_bin_name);