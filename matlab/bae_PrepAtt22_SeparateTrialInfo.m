clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,suj_list,~]  = xlsread('../documents/PrepAtt2_PreProcessingIndex.xlsx','B:B');
suj_list        = suj_list(2:73);

for sb = 1:length(suj_list)
    
    suj                 = suj_list{sb};
    
    cond_main           = 'CnD';
    
    fname_in        = ['../data/' suj '/field/' suj '.' cond_main '.mat'];
    
    fprintf('Loading %s\n',fname_in);
    load(fname_in)
   
    trialinfo       = data_elan.trialinfo;
    
    fname_out = [suj '.' cond_main '.TrialInfo'];
    
    fprintf('\n\nSaving %50s \n\n',fname_out);
    
    save(['../data/' suj '/field/' fname_out '.mat'],'trialinfo','-v7.3');
    
end