clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

suj_list = [1:4 8:17]; % {'yc1'}; % [fp_list_all cn_list_all]; clearvars -except suj_list

for sb = 1:length(suj_list)
    
    suj             = [ 'yc' num2str(suj_list(sb))]; % suj_list{sb};
    
    infIN.eegName   = dir(['/Volumes/dycog/Aurelie/DATA/MEG/PAT_MEG21/pat.meeg/data/' suj '/eeg/' suj '*.bp0.1-40.eeg.eeg']);
    
    infIN.eegName   = ['/Volumes/dycog/Aurelie/DATA/MEG/PAT_MEG21/pat.meeg/data/' suj '/eeg/' infIN.eegName.name];
    
    infIN.posName   = ['/Volumes/dycog/Aurelie/DATA/MEG/PAT_MEG21/pat.meeg/data/' suj '/pos/' suj '.pat2.fin.pos'];
    
    infIN.elan_chan = 63:64;
    
    infIN.Fs        = 600;
    
    infIN.code      = [1 2 3 4 101 103 202 204];
    infIN.code      = infIN.code+1000;
    infOUT.name     = ['../data/paper_data/' suj '.CnD.eog.mat'];
    
    h_elan2fieldtrip_intra(infIN,3,3,infOUT);
    
end