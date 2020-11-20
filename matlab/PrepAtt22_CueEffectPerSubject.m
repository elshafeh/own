clear ; clc ; close all; 

behav_table = readtable('../documents/PrepAtt22_YoungParticipants_behav_table4R_with.VN.Tukey.csv','Delimiter',';');

for ngroup = unique(behav_table.idx_group)'
    
    group_table = behav_table(behav_table.idx_group==ngroup,:);
    
    for sb = unique(group_table.sub_idx)'
        
        fprintf('Testing Cue Effect On %s\n',['g' num2str(ngroup) 'sub' num2str(sb)]);
        
        inf_rt          = group_table(group_table.sub_idx ==sb & group_table.CUE ~=0 & group_table.DIS==0 & group_table.CORR>0,:);
        unf_rt          = group_table(group_table.sub_idx ==sb & group_table.CUE ==0 & group_table.DIS==0 & group_table.CORR>0,:);
        
        inf_rt          = inf_rt.RT;
        unf_rt          = unf_rt.RT;
        
        flg             = min([length(inf_rt) length(unf_rt)]);
        
        inf_trl_array   = PrepAtt22_fun_create_rand_array(1:length(inf_rt),flg);
        unf_trl_array   = PrepAtt22_fun_create_rand_array(1:length(unf_rt),flg);
        
        inf_rt          = inf_rt(inf_trl_array);
        unf_rt          = unf_rt(unf_trl_array);
        
        [h,p_cue(sb,1)]   = ttest(inf_rt,unf_rt);
        rt_diff(sb,1)     = median(inf_rt)-median(unf_rt);
        
        
        inf_rt          = group_table(group_table.sub_idx ==sb & group_table.CUE ~=0 & group_table.DIS==0 & group_table.CORR==1,:);
        unf_rt          = group_table(group_table.sub_idx ==sb & group_table.CUE ==0 & group_table.DIS==0 & group_table.CORR==1,:);
        
        inf_rt          = inf_rt.RT;
        unf_rt          = unf_rt.RT;
        
        flg             = min([length(inf_rt) length(unf_rt)]);
        
        inf_trl_array   = PrepAtt22_fun_create_rand_array(1:length(inf_rt),flg);
        unf_trl_array   = PrepAtt22_fun_create_rand_array(1:length(unf_rt),flg);
        
        inf_rt          = inf_rt(inf_trl_array);
        unf_rt          = unf_rt(unf_trl_array);
        
        [h,p_cue(sb,2)]   = ttest(inf_rt,unf_rt);
        rt_diff(sb,2)     = median(inf_rt)-median(unf_rt);
        
    end
    
end

clearvars -except p_cue rt_diff; clc ; 

sig = length(p_cue(p_cue<0.1));
phy = length(rt_diff(rt_diff<0));
figure;
hold on
plot(rt_diff(:,1));hline(0,'-k');xlim([0 length(rt_diff)+1]);ylim([-60 60]);
plot(rt_diff(:,2));hline(0,'-k');xlim([0 length(rt_diff)+1]);ylim([-60 60]);
legend({'NoTukey','eTukey'});

figure;
hold on
plot(p_cue(:,1));hline(0,'-k');xlim([0 length(p_cue)+1]);ylim([0 0.1]);
plot(p_cue(:,2));hline(0,'-k');xlim([0 length(p_cue)+1]);ylim([0 0.1]);
legend({'NoTukey','eTukey'});