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
    
    %Calculate the phase for each participant
    load(fullfile(File_st.preproc_files_path,[Names_Test{pnum} '_' Phase_st.preproc '.mat']));
    run(fullfile(File_st.info_path,[Names_Test{ pnum} '_info_preproc.m']));
    Phase_st.FOI=part.IAF-5:1:part.IAF+5;
    %[phase_hit,phase_miss]=prestim_onset_tfa(Phase_st,data_phase);
    [phase_hit,phase_miss]=prestim_onset_tfa_mtmfft(Phase_st,data_phase);
    try
        load(fullfile(File_st.power_files_path,[Analysis '_' Names_Test{pnum} '_' Phase_st.peaks_output_file  '.mat']),'has_peak_*');
    catch
        error('Before running this script you need to run IAF power, please!');
    end
    %Select trials with an IAF peak
    cfg=[];
    cfg.trials=has_peak_hit;
    phase_hit=ft_selectdata(cfg,phase_hit);
    cfg=[];
    cfg.trials=has_peak_miss;
    phase_miss=ft_selectdata(cfg,phase_miss);
     
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
    
    %And now calculate stats
    test_matrix=[];
    test_matrix(1,:,:)=pos_val;
    compare=null_pos-repmat(test_matrix,POS_st.Null_pos,1,1);
    
    compare=(compare>0);
    pvalue=squeeze(mean(compare,1));
    
    [~ ,~ ,adjusted_pvalue]=fdr_bh(pvalue,0.05,'pdep','yes');
    
    save(fullfile(File_st.phase_files_path,[Analysis '_' Names_Test{pnum} '_' POS_st.stat_file '.mat']),'pvalue','adjusted_pvalue');
    
    
end



