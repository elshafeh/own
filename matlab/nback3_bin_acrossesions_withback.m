clear ; close all; global ft_default
ft_default.spmversion = 'spm12';

suj_list                                = [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    subjectname                         = ['sub' num2str(suj_list(nsuj))];
    
    % load peak
    ext_peak_file                       = '0back.equalhemi';
    dir_data                            = '~/Dropbox/project_me/data/nback/peak/';
    fname                               = [dir_data subjectname '.alphabeta.peak.package.' ext_peak_file '.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    allalphapeaks(nsuj,1)               = apeak; clear apeak;
    allbetapeaks(nsuj,1)                = bpeak; clear bpeak;
    
    allchan{nsuj}                       = max_chan; clear max_chan;
    
end

mean_beta_peak                          = round(nanmean(allbetapeaks));
allbetapeaks(isnan(allbetapeaks))       = mean_beta_peak;

keep suj_list all* ext_peak_file; clc ;

for nsuj = 1:length(suj_list)
    
    bin_summary                         = [];
    i                                   = 0;
    
    dir_data                            = '~/Dropbox/project_me/data/nback/singletrial/';
    fname_in                            = [dir_data 'sub' num2str(suj_list(nsuj)) '.singletrial.fft.mat'];
    fprintf('loading %s\n',fname_in);
    load(fname_in)
    
    fname_in                            = [dir_data 'sub' num2str(suj_list(nsuj)) '.singletrial.trialinfo.mat'];
    fprintf('loading %s\n',fname_in);
    load(fname_in);
    
    freq_comb.trialinfo                 = trialinfo; clear trialinfo;
    
    %-%-% zoom on occipital channels
    %-%-% we zoom in afterwards (not before) due to some combine planar
    % problems
    cfg                                 = [];
    cfg.channel                         = allchan{nsuj};
    freq                                = ft_selectdata(cfg,freq_comb); clear freq_comb;
    
    %-%-% zoom on occipital channels
    %-%-% we zoom in afterwards (not before) due to some combine planar
    % problems
    
    allpeaks                            = [allalphapeaks(nsuj) allbetapeaks(nsuj)];
    list_band                           = {'alpha' 'beta'};
    list_width                          = [1 2];
    
    for nband = 1:length(list_band)
        
        nb_bin                          = 2;
        
        for nback = [1 2]
            
            cfg                             = [];
            cfg.trials                      = find(freq.trialinfo(:,1) == nback +4);
            freq_select                     = ft_selectdata(cfg,freq);
            
            [tmp_summary]                   = nback_func_preparebin_sessionconcat(freq_select,allpeaks(nband),nb_bin,list_width(nband));
            
            for nbin = 1:nb_bin
                
                %-%-% save information
                i                        	= i+1;
                bin_summary(i).sub       	= ['sub' suj_list(nsuj)];
                bin_summary(i).band       	= list_band{nband};
                bin_summary(i).bin        	= ['b' num2str(nbin)];
                
                bin_summary(i).win          = 'pre';
                bin_summary(i).back        	= [num2str(nback) 'back'];
                
                bin_summary(i).acc       	= tmp_summary.perc_corr(nbin);
                bin_summary(i).rt        	= tmp_summary.med_rt(nbin);
                bin_summary(i).rt_correct 	= tmp_summary.med_rt_correct(nbin);
                
                bin_summary(i).index      	= tmp_summary.bins(:,nbin);
                bin_summary(i).trialinfo  	= freq.trialinfo(tmp_summary.bins(:,nbin),:);
                
                
            end
            
        end
        
    end
    
    ext_bin_name                    	= ['preconcat' num2str(nb_bin) 'bins.' ext_peak_file '.withback'];
    dir_out                             = '~/Dropbox/project_me/data/nback/bin/';
    fname_out                        	= [dir_out 'sub' num2str(suj_list(nsuj)) '.' ext_bin_name '.binsummary.mat'];
    fprintf('saving %s\n',fname_out);
    save(fname_out,'bin_summary');
    
    keep nsuj suj_list all* ext_bin_name ext_peak_file
    
end

keep ext_bin_name

nback3_func_bin2R(ext_bin_name);