clear ; clc ;

[~,suj_list,~]  = xlsread('../documents/PrepAtt2_PreProcessingIndex.xlsx','B:B');
suj_list        = suj_list(2:73);

for sb = 1:length(suj_list)
    
    suj             = suj_list{sb};
    
    load(['../data/' suj '/res/' suj '_final_ds_list.mat']);
    
    DsName    = ['/media/hesham.elshafei/PAT_MEG2/pat_expe22_backup_ds/' final_ds_list{1,2}];
    fprintf('Copying %s\n',final_ds_list{1,2});
    
    system(['cp -r ' DsName ' /mnt/autofs/Aurelie/DATA/MEG/PAT_EXPE22/data/' suj '/ds/.']);
    
end