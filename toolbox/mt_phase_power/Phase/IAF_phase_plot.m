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


load Cortex_labels


for pnum=1:size(Names_Test,2)
    
    %Calculate the phase for each participant
    load(fullfile(File_st.phase_files_path,[Analysis '_' Names_Test{pnum} '_' POS_st.stat_file '.mat']),'pvalue','adjusted_pvalue');
    run(fullfile(File_st.info_path,[Names_Test{ pnum} '_info_preproc.m']));
    load(part.layout);
    
    
    plot_data.label=LABELS;
    plot_data.dimord='chan_freq';
    plot_data.freq=part.IAF-5:1:part.IAF+5;
    plot_data.pval=pvalue';
    h=figure
    title(Names_Test{pnum})
    for foi=1:length(plot_data.freq)
        subplot(3,4,foi)
        cfg=[];
        cfg.layout=layout;
        cfg.parameter='pval';
        cfg.xlim=[plot_data.freq(foi) plot_data.freq(foi)];
        cfg.zlim=[0 0.05];
        cfg.comment=['f=' num2str(plot_data.freq(foi)) 'Hz'];
        ft_topoplotTFR(cfg,plot_data);
        colormap('jet')
    end
    
    saveas(h,['C:\Users\U66300\Dropbox (UPF-MRG)\Mireia\05 MATLAB\00 Mireia\08_Cortex_Analysis_files\Plots\' Analysis '_' Names_Test{pnum} '_pos_plot.tif'],'tiff');
    close all
end



