addpath('C:\Users\U66300\toolbox\CircStat2012a\');
addpath('C:\Users\U66300\toolbox\fieldtrip-20161103\');
addpath(genpath(pwd));
ft_defaults;

clearvars
%%%% SCRIPT FOR GROUP POWER ANALYSIS

%Intialize path structure
[File_st,Analysis,~,Phase_st,POS_st]=Default_input_values('iaf');
%Get list of participants available in selected participants directory
Names_Test=Participant_IDs(File_st,'Test');





for pnum=1:size(Names_Test,2)
    
     try
        load(fullfile(File_st.power_files_path,[Analysis '_' Names_Test{pnum} '_' Phase_st.peaks_output_file  '.mat']),'has_peak_*');
    catch
        error('Before running this script you need to run IAF power, please!');
    end
   
    
    IAF_hit(pnum,1)=sum(has_peak_hit);
    Total_hit(pnum,1)=length(has_peak_hit);
    IAF_miss(pnum,1)=sum(has_peak_miss);
    Total_miss(pnum,1)=length(has_peak_miss);
    
end


Prop_IAF_hit=IAF_hit./Total_hit;
Prop_IAF_miss=IAF_miss./Total_miss;
