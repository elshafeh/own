function r_PrepAtt22_MEEG_Filt_0240_ajdc(list_all_suj)

%load('../documents/list_all_suj.mat'); %list_all_suj

%list_all_suj = {'mg1'}; %{'yc9'};

for sb = 1:length(list_all_suj)
    
    suj = list_all_suj{sb};
    
    cd(['../data/' suj '/meeg/'])
    
    if strcmp(suj,'yc9')
        
        %%filtrage MEG pour yc9
        
        EEGfileIN   = [ suj '.pat22.3rdOrder.jc.offset.meeg.swap.bs47t53.o3.bs97t103.o3.bs147t153.o3.bp0point1t40.o3.corrajdc.eeg'];
        EEGfileOUT = [ suj '.pat22.preprocess4ERP_ajdc.0.2_40.eeg'];
        parfileMEG  = '../../../par/meg.bp0.2_40.o3.ajdc.par'
        
        ligne       = ['eegfiltfilt ' EEGfileIN ' ' parfileMEG ' ' EEGfileOUT];
        
        system(ligne);
        
    else
        
        %%filtrage MEG/EEG
        EEGfileIN   = [ suj '.pat22.3rdOrder.jc.offset.meeg.swap.bs47t53.o3.bs97t103.o3.bs147t153.o3.bp0point1t40.o3.corrajdc.eeg'];
        EEGfileOUT = [ suj '.pat22.preprocess4ERP_ajdc.0.2_40.eeg'];
        parfileMEG  = '../../../par/meeg.bp0.2_40.o3.ajdc.par'
        
        ligne       = ['eegfiltfilt ' EEGfileIN ' ' parfileMEG ' ' EEGfileOUT];
        
        system(ligne);
        
    end
    cd ../../../scripts.m/
    
end




