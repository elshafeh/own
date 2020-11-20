addpath('C:\Users\U66300\toolbox\CircStat2012a\');
addpath('C:\Users\U66300\toolbox\fieldtrip-20161103\');
addpath(genpath(pwd));
ft_defaults;

clearvars
%%%% SCRIPT FOR GROUP POWER ANALYSIS

%Intialize path structure
[File_st,Analysis,~,Phase_st,POS_st]=Default_input_values('group');
%Get list of participants available in selected participants directory
Names_Test=Participant_IDs(File_st,'Test');




%Calculate the POS for each participant
for pnum=1:size(Names_Test,2)
    
   tic 
   load(fullfile(File_st.phase_files_path,[Analysis '_' Names_Test{pnum} '_' Phase_st.output_file '.mat']),'data_*');
    try
        load(fullfile(File_st.power_files_path,['iaf_' Names_Test{pnum} '_' Phase_st.peaks_output_file  '.mat']),'has_peak_*');
    catch
        error('Before running this script you need to run IAF power, please!');
    end
   data_hit=data_hit(has_peak_hit,:,:);
   data_miss=data_miss(has_peak_miss,:,:);
   %Calculate POS
   all_data=cat(1,data_hit,data_miss);
   hit_vec=cat(1,true(size(data_hit,1),1),false(size(data_miss,1),1));
   pos_val=pos_calculate(all_data,hit_vec);
   save(fullfile(File_st.phase_files_path,[Analysis '_' Names_Test{pnum} '_' POS_st.output_file '_with_peak.mat']),'pos_val');
 
   null_pos=null_pos_calculate(all_data,hit_vec,POS_st.Null_pos);
   save(fullfile(File_st.phase_files_path,[Analysis '_' Names_Test{pnum} '_' POS_st.null_output_file '_with_peak.mat']),'null_pos');
   toc
end


