clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

[~,suj_group{1},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_list            = suj_group{1}(2:22);

for sb = 1:length(suj_list)
    
    suj                 = suj_list{sb};
    
    infIN.eegName       = dir(['/Volumes/PAM/Aurelie/DATA/MEG/PAT_EXPE22/data/' suj '/meeg/' suj '.pat22.*regress0.eeg']);
    infIN.eegName       = ['/Volumes/PAM/Aurelie/DATA/MEG/PAT_EXPE22/data/' suj '/meeg/' infIN.eegName.name];
    infIN.posName       = ['/Volumes/PAM/Aurelie/DATA/MEG/PAT_EXPE22/data/' suj '/pos/' suj '.pat22.rec.behav.fdis.bad.epoch.rej.fin.fdis.pos'];
    
    infIN.elan_chan     = 307:313;
    infIN.Fs            = 600;
    
    infIN.code          = [2011 2012 2013 2014 2021 2022 2023 2024 2111 2113 2121 2123 2212 2214 2222 2224];
    
    data_elan           = h_elan2fieldtrip_intra(infIN,2,2);
    
    rep4reviewers_infunctionWavelet(data_elan,suj,'DIS.eeg.regress')
    
    infIN.code          = [6011 6012 6013 6014 6021 6022 6023 6024 6111 6113 6121 6123 6212 6214 6222 6224];
    data_elan           = h_elan2fieldtrip_intra(infIN,2,2);
    
    rep4reviewers_infunctionWavelet(data_elan,suj,'fDIS.eeg.regress')
    
end