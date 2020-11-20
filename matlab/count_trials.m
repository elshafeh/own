clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

suj_list = {'yc1','yc2','yc3','yc4','yc8','yc9','yc10','yc11','yc12','yc13','yc14','yc15','yc16','yc17'};

clearvars -except suj_list

for sb = 1:length(suj_list)
    
    suj                         = suj_list{sb};
    
    fprintf('Loading Virtual Data For %s\n',suj)
    
    dir_data                    = '../data/paper_data/';
    
    load([dir_data suj '.CnD.prep21.AV.1t20Hz.m800p2000msCov.mat']);
    
    list_cue                    = {'R','L','N'};
    list_ix_cue                 = {2,1,0};
    list_ix_tar                 = {1:4,1:4,1:4};
    list_ix_dis                 = {0,0,0};
    
    for ncue = 1:length(list_cue)
        num_trials(sb,ncue)     = length(h_chooseTrial(virtsens,list_ix_cue{ncue},list_ix_dis{ncue},list_ix_tar{ncue}));
    end
    
end

clearvars -except num_trials

final_count = mean(num_trials,2);

mean_count = mean(final_count);
std_count = std(final_count);
sem_count = std_count/sqrt(14);
