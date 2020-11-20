% Create TFR gavg 

clear ; clc ; dleiftrip_addpath ;

for sb = 1:14
    
    cnd_list = {'bp'};
    
    suj_list = [1:4 8:17] ;
    
    suj = ['yc' num2str(suj_list(sb))];
    
    for cnd = 1:length(cnd_list)
        
        load(['../data/' suj '/tfr/' suj '.' cnd_list{cnd} '.all.wav.5t18Hz.m3p3.mat']);
        
        freq.cfg = [];
        
        allsuj{sb,cnd} = freq ; 
        
    end
end

clearvars -except allsuj

for cnd = 1:size(allsuj,2)
    
    Gavg{cnd}       = ft_freqgrandaverage([],allsuj{:,cnd});
    Gavg{cnd}.cfg   = [];
    
end

save('../data/yctot/gavg/bp.gavg.mat');