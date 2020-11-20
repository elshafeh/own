clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,suj_group{1},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_list            = suj_group{1}(2:22);

for sb = 1:length(suj_list)
    
    suj             = suj_list{sb};
    
    load(['../data/' suj '/res/' suj '_final_ds_list.mat']);
    
    infIN.Fs        = 600;
    
    infIN.DsName    = ['../data/' suj '/ds/' final_ds_list{1,2}];
    infIN.eegName   = dir(['../data/' suj '/meeg/' suj '*regress0.eeg']);
    infIN.eegName   = ['../data/' suj '/meeg/' infIN.eegName.name];
    infIN.posName   = ['../data/' suj '/pos/' suj '.pat22.rec.behav.fdis.bad.epoch.rej.fin.fdis.pos'];
    
    infIN.code      = [2011 2012 2013 2014 2021 2022 2023 2024 2111 2113 2121 2123 2212 2214 2222 2224];
    infIN.code      = infIN.code+1000;
    
    infIN.elan_chan = 32:306;
    
    infOUT.name     = ['../data/' suj '/field/' suj '.DT.mat'];
    
    if ~exist(infOUT.name)
        h_elan2fieldtrip(infIN,3,3,infOUT);
    end
    
    infIN.code      = [2011 2012 2013 2014 2021 2022 2023 2024 2111 2113 2121 2123 2212 2214 2222 2224];
    infIN.code      = infIN.code-1000;
    
    infIN.elan_chan = 32:306;
    
    infOUT.name     = ['../data/' suj '/field/' suj '.CD.mat'];
    
    if ~exist(infOUT.name)
        h_elan2fieldtrip(infIN,3,3,infOUT);
    end
    
end

% flg             = dir(['../data/' suj '/field/*.fDIS.mat']);
% if length(flg) < 1
%     infIN.code      = [6011 6012 6013 6014 6021 6022 6023 6024 6111 6113 6121 6123 6212 6214 6222 6224];
%     infIN.elan_chan = 32:306;
%     infOUT.name     = ['../data/' suj '/field/' suj '.fDIS.mat'];
%     h_elan2fieldtrip(infIN,4,4,infOUT);
% end
%
% infIN.eegName   = dir(['../data/' suj '/meeg/' suj '*regress0.eeg']);
% infIN.eegName   = ['../data/' suj '/meeg/' infIN.eegName.name];
% infIN.posName   = ['../data/' suj '/pos/' suj '.pat22.rec.behav.fdis.bad.epoch.rej.fin.fdis.pos'];
%
% infIN.elan_chan = 307:313;
%
% infIN.Fs        = 600;
%
% infIN.code      = [1 2 3 4 101 103 202 204];
% infIN.code      = infIN.code+1000;
% infOUT.name     = ['../data/' suj '/field/' suj '.CnD.eeg.mat'];
%
% if ~exist(infOUT.name)
%     h_elan2fieldtrip_intra(infIN,2,2,infOUT);
% end
%
% infIN.code      = [1 2 3 4 101 103 202 204];
% infIN.code      = infIN.code+3000;
% infOUT.name     = ['../data/' suj '/field/' suj '.nDT.eeg.mat'];
%
% if ~exist(infOUT.name)
%     h_elan2fieldtrip_intra(infIN,2,2,infOUT);
% end
%
% infIN.code      = [2011 2012 2013 2014 2021 2022 2023 2024 2111 2113 2121 2123 2212 2214 2222 2224];
% infOUT.name     = ['../data/' suj '/field/' suj '.DIS.eeg.mat'];
%
% if ~exist(infOUT.name)
%     h_elan2fieldtrip_intra(infIN,2,2,infOUT);
% end
%
% infIN.code      = [6011 6012 6013 6014 6021 6022 6023 6024 6111 6113 6121 6123 6212 6214 6222 6224];
% infOUT.name     = ['../data/' suj '/field/' suj '.fDIS.eeg.mat'];
% if ~exist(infOUT.name)
%     h_elan2fieldtrip_intra(infIN,2,2,infOUT);
% end