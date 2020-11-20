clear ; clc ; 

[~,suj_list,~]  = xlsread('../documents/PrepAtt2_PreProcessingIndex.xlsx','B:B');
suj_list        = suj_list(2:73);

%mkdir /media/hesham.elshafei/PAT_MEG2/pat_expe22_backup/

for sb = 1:length(suj_list)
    
    suj             = suj_list{sb};
    
    fprintf('Copying Files For %s\n',suj);
    
    dataIN          = dir(['../data/' suj '/meeg/' suj '.*regress0.ee*']);
    
    for n = 1:size(dataIN)
       
        data_source = ['../data/' suj '/meeg/' dataIN(n).name];
        data_destin = ['/media/hesham.elshafei/PAT_MEG2/pat_expe22_backup/' dataIN(n).name];
        
        copyfile(data_source,data_destin);
        
        clear data_source data_destin
        
    end
    
end