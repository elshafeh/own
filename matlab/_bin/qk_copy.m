clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

[~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');

suj_list        = allsuj(2:15,1);
suj_list        = [suj_list;allsuj(2:15,2)];

[~,suj_group,~] = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_list        = unique([suj_list;suj_group(2:22)]);

for sb = 1:length(suj_list)
    
    suj                                 = suj_list{sb};
    
    dir_data                            = ['/Volumes/PAM/Aurelie/DATA/MEG/PAT_EXPE22/data/' suj '/ds/'];
    DsName                              = [dir_data suj '.pat2.restingstate.thrid_order.ds/'];
    
    if exist(DsName)
        
        fprintf('copying for %s\n',suj);
        system(['cp -r ' DsName ' ../data/resting_state/.']);
        
    end
    
end