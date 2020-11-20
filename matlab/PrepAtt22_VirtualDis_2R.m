clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,suj_group{1},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_group{1}        = suj_group{1}(2:22);

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        list_cue = {'V','N'};
        list_dis = {'DIS','fDIS'};
        
        for ncue = 1:length(list_cue)
            for ndis = 1:length(list_dis)
                
                suj                     = suj_list{sb};
                
                ext_name1               = '1t20Hz';
                ext_name2               = '.broadAuditoryAreas.50t120Hz.m200p800msCov.waveletPOW.50t119Hz.m1000p1000.KeepTrials.mat';
                
                fprintf('\nLoading %50s \n',fname_in);
                load(fname_in)
                
                for ndelay              = 1:2
                    
                    cfg                 = [];
                    cfg.
                    
                    
                    
                end
                
            end
            
        end
    end
end