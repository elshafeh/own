function [Results,Raw_table,Stat_table]=Descriptive_phases(Names_Test,Best_point,Bin_edges,Bin_centers,Phase_explore_st,Results,shifted_idx,shifted_Bin_centers)

    Hit_direction=nan(length(Names_Test),1);
    Miss_direction=nan(length(Names_Test),1);
    Hit_kappa=nan(length(Names_Test),1);
    Miss_kappa=nan(length(Names_Test),1);
    
    
    for pnum=1:size(Names_Test,2)
        %Fit Von Mises distribution to Hits and Misses
        [Hit_direction(pnum),Hit_kappa(pnum)] = circ_vmpar(Best_point(pnum).Hit_phases);
        [Miss_direction(pnum),Miss_kappa(pnum)] = circ_vmpar(Best_point(pnum).Miss_phases);
        %Get phase distributions with preferred Hit phase aligned to 0 degrees
        Shifted_hit=wrapToPi(Best_point(pnum).Hit_phases-Hit_direction(pnum));
        Shifted_miss=wrapToPi(Best_point(pnum).Miss_phases-Hit_direction(pnum));
        
        %Divide phase data into 11 bins, calculate phase-specific hit-rate
        %and calculate. Align: 0 bin corresponds to mean Hit phase for each participant.
        shifted_HIT_RATES(pnum,:)=phase_behavior_correlation(Shifted_hit,Shifted_miss,Bin_edges,Bin_centers);
        HIT_RATES(pnum,:)=phase_behavior_correlation(Best_point(pnum).Hit_phases,Best_point(pnum).Miss_phases,Bin_edges,Bin_centers);
    end
    
    Hit_to_miss=wrapToPi(circ_dist(Hit_direction,Miss_direction));
    
    %Test if mean Misses distribution is concentrated aroud mean Hits+180º
    pvalue_miss=circ_vtest(Hit_to_miss,Phase_explore_st.Expected_difference);
   
    shifted_HIT_RATES=shifted_HIT_RATES(:,shifted_idx);
    
    %Change labels!!!     
    Stat_table.ID=Names_Test';
    for i=1:size(shifted_HIT_RATES,2)
    eval(['Stat_table.HR_bin' num2str(shifted_idx(i)) '=squeeze(shifted_HIT_RATES(:,i));']);
    end
    
    Raw_table.ID=Names_Test';
    Raw_table.Hit_direction=Hit_direction;
    Raw_table.Hit_concentration=Hit_kappa;
    Raw_table.Miss_direction=Miss_direction;
    Raw_table.Miss_concentration=Miss_kappa;
    Raw_table.Hit_to_miss_distance=Hit_to_miss;
    for i=1:size(HIT_RATES,2)
    eval(['Raw_table.HR_bin' num2str(i) '=squeeze(HIT_RATES(:,i));']);
    end
    %Save data
    Stat_table=struct2table(Stat_table);
    Raw_table=struct2table(Raw_table);
    
    Results.Miss_oposition_p_value=pvalue_miss;
    Results.Mean_hit=circ_mean(Hit_direction);
    Results.Mean_miss=circ_mean(Miss_direction);
    
    Results.Shifted_bins=shifted_Bin_centers;
    Results.Shifted_HR=shifted_HIT_RATES;
    Results.Bins=Bin_centers;
    Results.HR=HIT_RATES;
    Results.IDs=Names_Test;
    
    %Significance test: ANOVA on hit rate (remove central bin).
 