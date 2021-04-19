clear;clc;

alldata                 = [];

for nsuj = [1:33 35:36 38:44 46:51]
    
    dir_data            = '~/Dropbox/project_me/data/nback/trialinfo/';
    fname               = [dir_data 'sub' num2str(nsuj) '.trialinfo.mat'];
    load(fname);
    
    
    flg_nback_stim      = find(trialinfo(:,2) == 2);
    sub_info            = trialinfo(flg_nback_stim,[4 5 6]);
    
    sub_info_correct    = sub_info(sub_info(:,1) == 1 | sub_info(:,1) == 3,:); % remove incorrect trials for RT analyses
    sub_info_correct    = sub_info_correct(sub_info_correct(:,2) ~= 0,:); % remove zeros
    
    median_rt           = median(sub_info_correct(:,2));
    
    fast_rt             = mean(sub_info_correct(sub_info_correct(:,2) < median_rt,2)) ./ 1000;
    slow_rt             = mean(sub_info_correct(sub_info_correct(:,2) > median_rt,2)) ./ 1000;
    
    %     fast_rt             = median(sub_info_correct(sub_info_correct(:,2) < median_rt,2)) ./ 1000;
    %     slow_rt             = median(sub_info_correct(sub_info_correct(:,2) > median_rt,2)) ./ 1000;
    
    alldata             = [alldata; fast_rt slow_rt];
    
    
end

keep alldata

boxplot(alldata,'Labels',{'fast RT','slow RT'});
ylabel('Reaction time (s)');
ylim([0 1.4]);
yticks([0 0.2 0.5 0.8 1.1 1.4]);
set(gca,'FontSize',16,'FontName', 'Calibri','FontWeight','normal');
grid;