function bil_alpha_select_maxchan(subjectName,time_window,lmt)

if isunix
    subject_folder = ['/project/3015079.01/data/' subjectName];
else
    subject_folder = ['P:/3015079.01/data/' subjectName];
end

ext_name                                    = 'gratinglock.demean.erfComb';
file_list                                	= dir([subject_folder '/erf/' subjectName '.' ext_name '.mat']);

fname                                       = [file_list(1).folder '/' file_list(1).name];
fprintf('\nloading %s\n',fname);
load(fname);

cfg                                         = [];
cfg.latency                                 = time_window;
cfg.avgovertime                             = 'yes';
cfg.channel                                 = {'M*O*'};
data_avg                                    = ft_selectdata(cfg,avg_comb);

vctr                                        = [[1:length(data_avg.avg)]' data_avg.avg];
vctr_sort                                   = sortrows(vctr,2,'descend'); % sort from high to low

max_chan                                    = data_avg.label(vctr_sort(1:lmt,1));

% adapt name of file accroding to time-window chosen
ext_time                                    = ['p' num2str(round(time_window(1)*1000))];
ext_time                                    = [ext_time 'p' num2str(round(time_window(2)*1000)) 'ms.postOnset'];

fname_out                                   = [subject_folder '/erf/' subjectName '.' ext_name '.max' num2str(lmt) 'chan.' ext_time '.mat'];
fprintf('saving %s\n\n',fname_out);

save(fname_out,'max_chan');