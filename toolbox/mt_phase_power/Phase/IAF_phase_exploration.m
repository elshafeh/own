addpath('C:\Users\U66300\toolbox\CircStat2012a\');
addpath('C:\Users\U66300\toolbox\fieldtrip-20161103\');
addpath(genpath(pwd));
ft_defaults;

clearvars

%%%% SCRIPT FOR GROUP POWER ANALYSIS

%Intialize path structure
[File_st,Analysis,~,Phase_st,POS_st,Phase_explore_st]=Default_input_values('iaf');
%Get list of participants available in selected participants directory
Names_Test=Participant_IDs(File_st,'Test');


%Select always the most significant electrode and frequency
Bin_edges=-pi:2*pi/Phase_explore_st.Numbins:pi;
Bin_centers=Bin_edges(1:end-1)+pi/Phase_explore_st.Numbins;

HIT_RATES=nan(length(Names_Test),Phase_explore_st.Numbins);


for pnum=1:size(Names_Test,2)
    run(fullfile(File_st.info_path,[Names_Test{ pnum} '_info_preproc.m']));
    %Load stats
      %load(fullfile(File_st.phase_files_path,[Analysis '_' Names_Test{pnum} '_' POS_st.stat_file '.mat']),'adjusted_pvalue');
      load(fullfile(File_st.phase_files_path,[Analysis '_' Names_Test{pnum} '_' POS_st.stat_file '.mat']),'pvalue');
      adjusted_pvalue=pvalue;
      min_pval=min(min(adjusted_pvalue));
      
      if min_pval<Phase_explore_st.alpha
        %Select the most significant electrode-frequency pair
        %The output is a logical array Freq x Electrode
        significant_points=(adjusted_pvalue==min_pval);
        % If there are more than one electrode with the same p-value, take the one with higher POS
        load(fullfile(File_st.phase_files_path,[Analysis '_' Names_Test{pnum} '_' POS_st.output_file '.mat']),'pos_val');    
        %Mask POS values to get only the values of the significant ones,
        %take maximum POS
        [best_Freq,best_El]=find(pos_val==max(max(pos_val.*significant_points)));
        
        
        clear pos_val adjusted_pvalue
        load(fullfile(File_st.phase_files_path,[Analysis '_' Names_Test{pnum} '_' Phase_st.output_file '.mat']),'data_*','phase_hit');
        
        BEST_EL=Phase_st.labels{best_El};
        BEST_FREQ=phase_hit.freq(best_Freq);
        
        
        clear phase_hit;
        
        %Make sure data is complex valued and bring it to phase format
        %(radians) between -Pi and Pi
        assert((~isreal(data_hit))&&(~isreal(data_miss)),'Error, the input should be complex data!')
        data_hit=wrapToPi(angle(data_hit./abs(data_hit)));
        data_miss=wrapToPi(angle(data_miss./abs(data_miss)));
        
        %Select best freq-electrode point
        Hit_phases=squeeze(data_hit(:,best_Freq,best_El));
        Miss_phases=squeeze(data_miss(:,best_Freq,best_El));
        
        %Fit Von Mises distribution to Hits and Misses
        [Hit_direction,Hit_kappa] = circ_vmpar(Hit_phases);
        [Miss_direction,Miss_kappa] = circ_vmpar(Miss_phases);
       
        %Test if Misses distribution is concentrated aroud Hits+180º
        pval_miss = circ_vtest(Miss_phases, wrapToPi(Hit_direction+Phase_explore_st.Expected_difference));
        
        %Divide phase data into N bins, calculate phase-specific hit-rate
        %and calculate Phase to HR correlation. 
        [phase_HR, phase_HR_corr]=phase_behavior_correlation(Hit_phases,Miss_phases,Bin_edges,Bin_centers);
        %Significance test: Montecarlo randomization test
        Null_phases=cat(1,Hit_phases,Miss_phases);
        Nhits=size(Hit_phases,1);
        pval_corr=0;
        for n=1:Phase_explore_st.Nrandomizations
           Null_phases=Null_phases(randperm(length(Null_phases)));
           nullA=Null_phases(1:Nhits);
           nullB=Null_phases(Nhits+1:end);
           [~, null_phase_HR_corr,~]=phase_behavior_correlation(nullA,nullB,Bin_edges,Bin_centers); 
            pval_corr=pval_corr+(null_phase_HR_corr>=phase_HR_corr);
        end
        pval_corr=pval_corr/Phase_explore_st.Nrandomizations;
        %Save data
        iaf_explore_phases(pnum,1).ID=Names_Test{pnum};
        iaf_explore_phases(pnum,1).IAF=part.IAF;
        iaf_explore_phases(pnum,1).Best_Freq=BEST_FREQ;
        iaf_explore_phases(pnum,1).Best_electrode=BEST_EL;
        iaf_explore_phases(pnum,1).Hit_direction=Hit_direction;
        iaf_explore_phases(pnum,1).Hit_concentration=Hit_kappa;
        iaf_explore_phases(pnum,1).Miss_direction=Miss_direction;
        iaf_explore_phases(pnum,1).Miss_concentration=Miss_kappa;
        iaf_explore_phases(pnum,1).Pval_miss_oposition= pval_miss;
        HIT_RATES(pnum,:)=phase_HR;
        iaf_explore_phases(pnum,1).Pval_correlation=pval_corr;
        iaf_explore_phases(pnum,1).HR_phase_correlation=phase_HR_corr;
        
      else
        display('No significant electrode-frequency pair found for this participant!');
        iaf_explore_phases(pnum,1).ID=Names_Test{pnum};
        iaf_explore_phases(pnum,1).IAF=part.IAF;
        iaf_explore_phases(pnum,1).Best_Freq=NaN;
        iaf_explore_phases(pnum,1).Best_electrode='None';
        iaf_explore_phases(pnum,1).Hit_direction=NaN;
        iaf_explore_phases(pnum,1).Hit_concentration=NaN;
        iaf_explore_phases(pnum,1).Miss_direction=NaN;
        iaf_explore_phases(pnum,1).Miss_concentration=NaN;
        iaf_explore_phases(pnum,1).Pval_miss_oposition=NaN;
        iaf_explore_phases(pnum,1).Pval_correlation=NaN;
        iaf_explore_phases(pnum,1).HR_phase_correlation=NaN;
      end
    
    
end

iaf_explore_phases=struct2table(iaf_explore_phases);
iaf_phase_behavior.HIT_RATE=HIT_RATES;
iaf_phase_behavior.ID=Names_Test;
iaf_phase_behavior.Bin_centers=Bin_centers;
save(fullfile(File_st.phase_files_path,[Analysis '_'  Phase_explore_st.output_file '.mat']),'iaf_explore_phases','iaf_phase_behavior');


