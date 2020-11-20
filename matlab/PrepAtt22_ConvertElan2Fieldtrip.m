clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

% [~,suj_group{1},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
% suj_list            = suj_group{1}(2:22);

suj_list            = {'oc2','oc10'};

for sb = 1:length(suj_list)
    
    suj             = suj_list{sb};
    
    data_directory  = '/Users/heshamelshafei//Desktop/tmp_ageing_elan/';
    
    infIN.eegName   = [data_directory suj '.pat22.preprocess4ERP.0.2_40.eeg'];
    infIN.posName   = [data_directory suj '.pat22.rec.behav.fdis.bad.epoch.rej.fin.fdis.pos'];
    
    infIN.elan_chan = 307:313;
    
    infIN.Fs        = 600;
    
    infIN.code      = [1 2 3 4 101 103 202 204];
    infIN.code      = infIN.code+1000;
    infOUT.name     = [data_directory suj '.CnD.eeg.mat'];
    
    data_elan       = h_elan2fieldtrip_intra(infIN,2,2);
    save(infOUT.name,'data_elan','-v7.3'); clear data_elan;
    
    infIN.code      = [1 2 3 4 101 103 202 204];
    infIN.code      = infIN.code+3000;
    infOUT.name     = [data_directory suj '.nDT.eeg.mat'];
    
    data_elan       = h_elan2fieldtrip_intra(infIN,2,2);
    save(infOUT.name,'data_elan','-v7.3'); clear data_elan;
    
    infIN.code      = [2011 2012 2013 2014 2021 2022 2023 2024 2111 2113 2121 2123 2212 2214 2222 2224];
    infOUT.name     = [data_directory suj '.DIS.eeg.mat'];
    
    data_elan       = h_elan2fieldtrip_intra(infIN,2,2);
    save(infOUT.name,'data_elan','-v7.3'); clear data_elan;

    infIN.code      = [6011 6012 6013 6014 6021 6022 6023 6024 6111 6113 6121 6123 6212 6214 6222 6224];
    infOUT.name     = [data_directory suj '.fDIS.eeg.mat'];
    h_elan2fieldtrip_intra(infIN,2,2);
    
    data_elan       = h_elan2fieldtrip_intra(infIN,2,2);
    save(infOUT.name,'data_elan','-v7.3'); clear data_elan;
    
end