clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,suj_list,~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_list        = suj_list(2:22);

for sb = 1:length(suj_list)
    
    suj              = suj_list{sb};
    
    i =0 ;
    for cond_main = {'DIS','fDIS'}
        
        load(['../data/' suj '/field/' suj '.' cond_main{:} '.leftRightSens.PhaseLockingValueAndFreq.mat']);
        
        i = i + 1;
        
        allsuj{sb,i} = phase_lock ; clear phase_lock ;
        
    end
end

cfg                 = [];
cfg.operation       = 'x1-x2';
cfg.parameter       = 'powspctrm';
grand_average_bsl   = ft_math(cfg,ft_freqgrandaverage([],allsuj{:,1}),ft_freqgrandaverage([],allsuj{:,2}));

cfg=[];
cfg.zlim = [0 0.2];

ft_singleplotTFR(cfg,ft_freqgrandaverage([],allsuj{:,1}));
