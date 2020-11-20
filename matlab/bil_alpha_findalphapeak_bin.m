function [apeak,peak_name] = bil_alpha_findalphapeak_bin(subjectName)

if isunix
    subject_folder = ['/project/3015079.01/data/' subjectName];
else
    subject_folder = ['P:/3015079.01/data/' subjectName];
end

fname                                               = [subject_folder '/tf/' subjectName '.firstcuelock.5t20Hz.1HzStep.KeepTrials.comb.mat'];
fprintf('\nloading %s\n',fname);
load(fname);

erf_ext_name                                        = 'gratinglock.demean.erfComb.max20chan.p0p200ms';
fname                                               = [subject_folder '/erf/' subjectName '.' erf_ext_name '.postOnset.mat'];
fprintf('loading %s\n',fname);
load(fname);

peak_window                                         = [-1 0];
peak_name                                           = ['m' num2str(abs(peak_window(1)*1000)) 'm' num2str(abs(peak_window(2)*1000)) 'ms'];

cfg                                                 = [];
cfg.channel                                         = max_chan;
cfg.latency                                         = peak_window;
freq_peak                                           = ft_selectdata(cfg,freq_comb);

cfg                                                 = [];
cfg.method                                          = 'maxabs' ;
cfg.foi                                             = [7 15];
apeak                                               = alpha_peak(cfg,freq_peak);
apeak                                               = apeak(1);

if isnan(apeak)
    warning(['no alpha peak for ' subjectName]);
end

fname_out                                           = [subject_folder '/tf/' subjectName '.firstcuelock.freqComb.alphaPeak.' peak_name '.' erf_ext_name '.mat'];
fprintf('saving %s\n',fname_out);
save(fname_out,'apeak');

list_windows                                        = [-1 0; 0.5 1.5; 2 3; 3.5 4.5];
list_windows_name                                   = {'preCue1','preTarget','preCue2','preProbe'};
list_cond                                           = {'pre','retro','all'};

for nc = [3]
    for ntime = 1:size(list_windows,1)
        
        cfg                                         = [];
        cfg.channel                                 = max_chan;
        cfg.latency                                 = list_windows(ntime,:);
        cfg.frequency                               = [7 15];
        if nc ~= 3
        cfg.trials                                  = find(freq_comb.trialinfo(:,8) == nc);
        end
        freq                                        = ft_selectdata(cfg,freq_comb);
        
        for nb_bin  = [5 6 7 8 9 10]
            
            bnwidth                                 = 1;
            
            [bin_summary]                           = h_preparebins(freq,apeak,nb_bin,bnwidth);
            
            bin_name                                = [num2str(nb_bin) 'Bins.' num2str(bnwidth) 'Hz'];
            
            fname_out                               = [subject_folder '/tf/' subjectName '.firstcuelock.freqComb.alphaPeak.' ...
                peak_name '.' erf_ext_name '.' bin_name '.window.' list_windows_name{ntime} '.' list_cond{nc} '.mat'];
            
            fprintf('saving %s\n',fname_out);
            save(fname_out,'bin_summary');
            
            clear bin_summary
            
        end
        
        clear freq
        
    end
    
end

% cfg                                                 = [];
% cfg.method                                          = 'linear' ;
% cfg.foi                                             = [15 30];
% bpeak                                               = alpha_peak(cfg,freq_peak);
% bpeak                                               = bpeak(1);
%
% if isnan(bpeak)
%     warning(['no beta peak for ' subjectName]);
% end
%
% fname_out                                           = [subject_folder 'tf/' subjectName '.firstcuelock.freqComb.betaPeak.' peak_name '.' erf_ext_name '.mat'];
% fprintf('saving %s\n',fname_out);
% save(fname_out,'bpeak');