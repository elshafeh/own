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

Nfreq=length(Phase_st.FOI);
Nel=length(Phase_st.labels);
% Perform stats
mean_POS=zeros(Nfreq,Nel);
mean_null_POS=zeros(POS_st.Null_pos,Nfreq,Nel);

Analysis2='iaf';

for pnum=1:size(Names_Test,2)
   
   load(fullfile(File_st.phase_files_path,[Analysis2 '_' Names_Test{pnum} '_' POS_st.output_file '.mat']),'pos_val');
   mean_POS=mean_POS+pos_val;
   load(fullfile(File_st.phase_files_path,[Analysis2 '_' Names_Test{pnum} '_' POS_st.null_output_file '.mat']),'null_pos');
   mean_null_POS=mean_null_POS+null_pos;
end

mean_POS=mean_POS/size(Names_Test,1);
mean_null_POS=mean_null_POS/size(Names_Test,1);
test_matrix=[];
test_matrix(1,:,:)=mean_POS;
compare=mean_null_POS-repmat(test_matrix,POS_st.Null_pos,1,1);

compare=(compare>0);
pvalue=squeeze(mean(compare,1));

[~ ,~ ,adjusted_pvalue]=fdr_bh(pvalue,0.05,'pdep','yes');


% save(fullfile(File_st.phase_files_path,[Analysis '_' Analysis2 '_centered_' POS_st.stat_file '.mat']),'pvalue','adjusted_pvalue');
% save(fullfile(File_st.phase_files_path,[Analysis '_' Analysis2 '_centered_' POS_st.output_file '.mat']),'mean_POS');

