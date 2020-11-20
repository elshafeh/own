clear ; clc ;

ICA_table = readtable('../documents/PrepAtt22_ICA_fenetres_lesly.xlsx');
suj_list  = ICA_table.suj;

addpath(genpath('/dycog/Aurelie/DATA/mat_prog/BlinkCorrection'));
addpath('/dycog/matlab/prog/util_ELAN/conversion_generique');

for sb = 1:length(suj_list)
    
    suj = suj_list{sb};
    
    idx = strcmp(ICA_table.suj,suj);
    
    fs  = 600;
    t1  = ICA_table.meg(idx);
    
    if ~isnan(t1)
        
        t2  = t1+ (60*fs); % prend 1 minute de signal après l'échantillon récupéré dans le fichier xlsx
        
        load(['../data/' suj '/res/' suj '_eeg_file_list.mat'])
        
        dirIN  = ['../data/' suj '/meeg/' eeg_file_list{4,2} '.eeg'];
        
        [m_data,m_events,~,~,~,s_nb_channel_all,v_label_all,~,~,~,~] = eeg2mat(dirIN,ICA_table.meg(idx),ICA_table.meg(idx)+10,'all');
        
        list_chan = 32:306;
        
        if strcmp(v_label_all{list_chan(end)}(1:5),'MZP01') && strcmp(v_label_all{list_chan(1)}(1:5),'MLC11')
            
            dirXML = ['../data/' suj '/meeg/' eeg_file_list{4,2} '.meg.xml'];
            
%             if ~exist(dirXML)
                
                fprintf('Computing ICA Matrix For %s\n\n',dirIN);
                
%                 eegICA(dirIN, t1, t2, list_chan, dirXML)
                
                space = ' ';
                
                dirOUT =  ['../data/' suj '/meeg/' eeg_file_list{4,2} '.ICA.meg'];
                
                fprintf('Converting Matrix For %s\n\n',dirIN);
                
                ligne=['matrix2p ' dirIN ' ' dirXML ' ' dirOUT ' -i'];
                system(ligne);
                
                ligne=['eegproject' space dirIN space dirXML space dirOUT];
                system(ligne);
                
                system(['cp ' dirOUT '.p ../data/' suj '/meeg/' suj '.ICA.p']);
                system(['cp ' dirOUT '.eeg ../data/' suj '/meeg/' suj '.ICA.eeg']);
                system(['cp ' dirOUT '.eeg.ent ../data/' suj '/meeg/' suj '.ICA.eeg.ent']);
                

            end
%         end
        
    end
    
end