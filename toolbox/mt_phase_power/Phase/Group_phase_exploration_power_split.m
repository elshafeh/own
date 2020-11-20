addpath('C:\Users\U66300\toolbox\CircStat2012a\');
addpath('C:\Users\U66300\toolbox\fieldtrip-20161103\');
addpath(genpath(pwd));
ft_defaults;

clearvars
%%%% SCRIPT FOR GROUP POWER ANALYSIS

%Intialize path structure
[File_st,Analysis,Power_st,Phase_st,POS_st,Phase_explore_st]=Default_input_values('group');
%Get list of participants available in selected participants directory
Names_Test=Participant_IDs(File_st,'Test');


%Select always the most significant electrode and frequency
load(fullfile(File_st.phase_files_path,[Analysis '_' POS_st.stat_file '.mat']),'adjusted_pvalue');
min_pval=min(min(adjusted_pvalue));

   



    
    Bin_edges=-pi:2*pi/Phase_explore_st.Numbins:pi;
    Bin_centers=Bin_edges(1:end-1)+pi/Phase_explore_st.Numbins;
    shifted_HIT_RATES=nan(length(Names_Test),Phase_explore_st.Numbins);
    HIT_RATES=nan(length(Names_Test),Phase_explore_st.Numbins);

    [~,zero_bin]=min(abs(Bin_centers-0));
    shifted_idx=[1:zero_bin-1 zero_bin+1:length(Bin_centers)];
    shifted_Bin_centers=Bin_centers(shifted_idx);
    
    load(fullfile(File_st.phase_files_path,[Analysis '_' Phase_explore_st.output_file '.mat']),'Results','Stat_table','Raw_table');
    
    best_El=find(strcmp(Results.Best_electrode,Phase_st.labels));
    [~,best_Freq]=min(abs(Results.Best_frequency-Phase_st.FOI));
    
    
    %First store all individual data
    for pnum=1:size(Names_Test,2)
        %Load power values
        load(fullfile(File_st.power_files_path,[Analysis '_' Names_Test{pnum} '_' Power_st.output_file '.mat']),'non_avg*');
        cfg=[];
        cfg.channel=Results.Best_electrode;
        cfg.frequency=[Results.Best_frequency Results.Best_frequency];
        power_hit=ft_selectdata(cfg,non_avg_power_hit);
        power_miss=ft_selectdata(cfg,non_avg_power_miss);
        
        power_hit=power_hit.powspctrm;
        power_miss=power_miss.powspctrm;
        
        clear non_avg*
        
        med_pow=median(cat(1,power_hit,power_miss));
        
        Hit_hp=(power_hit>med_pow);
        Miss_hp=(power_miss>med_pow);
        
        clear power*
        
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
        
        HP(pnum,1).Hit_phases=Hit_phases(Hit_hp);
        HP(pnum,1).Miss_phases=Miss_phases(Miss_hp);
        
        LP(pnum,1).Hit_phases=Hit_phases(~Hit_hp);
        LP(pnum,1).Miss_phases=Miss_phases(~Miss_hp);
        
    end
    
    [HP_Results,HP_Raw_table,HP_Stat_table]=Descriptive_phases(Names_Test,HP,Bin_edges,Bin_centers,Phase_explore_st,Results,shifted_idx,shifted_Bin_centers);
    [LP_Results,LP_Raw_table,LP_Stat_table]=Descriptive_phases(Names_Test,LP,Bin_edges,Bin_centers,Phase_explore_st,Results,shifted_idx,shifted_Bin_centers);

    save(fullfile(File_st.phase_files_path,[Analysis '_' Phase_explore_st.output_file '_high_power.mat']),'HP_*');
    save(fullfile(File_st.phase_files_path,[Analysis '_' Phase_explore_st.output_file '_low_power.mat']),'LP_*');
