clear ; clc;

load ../data/bil_goodsubjectlist.27feb20.mat

if isunix
    project_dir      	= '/project/3015079.01/';
    start_dir         	= '/project/';
else
    project_dir      	= 'P:/3015079.01/';
    start_dir           = 'P:/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName     	= suj_list{nsuj};
    
    fname            	= [project_dir 'data/' subjectName '/tf/' subjectName '.firstcuelock.freqComb.alphaPeak.m1000m0ms.gratinglock.demean.erfComb.max20chan.p0p200ms.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    allpeaks(nsuj,1) 	= [apeak];
    
    fname            	= [project_dir 'data/' subjectName '/tf/' subjectName '.firstcuelock.1overf.orig.alphabetaPeak.' ...
        'm1000m0ms.mat'];
    load(fname);
    allpeaks(nsuj,2)  	= [bpeak_orig];
    
end

allpeaks(isnan(allpeaks(:,2)),2)    = nanmean(allpeaks(:,2));
allpeaks                = round(allpeaks);

allpeaks(:,3)         	= 4;
allpeaks(:,4)           = 80;

keep suj_list allpeaks ; clc;

i                       = 0;

for nsuj = 1:length(suj_list)
    
    subjectName         = suj_list{nsuj};
    
    if isunix
        subject_folder = ['/project/3015079.01/data/' subjectName '/'];
    else
        subject_folder = ['P:/3015079.01/data/' subjectName '/'];
    end
    
    fname               = [subject_folder 'preproc/' subjectName '_firstCueLock_ICAlean_finalrej.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    erf_ext_name       	= 'gratinglock.demean.erfComb.max20chan.p0p200ms';
    fname              	= [subject_folder '/erf/' subjectName '.' erf_ext_name '.postOnset.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    list_window     	= [-0.9967 0; 0.5 1.4967; 2 2.9967; 3.5 4.4967];
    list_windows_name 	= {'preCue1','preGab1','preCue2','preGab2'};
    
    list_smooth         = [1 2 1 20];
    list_freq           = {'alpha' 'beta' 'theta' 'gamma'};
    
    for ntime = 1:size(list_window)
        
        cfg             = [];
        cfg.latency 	= list_window(ntime,:);
        data_planar   	= h_ax2plan(ft_selectdata(cfg,dataPostICA_clean));
        
        % bin according to each frequency peak
        for nfreq = 1:size(allpeaks,2)
            
            cfg     	= [] ;
            cfg.pad   	= 1;
            cfg.output 	= 'pow';
            cfg.method 	= 'mtmfft';
            cfg.keeptrials 	= 'yes';
            cfg.foi   	= allpeaks(nsuj,nfreq);
            cfg.taper 	= 'hanning';
            cfg.tapsmofrq  	= list_smooth(nfreq);
            freq_planar	= ft_freqanalysis(cfg,data_planar);
            cfg       	= [];
            cfg.method 	= 'sum';
            freq_comb  	= ft_combineplanar(cfg,freq_planar);
            
            cfg         = [];
            cfg.channel = max_chan;
            freq_slct{nfreq}        = ft_selectdata(cfg,freq_comb); clear freq_comb freq_planar
            freq_slct{nfreq}        = rmfield(freq_slct{nfreq},'cfg');
            [bin_summary{nfreq}]    = h_preparebins(freq_slct{nfreq},allpeaks(nsuj,nfreq),5,0);
            
            info.freq=freq_slct{nfreq};
            info.bin_summary=bin_summary{nfreq};
            
            fname_out               = [subject_folder 'tf/' subjectName '.allbandbinning.' ...
                list_freq{nfreq} '.band.' list_windows_name{ntime} '.window.mat'];
            fprintf('saving %s\n',fname_out);
            save(fname_out,'info'); clear info fname_out;
            
        end
        
        % bin according to each frequency peak
        for nfreq = 1:length(bin_summary)
            for nbin = 1:size(bin_summary{nfreq}.bins,2)
                
                i = i +1;
                summary_table(i).suj    = subjectName;
                summary_table(i).win    = list_windows_name{ntime};
                summary_table(i).bin    = ['b' num2str(nbin)];
                summary_table(i).rt     = bin_summary{nfreq}.med_rt(nbin);
                summary_table(i).corr 	= bin_summary{nfreq}.perc_corr(nbin);
                summary_table(i).band 	= list_freq{nfreq};
                
                summary_table(i).pow_alpha 	= nanmean(nanmean(freq_slct{1}.powspctrm(bin_summary{nfreq}.bins(:,nbin),:)));
                summary_table(i).pow_beta 	= nanmean(nanmean(freq_slct{2}.powspctrm(bin_summary{nfreq}.bins(:,nbin),:)));
                summary_table(i).pow_theta 	= nanmean(nanmean(freq_slct{3}.powspctrm(bin_summary{nfreq}.bins(:,nbin),:)));
                summary_table(i).pow_gamma 	= nanmean(nanmean(freq_slct{4}.powspctrm(bin_summary{nfreq}.bins(:,nbin),:)));
                
                summary_table(i).avg_alpha 	= nanmean(nanmean(freq_slct{1}.powspctrm(unique([bin_summary{nfreq}.bins]),:)));
                summary_table(i).avg_beta 	= nanmean(nanmean(freq_slct{2}.powspctrm(unique([bin_summary{nfreq}.bins]),:)));
                summary_table(i).avg_theta 	= nanmean(nanmean(freq_slct{3}.powspctrm(unique([bin_summary{nfreq}.bins]),:)));
                summary_table(i).avg_gamma 	= nanmean(nanmean(freq_slct{4}.powspctrm(unique([bin_summary{nfreq}.bins]),:)));
                
                summary_table(i).norm_alpha = summary_table(i).pow_alpha ./ summary_table(i).avg_alpha;
                summary_table(i).norm_beta 	= summary_table(i).pow_beta ./ summary_table(i).avg_beta;
                summary_table(i).norm_theta = summary_table(i).pow_theta ./ summary_table(i).avg_theta;
                summary_table(i).norm_gamma = summary_table(i).pow_gamma ./ summary_table(i).avg_gamma;
                
                
            end
        end
    end
    
    keep i summary_table allpeaks suj_list
    
end

writetable(struct2table(summary_table),'../doc/bil.allbandbinning.txt');