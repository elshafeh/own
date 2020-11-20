clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,suj_group{1},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_group{1}        = suj_group{1}(2:22);

[~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');

suj_group{2}    = allsuj(2:15,1);
suj_group{3}    = allsuj(2:15,2);

lst_group       = {'Allyoung','Old','Young'};

fOUT            = '../documents/4R/3Groups_CueNoDis_TrialNumber.txt';

fid             = fopen(fOUT,'W+');

fprintf(fid,'%s\t%s\t%s\t%s\t%s\n','SUB','GROUP','CUE_CAT','TAR_SIDE','NTrials');

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj             = suj_list{sb};
        
        fprintf('Handling %s\n',suj)
        
        name_group      = lst_group{ngroup};
        
        load(['../data/' suj '/field/' suj '.CnD.TrialInfo.mat']);
        
        data_elan       = [];
        data_elan.trialinfo = trialinfo; clear trialinfo
        
        cond_cue        = {'Uninformative','Uninformative','Inforamtive','Inforamtive'};
        cond_side       = {'Left','Right','Left','Right'};
        
        cond_ix_cue     = {0,0,1,2};
        cond_ix_dis     = {0,0,0,0};
        cond_ix_tar     = {[1 3],[2 4],[1 3],[2 4]};
        
        for icond = 1:length(cond_cue)
            
            trial_choose    = h_chooseTrial(data_elan,cond_ix_cue{icond},cond_ix_dis{icond},cond_ix_tar{icond});
            
            fprintf(fid,'%s\t%s\t%s\t%s\t%d\n',suj,name_group,cond_cue{icond},cond_side{icond},length(trial_choose));
            
        end
        
    end
end

fclose(fid);