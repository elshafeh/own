clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));
clear ; clc ; 

[~,suj_group{1},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_list            = suj_group{1}(2:22);

for sb = 1:length(suj_list)
    
    suj             = suj_list{sb};
    
    infIN.eegName   = dir(['/Volumes/Pat22Backup/pat_expe22_back_meeg/' suj '.*pat22.*153.o3.eeg']);
    infIN.eegName   = ['/Volumes/Pat22Backup/pat_expe22_back_meeg/' infIN.eegName.name];
    infIN.posName   = ['/Volumes/Pat22Backup/pat_expe22_back_meeg/' suj '.pat22.rec.behav.fdis.bad.epoch.rej.fin.fdis.pos'];
    
    infIN.elan_chan = 307:313;
    infIN.Fs        = 600;
    
    infIN.code      = [2011 2012 2013 2014 2021 2022 2023 2024 2111 2113 2121 2123 2212 2214 2222 2224];
    infOUT.name     = ['/Volumes/Pat22Backup/pat_expe22_back_meeg/' suj '.DIS.eeg.nonfilt.mat'];
    
    if ~exist(infOUT.name)
        h_elan2fieldtrip_intra(infIN,2,2,infOUT);
    end
    
    infIN.code      = [6011 6012 6013 6014 6021 6022 6023 6024 6111 6113 6121 6123 6212 6214 6222 6224];
    infOUT.name     = ['/Volumes/Pat22Backup/pat_expe22_back_meeg/' suj '.fDIS.eeg.nonfilt.mat'];
    
    if ~exist(infOUT.name)
        h_elan2fieldtrip_intra(infIN,2,2,infOUT);
    end
    
end