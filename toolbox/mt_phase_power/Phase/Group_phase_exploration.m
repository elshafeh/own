addpath('C:\Users\U66300\toolbox\CircStat2012a\');
addpath('C:\Users\U66300\toolbox\fieldtrip-20161103\');
addpath(genpath(pwd));
ft_defaults;

clearvars
%%%% SCRIPT FOR GROUP POWER ANALYSIS

%Intialize path structure
[File_st,Analysis,~,Phase_st,POS_st,Phase_explore_st]=Default_input_values('group');
%Get list of participants available in selected participants directory
Names_Test=Participant_IDs(File_st,'Test');


%Select always the most significant electrode and frequency
%load(fullfile(File_st.phase_files_path,[Analysis '_' POS_st.stat_file '.mat']),'adjusted_pvalue');
load(fullfile(File_st.phase_files_path,[Analysis '_' POS_st.stat_file '.mat']),'adjusted_pvalue');

min_pval=min(min(adjusted_pvalue));




if min_pval<Phase_explore_st.alpha
    
    Bin_edges=-pi:2*pi/Phase_explore_st.Numbins:pi;
    Bin_centers=Bin_edges(1:end-1)+pi/Phase_explore_st.Numbins;
    shifted_HIT_RATES=nan(length(Names_Test),Phase_explore_st.Numbins);
    HIT_RATES=nan(length(Names_Test),Phase_explore_st.Numbins);
    
    [~,zero_bin]=min(abs(Bin_centers-0));
    shifted_idx=[1:zero_bin-1 zero_bin+1:length(Bin_centers)];
    shifted_Bin_centers=Bin_centers(shifted_idx);
    
    significant_points=(adjusted_pvalue==min_pval);
    % If there are more than one electrode with the same p-value, take the one with higher POS
    load(fullfile(File_st.phase_files_path,[Analysis '_' POS_st.output_file '.mat']),'mean_POS');
    %Mask POS values to get only the values of the significant ones,
    %take maximum POS
    [best_Freq,best_El]=find(mean_POS==max(max(mean_POS.*significant_points)));
    
    Results.Best_electrode=Phase_st.labels{best_El};
    Results.Best_frequency=Phase_st.FOI(best_Freq);
    
    clear mean_POS adjusted_pvalue
    %First store all individual data
    for pnum=1:size(Names_Test,2)
        %Get individual data
        load(fullfile(File_st.phase_files_path,[Analysis '_' Names_Test{pnum} '_' Phase_st.output_file '.mat']),'data_*');
        
        %Check phase is stored as complex-valued data and bring it to phase
        %format (radians between -pi and pi)
        assert((~isreal(data_hit))&&(~isreal(data_miss)),'Error, the input should be complex data!')
        data_hit=wrapToPi(angle(data_hit./abs(data_hit)));
        data_miss=wrapToPi(angle(data_miss./abs(data_miss)));
        
        %Select phases for best electrode-frequency point
        Hit_phases=squeeze(data_hit(:,best_Freq,best_El));
        Miss_phases=squeeze(data_miss(:,best_Freq,best_El));
        
        clear data_*
        
        Best_point(pnum,1).Hit_phases=Hit_phases;
        Best_point(pnum,1).Miss_phases=Miss_phases;
        
        
    end
    
    
    [Results,Raw_table,Stat_table]=Descriptive_phases(Names_Test,Best_point,Bin_edges,Bin_centers,Phase_explore_st,Results,shifted_idx,shifted_Bin_centers);
    save(fullfile(File_st.phase_files_path,[Analysis '_' Phase_explore_st.output_file '.mat']),'Results','Stat_table','Raw_table');
else
    display('No significant electrode-frequency pair found!');
    
end
