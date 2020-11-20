
addpath('C:\Users\U66300\toolbox\CircStat2012a\');
addpath('C:\Users\U66300\toolbox\fieldtrip-20161103\');
addpath(genpath(pwd));
ft_defaults;

clearvars
%Intialize path structure
File_st=Default_input_values;
%Get list of participants available in selected participants directory
[Names_Test,Names_Retest]=Participant_IDs(File_st,'Test');