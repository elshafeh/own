clear ; clc ; addpath(genpath('../fieldtrip-20151124/')); close all;

load ../data/data_fieldtrip/allyc_ageing_suj_list_1Old_2Young_3AllYoung.mat
suj_group      = suj_group(1:2);

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj                                 = suj_list{sb};
        
        dir_data                            = '../data/ageing_data/';
        
        fname_in                            = [dir_data suj '.CnD.AV.1t20Hz.M.1t40Hz.m800p2000msCov.mtmfftPOW.1t20Hz.m3000p3000.AvgTrials.mat'];
        
        fprintf('Loading %s\n',fname_in);
        
        load(fname_in)
        
        allsuj_data{sb} = freq ; clear freq ;
        
    end
    
    grand_average{ngroup}               = ft_freqgrandaverage([],allsuj_data{:});
    grand_average{ngroup}.powspctrm     = grand_average{ngroup}.powspctrm/1e20;
end

clearvars -except grand_average

for nchan = 1:length(grand_average{1}.label)
    
    subplot(3,2,nchan)
    hold on
    
    for ngroup = 1:2
        plot(round(grand_average{ngroup}.freq),grand_average{ngroup}.powspctrm(nchan,:),'LineWidth',2);
        xlim([1 20]);
        ylim([0 6])
    end
    
    legend({'OLD','YOUNG'});
    title(grand_average{1}.label{nchan});
    xlabel('Frequency (Hz)');
    ylabel('Power/1e20');
    
end