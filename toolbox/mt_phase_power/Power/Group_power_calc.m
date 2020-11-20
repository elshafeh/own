addpath('C:\Users\U66300\toolbox\CircStat2012a\');
addpath('C:\Users\U66300\toolbox\fieldtrip-20161103\');
addpath(genpath(pwd));
ft_defaults;
clearvars
%%%% SCRIPT FOR GROUP POWER ANALYSIS

%Intialize path structure
[File_st,Analysis,Power_st]=Default_input_values('group');
%Get list of participants available in selected participants directory
Names_Test=Participant_IDs(File_st,'Test');


navgP=Power_st;
navgP.Avg_trials='no';

%Calculate the power for each participant
for pnum=1:size(Names_Test,2)
    
   load(fullfile(File_st.preproc_files_path,[ Names_Test{pnum} '_' Power_st.preproc '.mat']));
    
 % [power_hit,power_miss]=prestim_onset_tfa(Power_st,data_power);
   [power_hit,power_miss]=prestim_onset_tfa_mtmfft(Power_st,data_power);
   power_hit.powdb=10*log10(power_hit.powspctrm);
   power_miss.powdb=10*log10(power_miss.powspctrm);
   
   group_power_hit{pnum,1}=power_hit;
   group_power_miss{pnum,1}=power_miss;
   
  
   %[non_avg_power_hit,non_avg_power_miss]=prestim_onset_tfa(navgP,data_power);
   [non_avg_power_hit,non_avg_power_miss]=prestim_onset_tfa_mtmfft(navgP,data_power);
   save(fullfile(File_st.power_files_path,[Analysis '_' Names_Test{pnum} '_' Power_st.output_file '.mat']),'power_*','non_avg_*');
   clear non_avg_*
end
clear navgP;

