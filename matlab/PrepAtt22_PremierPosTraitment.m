clear ; clc ; close all;

addpath(genpath('../../fieldtrip-20151124/'));

[~,suj_list,~]  = xlsread('../documents/temp/New_PrepAtt22_Participant_Index_and_Preprocessing_Progress.xlsx','B:B');
suj_list        = suj_list(2:end);
load('../documents/pick_jump_ElanConcatFileToUse.mat');
summary = table2array(summary) ;

for sb = 1:length(suj_list)
    
    suj                     = suj_list{sb};
    
    ElanFile                = ['../data/' suj '/meeg/' summary{sb,2} '.eeg'];
    
    if strcmp(summary{sb,1},suj)
        
        fprintf('Handling %s\n',suj);
        
        if exist(ElanFile,'file')
            
            PosFile                     = ['../data/' suj '/pos/' suj '.pat22.pos'];
            posIN                       = load(PosFile);
            
            %remove unwanted codes
            posIN                       =  PrepAtt22_funk_pos_prepare(posIN,sb,1,1);
            
            % recode events and correct for trigger delays
            pos_rec                     = PrepAtt22_funk_pos_recode(posIN);
            posnameout                  = ['../data/' suj '/pos/' suj '.pat22.rec.pos'];
            dlmwrite(posnameout,[pos_rec(:,4) pos_rec(:,3)  zeros(length(pos_rec),1)],'Delimiter','\t' ,'precision','%10d');
            
            % evaluate behavioral performance
            [trl_tot,behav_summary,pos_behav]             = PrepAtt22_funk_pos_summary(pos_rec);
            posnameout                  = ['../data/' suj '/pos/' suj '.pat22.rec.behav.pos'];
            dlmwrite(posnameout,pos_behav,'Delimiter','\t' ,'precision','%10d');
            
            % add fake distractors
            pos_fdis                     = PrepAtt22_funk_pos_AddFakeDistractors(pos_behav);
            posnameout                   = ['../data/' suj '/pos/' suj '.pat22.rec.behav.fdis.pos'];
            dlmwrite(posnameout,pos_fdis,'Delimiter','\t' ,'precision','%10d');
            
            % add bad segments
            pos_bad                      = PrepAtt22_funk_pos_BadSegmentFuse(suj,pos_fdis);
            posnameout                   = ['../data/' suj '/pos/' suj '.pat22.rec.behav.fdis.bad.pos'];
            dlmwrite(posnameout,pos_bad,'Delimiter','\t' ,'precision','%10d');
            
            %Epoch
            [pos_epoch,trial]               = PrepAtt22_PosFile_Epoch(suj,pos_bad);
            posnameout                      = ['../data/' suj '/pos/' suj '.pat22.rec.behav.fdis.bad.epoch.pos'];
            dlmwrite(posnameout,pos_epoch,'Delimiter','\t' ,'precision','%10d');
            
            [ntot,nmiss,nfa,ninc,ntte,njump,premain] = PrepAtt22_funk_behav_report(pos_bad);
            
            medRT       = median(behav_summary(behav_summary(:,10)==1,11));
            meanRT      = mean(behav_summary(behav_summary(:,10)==1,11));
            
            big_behav_summary{sb,1}      = suj;
            big_behav_summary{sb,2}      = ntot;
            big_behav_summary{sb,3}      = nmiss;
            big_behav_summary{sb,4}      = nfa;
            big_behav_summary{sb,5}      = ninc;
            big_behav_summary{sb,6}      = ntte;
            big_behav_summary{sb,7}      = njump;
            big_behav_summary{sb,8}      = premain;
            big_behav_summary{sb,9}      = medRT;
            big_behav_summary{sb,10}     = meanRT;
            
            clearvars -except trialpot suj sb suj_list summary big_behav_summary;
            
            fprintf('\n');
            
        end
    end
end

clearvars -except big_behav_summary

big_behav_table                   = array2table(big_behav_summary,'VariableNames',{'suj' ;'ntot'; 'nmiss'; 'nfa';'ninc'; 'ntte' ;'njump' ...
    ;'premain'; 'medRT' ;'meanRT'});

writetable(big_behav_table,'../documents/PrepAtt22_PosFileTreatmentResults.csv','Delimiter',';')