clear ; clc ; dleiftrip_addpath ; close all ; 

for sb = 1:14
    
    suj_list = [1:4 8:17];
    
    suj = ['yc' num2str(suj_list(sb))];
    
    dis_carrier = {}; fdis_carrier={};
    
    for dis_cond = 1:3;
        
        fname = ['../data/' suj '/tfr/' suj '.DIS' num2str(dis_cond) '.all.wav.1t100Hz.m3000p3000.mat'];
        fprintf('Loading %30s\n',fname);
        load(fname);
        
        dis_carrier{dis_cond}              = freq;
        
        clear freq
        
        fname = ['../data/' suj '/tfr/' suj '.fDIS' num2str(dis_cond) '.all.wav.1t100Hz.m3000p3000.mat'];
        fprintf('Loading %30s\n',fname);
        load(fname);
        
        fdis_carrier{dis_cond}              = freq;
        
        clear freq
        
    end
    
    clear fname dis_cond
    
    freq = ft_freqgrandaverage([],dis_carrier{:});
    fname = ['../data/' suj '/tfr/' suj '.DIS.all.wav.1t100Hz.m3000p3000.mat'];
    save(fname,'freq');

    clear freq dis_carrier fname
    
    freq = ft_freqgrandaverage([],fdis_carrier{:});
    fname = ['../data/' suj '/tfr/' suj '.fDIS.all.wav.1t100Hz.m3000p3000.mat'];
    save(fname,'freq');
    
    clear freq fdis_carrier fname
    
end
