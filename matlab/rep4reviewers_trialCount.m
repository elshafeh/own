clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

[~,suj_group{1},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_list            = suj_group{1}(2:22);

for sb = 1:length(suj_list)
    
    suj             = suj_list{sb};
    suj_trialinfo   = [];
    
    load(['../data/dis_rep4rev/' suj '.CnD.TrialInfo.mat']);
    suj_trialinfo   = [suj_trialinfo;trialinfo]; clear trialinfo;
    
    load(['../data/dis_rep4rev/' suj '.DIS.trialinfo.mat']);
    suj_trialinfo   = [suj_trialinfo;trialinfo]; clear trialinfo;
    
    data.trialinfo  = suj_trialinfo;
    
    ix              = 0;
    
    %     list_cue        = {0,[1,2]};
    %     list_dis        = {0,1,2};
    %     list_tar        = {1,2,3,4};
    
    list_cue        = {0,[1,2]};
    list_dis        = {0,[1:2]};
    list_tar        = {1:4};
    
    for ncue = 1:length(list_cue)
        for ndis = 1:length(list_dis)
            for ntar = 1:length(list_tar)

                ntrls   = h_chooseTrial(data,list_cue{ncue},list_dis{ndis},list_tar{ntar});
                ntrls   = length(ntrls);
                ix      = ix+1;
                
                allsuj_info(ix,sb) = ntrls; clear ntrls;
                
            end
        end
    end
end

clearvars -except allsuj_info

mean_allsuj_info        = mean(allsuj_info,2);
sem_allsuj_info         = std(allsuj_info,0,2)/sqrt(size(allsuj_info,2));

for n = 1:length(mean_allsuj_info)
    fprintf('%.2f ? %.2f\n',mean_allsuj_info(n),sem_allsuj_info(n));
end

sum__allsuj_info        = sum(allsuj_info,2);