clear ; clc ;

for sb = 2:14
    
    suj_list = [1:4 8:17];
    suj = ['yc' num2str(suj_list(sb))];
    
    cnd_list = {'nDT'};
    
    for cnd = 1:length(cnd_list)
        
        trialinfo = [];
        
        for prt = 1:3
            
            fprintf('\nLoading %20s\n',['../data/elan/' suj '.pt' num2str(prt) '.' cnd_list{cnd}]);
            load(['../data/elan/' suj '.pt' num2str(prt) '.' cnd_list{cnd} '.mat']);
            
            trialinfo = [trialinfo;data_elan.trialinfo]; clear data_elan ; 
            
        end
        
        clear prt ;
        
        save(['../data/trialinfo/' suj '.' cnd_list{cnd} '.trialinfo.mat'],'trialinfo'); clear trialinfo
        
    end
    
end