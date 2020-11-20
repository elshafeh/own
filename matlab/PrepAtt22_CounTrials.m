clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

% [~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');
%
% suj_group{1}    = allsuj(2:15,1);
% suj_group{2}    = allsuj(2:15,2);
% lst_group       = {'Old','Young'};

[~,suj_group{1},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_group{1}        = suj_group{1}(2:22);
lst_group           = {'AllYoung'};

trial_summary   = {};
i               = 0;

for ngrp = 1:length(suj_group)
    
    suj_list = suj_group{ngrp};
    
    for sb = 1:length(suj_list)
        
        suj          = suj_list{sb};
        posIN        = load(['../data/' suj '/pos/' suj '.pat22.rec.behav.fdis.bad.epoch.rej.fin.fdis.pos']);
        posIN        = posIN(posIN(:,3)==0 & floor(posIN(:,2)/1000)==1,2)-1000;
        posIN(:,2)   = floor(posIN(:,1)/100); % determines cue condition
        posIN(:,3)   = floor((posIN(:,1)-100*posIN(:,2))/10);     % Determine distractor latency
        posIN(:,4)   = posIN(:,1) - (posIN(:,2)*100 + posIN(:,3)*10);
        
        list_cue     = {'NCue','LCue','RCue'};
        list_tar     = {'LLow','RLow','LHigh','RHigh'};
        
        for ncue = 0:2
            for ndis = 0:2
                for ntar = 1:4
                                        
                    if strcmp(list_cue{ncue+1}(1),'N')
                        
                        i = i +1;

                        
                        mtrx_len = length(posIN(posIN(:,2)==ncue & posIN(:,3)==ndis & posIN(:,4)==ntar,1));
                        
                        trial_summary{i,1} = suj;
                        trial_summary{i,2} = lst_group{ngrp};
                        trial_summary{i,3} = list_cue{ncue+1};
                        trial_summary{i,4} = list_tar{ntar};
                        trial_summary{i,5} = ['D' num2str(ndis)];
                        trial_summary{i,6} = mtrx_len;
                        trial_summary{i,7} = 'UnInformative';
                        
                    else
                        
                        if strcmp(list_cue{ncue+1}(1),list_tar{ntar}(1))
                            
                            i = i +1;
                            
                            mtrx_len = length(posIN(posIN(:,2)==ncue & posIN(:,3)==ndis & posIN(:,4)==ntar,1));
                            
                            trial_summary{i,1} = suj;
                            trial_summary{i,2} = lst_group{ngrp};
                            trial_summary{i,3} = list_cue{ncue+1};
                            trial_summary{i,4} = list_tar{ntar};
                            trial_summary{i,5} = ['D' num2str(ndis)];
                            trial_summary{i,6} = mtrx_len;
                            trial_summary{i,7} = 'Informative';
                            
                        end
                    end
                    
                end
            end
        end
    end
end

clearvars -except trial_summary

trial_table                  = array2table(trial_summary,'VariableNames',{'SUJ' ;'GROUP'; 'CUE'; 'TAR'; 'DIS' ;'NTRIAL';'CUE_CAT'});

writetable(trial_table,'../documents/PrepAtt22_TrialCount.csv','Delimiter',';')
% clearvars -except trial_summary
