clear ; clc;

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName             = suj_list{nsuj};
    
    if isunix
        subject_folder      = ['/project/3015079.01/data/' subjectName '/'];
    else
        subject_folder      = ['P:/3015079.01/data/' subjectName '/'];
    end
    
    fname                   = [subject_folder 'preproc/' subjectName '_firstCueLock_ICAlean_finalrej.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    erf_ext_name           	= 'gratinglock.demean.erfComb.max20chan.p0p200ms';
    fname                	= [subject_folder '/erf/' subjectName '.' erf_ext_name '.postOnset.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    cfg                 	= [];
    cfg.channel          	= max_chan;
    dataPostICA_clean       = ft_selectdata(cfg,dataPostICA_clean);
    
    list_time             	= [-1 4.5]; %-1 0; 0.5 1.5; 2 3; 3.5 4.5];
    
    for ntime = 1:size(list_time,1)
        
        peak_window      	= list_time(ntime,:);
        
        cfg                 = [];
        cfg.toilim          = peak_window;
        data                = ft_redefinetrial(cfg,dataPostICA_clean);
        
        % perform IRASA and regular spectral analysis
        cfg                 = [];
        cfg.foi             = 1:1:40;
        cfg.taper           = 'hanning';
        cfg.pad             = 'nextpow2';
        cfg.keeptrials      = 'no';
        cfg.method          = 'irasa';
        frac_r              = ft_freqanalysis(cfg, data);
        cfg.method          = 'mtmfft';
        orig_r              = ft_freqanalysis(cfg, data);
        
        frac_r.freq         = round(frac_r.freq);
        orig_r.freq         = round(orig_r.freq);

        % subtract the fractal component from the power spectrum
        cfg                 = [];
        cfg.parameter       = 'powspctrm';
        cfg.operation       = 'x1-x2';
        osci                = ft_math(cfg, orig_r, frac_r);
        
        cfg               	= [];
        cfg.method         	= 'maxabs' ;
        cfg.foi           	= [7 15];
        apeak              	= alpha_peak(cfg,orig_r);
        apeak_orig          = apeak(1);
        
        apeak              	= alpha_peak(cfg,osci);
        apeak_osci          = apeak(1);
        
        cfg                	= [];
        cfg.method         	= 'linear' ;
        cfg.foi            	= [15 35];
        bpeak              	= alpha_peak(cfg,orig_r);
        bpeak_orig        	= bpeak(1);
        
        bpeak              	= alpha_peak(cfg,osci);
        bpeak_ocsi         	= bpeak(1);
        
        data                = [];
        data.avg (1,:)      = mean(orig_r.powspctrm,1);
        data.avg (2,:)      = mean(osci.powspctrm,1);
        data.label          = {'orig','osci'};
        data.dimord         = 'chan_time';
        data.time           = osci.freq;
        
        peak_name          	= ['m' num2str(abs(peak_window(1)*1000)) 'm' num2str(abs(peak_window(2)*1000)) 'ms'];
        fname_out          	= [subject_folder '/tf/' subjectName '.firstcuelock.1overf.orig.alphabetaPeak.' peak_name '.mat'];
        fprintf('saving %s\n',fname_out);
        save(fname_out,'bpeak_orig','bpeak_ocsi','apeak_orig','apeak_osci','data');
        
        clear *peak* osci data *_r
        
    end
    
    clear dataPostICA_clean;
    
end