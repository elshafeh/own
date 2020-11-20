function [File_st,Analysis,Power_st,Phase_st,POS_st,Phase_explore_st]=Default_input_values(flag)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Mireia Torralba 2017 (MRG group)
%
% Configuration file, for general values
%
% Inputs
%  flag:    Group or IAF analysis (case independent), only required when
%  number of outputs is >1
% Outputs
%  File_st:     Path names
%  Power_st:        Settings for power analysis
%  Phase_st:        Settings for phase analysis
%  POS_st:          Settings for POS analysis
%  Phase_explore:   Settings for significant POS freq-el points exploration
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%Path names
File_st=[];
File_st.preproc_main_path='C:\Users\U66300\Dropbox (UPF-MRG)\Cortex_preregister\02_Cortex_Preproc\';
File_st.info_path='C:\Users\U66300\Dropbox (UPF-MRG)\Cortex_preregister\02_Cortex_Preproc\05_INFO_FILES_preproc\';
File_st.preproc_files_path='C:\Users\U66300\Dropbox (UPF-MRG)\Cortex_preregister\02_Cortex_Preproc\04_OUTPUT\';
File_st.power_files_path='C:\Users\U66300\Dropbox (UPF-MRG)\Cortex_preregister\04_Cortex_Analysis\Power\';
File_st.phase_files_path='C:\Users\U66300\Dropbox (UPF-MRG)\Cortex_preregister\04_Cortex_Analysis\Phase\';

load Cortex_labels;
load Cortex_neighbours;
load Cortex_layout;

if nargout>1
    
    %Main analysis
    Analysis=lower(flag);
    
    assert(isequal(Analysis,'group')|isequal(Analysis,'iaf'),'Please set the flag to group or iaf');
    
    switch Analysis
        case 'group'
            FOI=5:1:15;
            Avg_trials='yes';
        case 'iaf'
            FOI=[];
            Avg_trials='no';
    end
    
    %Power structure
    Power_st=[];
    Power_st.preproc='preproc_power';
    Power_st.output_file='power';
    Power_st.stats_output_file='power_stats';
    Power_st.Num_cycles=4;
    Power_st.Taper='hanning';
    Power_st.output='pow';
    Power_st.Nrandomizations=1e4;
    Power_st.neighbours=neighbours;
    Power_st.FOI=FOI;
    Power_st.Avg_trials=Avg_trials;
    Power_st.peaks_output_file='iaf_trl_peaks';
    Power_st.labels=LABELS;
    Power_st.layout=layout;
    
    %Phase structure
    Phase_st=[];
    Phase_st.preproc='preproc_phase';
    Phase_st.output_file='phase';
    Phase_st.Num_cycles=2;
    Phase_st.Taper='hanning';
    Phase_st.output='fourier';
    Phase_st.FOI=FOI;
    Phase_st.peaks_output_file=Power_st.peaks_output_file;
    Phase_st.labels=LABELS;
    Phase_st.layout=layout;
    %POS structure
    POS_st=[];
    POS_st.output_file='pos';
    POS_st.null_output_file='null_pos';
    POS_st.stat_file='stats_pos';
    POS_st.Null_pos=1e4;
    %Phase exploration structure
    Phase_explore_st.output_file='phase_explore';
    Phase_explore_st.Nrandomizations=1e4;
    Phase_explore_st.Numbins=11;
    Phase_explore_st.Expected_difference=pi;
    Phase_explore_st.alpha=0.05;
    Phase_explor_st.labels=LABELS;
end
