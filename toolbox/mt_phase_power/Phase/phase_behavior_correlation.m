function [phase_HR, phase_HR_corr, pval_corr]=phase_behavior_correlation(Hit_phases,Miss_phases,Bin_edges,Bin_centers) 


hit_counts=histcounts(Hit_phases,Bin_edges);
miss_counts=histcounts(Miss_phases,Bin_edges);
         
phase_HR=hit_counts./(hit_counts+miss_counts);
[phase_HR_corr, pval_corr] = circ_corrcl(Bin_centers,phase_HR);

clear hit_counts miss_counts