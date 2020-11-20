clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');

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
        allsuj_behav{i,5}           = perc_corr;
        allsuj_behav{i,6}           = '';

        rt_tot(sb,1)                = med_rt;
        pc_tot(sb,1)                = perc_corr;
        
    end
    
    for sb = 1:length(suj_list)
        
        suj                         = suj_list{sb};
        indx                        = find(strcmp(allsuj_behav(:,2),suj));
        
        if rt_tot(sb,1) < median(rt_tot)
            allsuj_behav{indx,4} = 'fast';
        else
            allsuj_behav{indx,4} = 'slow';
        end
        
        if pc_tot(sb,1) > median(pc_tot)
            allsuj_behav{indx,6} = 'good';
        else
            allsuj_behav{indx,6} = 'bad';
        end
        
    end
    
    clear rt_tot pc_tot
    
end

clearvars -except allsuj_behav ;

list_group = {'old_fast','old_slow','young_fast','young_slow','old_good','old_bad','young_good','young_bad'};

suj_group{1} = allsuj_behav(find(strcmp(allsuj_behav(:,1),'Old') & strcmp(allsuj_behav(:,4),'fast')),2);
suj_group{2} = allsuj_behav(find(strcmp(allsuj_behav(:,1),'Old') & strcmp(allsuj_behav(:,4),'slow')),2);
suj_group{3} = allsuj_behav(find(strcmp(allsuj_behav(:,1),'Young') & strcmp(allsuj_behav(:,4),'fast')),2);
suj_group{4} = allsuj_behav(find(strcmp(allsuj_behav(:,1),'Young') & strcmp(allsuj_behav(:,4),'slow')),2);

save('../data_fieldtrip/index/age_group_performance_split.mat','suj_group');


% suj_group{5} = allsuj_behav(find(strcmp(allsuj_behav(:,1),'Old') & strcmp(allsuj_behav(:,6),'good')),2);
% suj_group{6} = allsuj_behav(find(strcmp(allsuj_behav(:,1),'Old') & strcmp(allsuj_behav(:,6),'bad')),2);
% suj_group{7} = allsuj_behav(find(strcmp(allsuj_behav(:,1),'Young') & strcmp(allsuj_behav(:,6),'good')),2);
% suj_group{8} = allsuj_behav(find(strcmp(allsuj_behav(:,1),'Young') & strcmp(allsuj_behav(:,6),'bad')),2);

fOUT                = '../documents/4R/Age_Behavioral_Performance_eCut.txt';

fid                 = fopen(fOUT,'W+');

fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n','SUB','GROUP','PERF','CUE_CAT','DIS','TAR_SIDE','MedianRT','PerCorrect');

cond_cue            = {'Uninformative','Uninformative','Inforamtive','Inforamtive'};
cond_side           = {'Left','Right','Left','Right'};

cond_ix_cue         = {0,0,1,2};
cond_ix_tar         = {[1 3],[2 4],[1 3],[2 4]};

for sb = 1:length(allsuj_behav)
    
    for icond = 1:length(cond_cue)
        for cond_ix_dis = 1:3
            
            suj     = allsuj_behav{sb,2};
            
            fprintf('Handling %s\n',suj);
            
            group   = allsuj_behav{sb,1};
            pcut    = allsuj_behav{sb,4};
            
            [med_rt,~,perc_corr,~,~] = h_behav_eval(suj,cond_ix_cue{icond},cond_ix_dis-1,cond_ix_tar{icond});
            
            fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%.4f\t%.4f\n',suj,group,pcut,cond_cue{icond},['D' num2str(cond_ix_dis-1)],cond_side{icond},med_rt,perc_corr);
            
        end
    end
end

fclose(fid);