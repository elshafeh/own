addpath('C:\Users\U66300\toolbox\CircStat2012a\');
addpath('C:\Users\U66300\toolbox\fieldtrip-20161103\');
addpath(genpath(pwd));
ft_defaults;
clearvars
%%%% SCRIPT FOR GROUP POWER ANALYSIS

%Intialize path structure
[File_st,Analysis,Power_st]=Default_input_values('group');
%Get list of participants available in selected participants directory
Names_Test=Participant_IDs(File_st,'Test');

Analysis2='iaf'

%Calculate the power for each participant
for pnum=1:size(Names_Test,2)
    
    load(fullfile(File_st.power_files_path,[Analysis2 '_' Names_Test{pnum} '_' Power_st.output_file '.mat']));
    
    cfg=[];
    cfg.param='powdb';
    cfg.avgoverrpt='yes';
    power_hit=ft_selectdata(cfg,power_hit);
    power_miss=ft_selectdata(cfg,power_miss);
    power_hit.freq=1:11;
    power_miss.freq=1:11;
    group_power_hit{pnum,1}=power_hit;
    group_power_miss{pnum,1}=power_miss;
    
    cfg=[];
    cfg.parameter='powdb';
    cfg.operation='subtract';
    group_power_contrast{pnum,1}=ft_math(cfg,power_hit,power_miss);
    
    
end
clear navgP;

% And now perfom stats: Paired t-test Hit vs Miss (left tail) alpha
% level=0.05. Minimum number of neighbours=2; Multiple comparison
% correction: Cluster

cfg = [];
cfg.parameter='powdb';
cfg.channel          = group_power_hit{1,1}.label;
cfg.method           = 'montecarlo';
cfg.statistic        = 'ft_statfun_depsamplesT';
cfg.correctm         = 'cluster';
cfg.clusteralpha     = 0.05;
cfg.clusterstatistic = 'maxsum';
cfg.minnbchan        = 2;
cfg.tail             = -1;%NOTICE THIS IS CORRECT IF WE COMPARE HITS VERSUS MISSES
cfg.clustertail      = cfg.tail;
cfg.alpha            = 0.05;
cfg.numrandomization = Power_st.Nrandomizations;
cfg.avgoverfreq='no';
cfg.avgoverchan='no';%

cfg.neighbours=Power_st.neighbours;% prepare_neighbours determines what sensors may form clusters
design=[];
design(1,:) = cat(2,1:size(group_power_hit,1),1:size(group_power_miss,1));
design(2,:) = cat(2,ones(1,size(group_power_hit,1)),2*ones(1,size(group_power_miss,1)));

cfg.design   = design;
cfg.ivar     = 2;
cfg.uvar     = 1;
cfg.design           = design;

group_power_stat = ft_freqstatistics(cfg, group_power_hit{:},group_power_miss{:});
save(fullfile(File_st.power_files_path,[Analysis '_' Analysis2 'centered_' Power_st.stats_output_file '.mat']),'group_power_stat');


cfg=[];
cfg.parameter='powdb';
avg_hit=ft_freqgrandaverage(cfg,group_power_hit{:});
avg_miss=ft_freqgrandaverage(cfg,group_power_miss{:});

cfg=[];
cfg.parameter='powdb';   
cfg.operation='subtract';
avg_contrast_db=ft_math(cfg,avg_hit,avg_miss);

cfg=[];
cfg.parameter='powdb';
cfg.layout=Power_st.layout;

for foi=1:length(avg_contrast_db.freq)
    subplot(3,4,foi)
    cfg.comment=['f=' num2str(avg_contrast_db.freq(foi)) ' Hz'];
    cfg.xlim=[avg_contrast_db.freq(foi) avg_contrast_db.freq(foi)];
    cfg.zlim=[-0.5 0.5];
    ft_topoplotTFR(cfg,avg_contrast_db);
    colormap('jet')
end

cfg=[];
cfg.layout=Power_st.layout;
cfg.alpha=0.15;
cfg.subplotsize=[2 3];
cfg.comment=' '
ft_clusterplot(cfg,group_power_stat);
colormap('jet')
