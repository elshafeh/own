function bil_beta_findpeak(subjectName,freq_comb)

if isunix
    subject_folder = ['/project/3015079.01/data/' subjectName];
else
    subject_folder = ['P:/3015079.01/data/' subjectName];
end

erf_ext_name                                            = 'gratinglock.demean.erfComb.max20chan.p0p200ms';
fname                                                   = [subject_folder '/erf/' subjectName '.' erf_ext_name '.postOnset.mat'];
fprintf('loading %s\n',fname);
load(fname);

list_time                                               = [-1 0; 0.5 1.5; 2 3; 3.5 4.5];

for ntime = 1:size(list_time,1)
    
    peak_window                                         = list_time(ntime,:);
    peak_name                                           = ['m' num2str(abs(peak_window(1)*1000)) 'm' num2str(abs(peak_window(2)*1000)) 'ms'];
    
    cfg                                                 = [];
    cfg.channel                                         = max_chan;
    cfg.latency                                         = peak_window;
    freq_peak                                           = ft_selectdata(cfg,freq_comb);
    freq_peak.freq                                      = round(freq_peak.freq);
    
    cfg                                                 = [];
    cfg.method                                          = 'linear' ;
    cfg.foi                                             = [15 35];
    bpeak                                               = alpha_peak(cfg,freq_peak);
    bpeak                                               = bpeak(1);
    
    if isnan(bpeak)
        warning(['no beta peak for ' subjectName]);
    else
        fprintf('peak found at %2d\n',bpeak);
    end
    
    fname_out                                           = [subject_folder '/tf/' subjectName '.firstcuelock.freqComb.betaPeak.' peak_name '.' erf_ext_name '.mat'];
    fprintf('saving %s\n',fname_out);
    save(fname_out,'bpeak');
    
end