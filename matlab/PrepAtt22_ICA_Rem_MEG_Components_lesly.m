clear ; clc ;

ICA_table = readtable('../documents/PrepAtt22_ICA_Comp_lesly.xlsx');
suj_list  = ICA_table.suj;

addpath(genpath('/dycog/Aurelie/DATA/mat_prog/BlinkCorrection'));
addpath('/dycog/matlab/prog/util_ELAN/conversion_generique');

for sb = 1:length(suj_list)
    
    suj = suj_list{sb};
    
    idx = strcmp(ICA_table.suj,suj);
    
    load(['../data/' suj '/res/' suj '_eeg_file_list.mat'])
    
    dirIN       = ['../data/' suj '/meeg/' eeg_file_list{5,2} '.eeg'];
    dirXML      = ['../data/' suj '/meeg/' eeg_file_list{4,2} '.meg.xml'];
    dirOUT      = [dirIN(1:end-4) '.icacorrMEG'];
    
    str1        = table2array(ICA_table(idx,2:end));
    str1        = num2str(str1(~isnan(str1)));
    
    space       = ' ';
    
    ligne=['eegfiltica ' dirIN space dirXML space dirOUT space str1];
    system(ligne);
    
    system(['rm ../data/' suj '/meeg/' suj '.ICA.p']);
    system(['rm ../data/' suj '/meeg/' suj '.ICA.eeg']);
    system(['rm ../data/' suj '/meeg/' suj '.ICA.eeg.ent']);
    
end

