clear ; clc ;
addpath('/Users/heshamelshafei/fieldtrip/'); ft_defaults;

global ft_default
ft_default.spmversion = 'spm12';

[~,suj_list,~]              = xlsread('../../documents/PrepAtt22_PreProcessingIndex.xlsx','A:B');
suj_list                    = suj_list(2:22,2);

ilu                         = 0;

for sb = 1
    
    suj                     = suj_list{sb};
    list_cond               = {'DIS','fDIS'};
    
    for ncond = 1
        
        fname               = ['../../data/scnd_round/' suj '.' list_cond{ncond} '.AudTPFC.1t120Hz.m200p800msCov.mpdc.mat'];
        
        fprintf('Loading %20s\n',fname); load(fname);
        
        fwin                = 20;
        
        mpdc.pdcspctrm      = 5.*log((1+mpdc.pdcspctrm)./(1-mpdc.pdcspctrm)); clear data;
        
        for nfreq = 40
            
            ix1                 = find(mpdc.freq == nfreq);
            ix2                 = find(mpdc.freq == nfreq+fwin);
            
            dataF               = squeeze(mean(mpdc.pdcspctrm(:,:,ix1:ix2),3));
            
            for seed = 1:length(mpdc.label)
                for target = 1:length(mpdc.label)
                    
                    if seed ~= target
                        
                        ilu                             = ilu + 1;
                        grng                            = dataF(seed,target) - dataF(target,seed);
                        
                        fprintf('%.2f\n',grng);
                        
                    end
                    
                end
            end
        end
    end
end