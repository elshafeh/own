clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,allsuj,~]    = xlsread('../documents/PrepAtt22_New_Matching4Matlab.xlsx','A:B');

suj_group{1}    = allsuj(2:15,1);
suj_group{2}    = allsuj(2:15,2);

i               = 0;

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    list_grp = {'Old','Young'};
    
    for sb = 1:length(suj_list)
        
        i                           = i + 1;
        
        suj                         = suj_list{sb};
        
        list_ix_cue                 = 0:2;
        list_ix_tar                 = 1:4;
        list_ix_dis                 = 0;
        [med_rt,~,perc_corr,~,~]    = h_behav_eval(suj,list_ix_cue,list_ix_dis,list_ix_tar); clc ;
        
        allsuj_behav{i,1}           = list_grp{ngroup};
        allsuj_behav{i,2}           = suj;
        allsuj_behav{i,3}           = med_rt;
        allsuj_behav{i,4}           = '';
        
        list_ix_cue                 = [1 2];
        [inf_rt,~,~,~,~]            = h_behav_eval(suj,list_ix_cue,list_ix_dis,list_ix_tar); clc ;

        list_ix_cue                 = 0;
        [unf_rt,~,~,~,~]            = h_behav_eval(suj,list_ix_cue,list_ix_dis,list_ix_tar); clc ;
        
        rt_tot(sb,1)                = med_rt;
        td_ind_tot(sb,1)            = unf_rt - inf_rt;
        perc_tot(sb,1)              = perc_corr;
        
    end
    
    for sb = 1:length(suj_list)
        
        suj                         = suj_list{sb};
        indx                        = find(strcmp(allsuj_behav(:,2),suj));
        
        if rt_tot(sb,1) < median(rt_tot)
            allsuj_behav{indx,4} = [list_grp{ngroup} '_fast'];
        else
            allsuj_behav{indx,4} = [list_grp{ngroup} '_slow'];
        end
        
        if td_ind_tot(sb,1) < median(td_ind_tot)
            allsuj_behav{indx,5} = [list_grp{ngroup} '_bad_use'];
        else
            allsuj_behav{indx,5} = [list_grp{ngroup} '_good_use'];
        end
        
        if perc_tot(sb,1) > median(perc_tot)
            allsuj_behav{indx,6} = [list_grp{ngroup} '_high_perf'];
        else
            allsuj_behav{indx,6} = [list_grp{ngroup} '_low_perf'];
        end
        
    end
    
    clear rt_tot
    
end

clearvars -except allsuj_behav ;

save('../data/data_fieldtrip/age_group_cut_by_3.mat','allsuj_behav');

% list_group = {'old_fast','old_slow','young_fast','young_slow'};
%
% suj_group{1} = allsuj_behav(find(strcmp(allsuj_behav(:,1),'Old') & strcmp(allsuj_behav(:,4),'fast')),2);
% suj_group{2} = allsuj_behav(find(strcmp(allsuj_behav(:,1),'Old') & strcmp(allsuj_behav(:,4),'slow')),2);
% suj_group{3} = allsuj_behav(find(strcmp(allsuj_behav(:,1),'Young') & strcmp(allsuj_behav(:,4),'fast')),2);
% suj_group{4} = allsuj_behav(find(strcmp(allsuj_behav(:,1),'Young') & strcmp(allsuj_behav(:,4),'slow')),2);
%
% save('../data/data_fieldtrip/age_group_cut_by_reaction_time.mat','suj_group','list_group');
%
% list_group = {'old_good','old_bad','young_good','young_bad'};
%
% suj_group{1} = allsuj_behav(find(strcmp(allsuj_behav(:,1),'Old') & strcmp(allsuj_behav(:,5),'good_use')),2);
% suj_group{2} = allsuj_behav(find(strcmp(allsuj_behav(:,1),'Old') & strcmp(allsuj_behav(:,5),'bad_use')),2);
% suj_group{3} = allsuj_behav(find(strcmp(allsuj_behav(:,1),'Young') & strcmp(allsuj_behav(:,5),'good_use')),2);
% suj_group{4} = allsuj_behav(find(strcmp(allsuj_behav(:,1),'Young') & strcmp(allsuj_behav(:,5),'bad_use')),2);
%
% save('../data/data_fieldtrip/age_group_cut_by_cue_use.mat','suj_group','list_group');
%
% list_group = {'old_high','old_low','young_high','young_low'};
%
% suj_group{1} = allsuj_behav(find(strcmp(allsuj_behav(:,1),'Old') & strcmp(allsuj_behav(:,6),'high_perf')),2);
% suj_group{2} = allsuj_behav(find(strcmp(allsuj_behav(:,1),'Old') & strcmp(allsuj_behav(:,6),'low_perf')),2);
% suj_group{3} = allsuj_behav(find(strcmp(allsuj_behav(:,1),'Young') & strcmp(allsuj_behav(:,6),'high_perf')),2);
% suj_group{4} = allsuj_behav(find(strcmp(allsuj_behav(:,1),'Young') & strcmp(allsuj_behav(:,6),'low_perf')),2);
%
% save('../data/data_fieldtrip/age_group_cut_by_perc_correct.mat','suj_group','list_group');

% list_group = {'old_fast','old_slow','young_fast','young_slow'};
%
% suj_group{1} = allsuj_behav(find(strcmp(allsuj_behav(:,1),'Old') & strcmp(allsuj_behav(:,4),'fast')),2);
% suj_group{2} = allsuj_behav(find(strcmp(allsuj_behav(:,1),'Old') & strcmp(allsuj_behav(:,4),'slow')),2);
% suj_group{3} = allsuj_behav(find(strcmp(allsuj_behav(:,1),'Young') & strcmp(allsuj_behav(:,4),'fast')),2);
% suj_group{4} = allsuj_behav(find(strcmp(allsuj_behav(:,1),'Young') & strcmp(allsuj_behav(:,4),'slow')),2);
%
% save('../data/data_fieldtrip/age_group_cut_by_reaction_time.mat','suj_group','list_group');

% fOUT                = '../documents/4R/Age_Behavioral_Performance_NewMatch.txt';
%
% fid                 = fopen(fOUT,'W+');
%
% fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n','SUB','GROUP','PERF','CUE_CAT','DIS','TAR_SIDE','MedianRT','PerCorrect');
%
% cond_cue        = {'Uninformative','Uninformative','Inforamtive','Inforamtive'};
% cond_side       = {'Left','Right','Left','Right'};
%
% cond_ix_cue     = {0,0,1,2};
% cond_ix_tar     = {[1 3],[2 4],[1 3],[2 4]};
%
% for ngroup = 1:length(suj_group)
%
%     suj_list = suj_group{ngroup};
%
%     list_grp = {'Old','Young'};
%
%     for sb = 1:length(suj_list)
%
%         suj                         = suj_list{sb};
%
%         for icond = 1:length(cond_cue)
%             for cond_ix_dis = 1:3
%
%                 group   = list_grp{ngroup};
%                 pcut    = 'all';
%
%                 [med_rt,~,perc_corr,~,~] = h_behav_eval(suj,cond_ix_cue{icond},cond_ix_dis-1,cond_ix_tar{icond});
%
%                 fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%.4f\t%.4f\n',suj,group,pcut,cond_cue{icond},['D' num2str(cond_ix_dis-1)],cond_side{icond},med_rt,perc_corr);
%
%             end
%         end
%     end
% end
%
% fclose(fid);