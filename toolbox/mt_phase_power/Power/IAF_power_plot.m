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
 
 load(fullfile(File_st.power_files_path,[Analysis '_' Names_Test{pnum} '_' Power_st.stats_output_file	 '.mat']),'iaf_power_stat');
cfg=[];
cfg.layout=Power_st.layout;
ft_clusterplot(cfg,iaf_power_stat);
colormap('jet')

end


