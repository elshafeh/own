addpath('C:\Users\U66300\toolbox\CircStat2012a\');
addpath('C:\Users\U66300\toolbox\fieldtrip-20161103\');
addpath(genpath(pwd));
ft_defaults;
clearvars
%%%% SCRIPT FOR IAF POWER ANALYSIS

%Intialize path structure
[File_st,Analysis,Power_st]=Default_input_values('iaf');
%Get list of participants available in selected participants directory
Names_Test=Participant_IDs(File_st,'Test');




%Calculate the power for each participant
for pnum=1:size(Names_Test,2)
    
   load(fullfile(File_st.preproc_files_path,[Names_Test{pnum} '_' Power_st.preproc  '.mat']));
   
   run(fullfile(File_st.info_path,[Names_Test{ pnum} '_info_preproc.m']));
   
   Power_st.FOI=part.IAF-5:1:part.IAF+5;
   
        
   %[power_hit,power_miss]=prestim_onset_tfa(Power_st,data_power);
    [power_hit,power_miss]=prestim_onset_tfa_mtmfft(Power_st,data_power);
     
   has_peak_hit=detect_trials_with_peak(power_hit);
   has_peak_miss=detect_trials_with_peak(power_miss);
   
   power_hit.powdb=10*log10(power_hit.powspctrm);
   power_miss.powdb=10*log10(power_miss.powspctrm);
   
  
   save(fullfile(File_st.power_files_path,[Analysis '_' Names_Test{pnum} '_' Power_st.output_file  '.mat']),'power_*');
   save(fullfile(File_st.power_files_path,[Analysis '_' Names_Test{pnum} '_' Power_st.peaks_output_file  '.mat']),'has_peak_*');
   



% And now perfom stats: Unpairedt-test Hit vs Miss (left tail) alpha
% level=0.05. Minimum number of neighbours=2; Multiple comparison
% correction: Cluster

cfg = [];
cfg.parameter='powdb';
cfg.method           = 'montecarlo';
cfg.statistic        = 'ft_statfun_indepsamplesT';
cfg.correctm         = 'cluster';
cfg.clusteralpha     = 0.05;
cfg.clusterstatistic = 'maxsum';
cfg.minnbchan        = 2;
cfg.tail             = -1;%NOTICE THIS IS CORRECT IF WE COMPARE HITS VERSUS MISSES
cfg.clustertail      = cfg.tail;
cfg.alpha            = 0.05;
cfg.numrandomization = 1e4;%Power_st.Nrandomizations;
cfg.avgoverfreq='no';
cfg.avgoverchan='no';%

cfg.neighbours=Power_st.neighbours;% prepare_neighbours determines what sensors may form clusters
design=[];
design(1,:) = cat(2,ones(1,size(power_hit.powspctrm,1)),2*ones(1,size(power_miss.powspctrm,1)));

cfg.design   = design;
cfg.ivar     = 1;


cfg.design           = design;

iaf_power_stat = ft_freqstatistics(cfg, power_hit,power_miss);

 save(fullfile(File_st.power_files_path,[Analysis '_' Names_Test{pnum} '_' Power_st.stats_output_file	 '.mat']),'iaf_power_stat');
end

cfg=[];
cfg.layout=Power_st.layout;


