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
    
   load(fullfile(File_st.preproc_files_path,[Names_Test{pnum} '_' Phase_st.preproc  '.mat']));
   %[phase_hit,phase_miss]=prestim_onset_tfa(Phase_st,data_phase);
   [phase_hit,phase_miss]=prestim_onset_tfa_mtmfft(Phase_st,data_phase);
  %Now rearrange the matrices in the order useful for further
   %calculations: Trial x Frequency x Channel
   
   data_hit=permute(phase_hit.fourierspctrm,[1,3,2]);
   data_miss=permute(phase_miss.fourierspctrm,[1,3,2]);
   save(fullfile(File_st.phase_files_path,[Analysis '_' Names_Test{pnum} '_' Phase_st.output_file '.mat']),'data_*','phase_*');
   
   %Calculate POS
   all_data=cat(1,data_hit,data_miss);
   hit_vec=cat(1,true(size(data_hit,1),1),false(size(data_miss,1),1));
   pos_val=pos_calculate(all_data,hit_vec);
   
   save(fullfile(File_st.phase_files_path,[Analysis '_' Names_Test{pnum} '_' POS_st.output_file '.mat']),'pos_val');
   null_pos=null_pos_calculate(all_data,hit_vec,POS_st.Null_pos);
   save(fullfile(File_st.phase_files_path,[Analysis '_' Names_Test{pnum} '_' POS_st.null_output_file '.mat']),'null_pos');
   
   Nfreq=size(pos_val,1);
   Nel=size(pos_val,2);
end


