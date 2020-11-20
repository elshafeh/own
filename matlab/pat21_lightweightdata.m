clear ; clc ;

for sb = 1:14
    
    cnd_list = {'CnD'};
    
    suj_list = [1:4 8:17];
    
    suj = ['yc' num2str(suj_list(sb))];
    
    for cnd = 1:5
        
        for prt = 1:3
            
            fprintf('\nLoading %20s\n',['../data/' suj '/elan/' suj '.pt' num2str(prt) '.' cnd_list{cnd}]);
            load(['../data/' suj '/elan/' suj '.pt' num2str(prt) '.' cnd_list{cnd} '.mat']);
            
            package = data_elan ;
            package = rmfield(package,'cfg');
            package = rmfield(package,'trial');
           
            clear data_elan 
            
            fprintf('\nSaving %20s\n',['../data/' suj '/elan/' suj '.pt' num2str(prt) '.' cnd_list{cnd} '.pack']);
            save(['../data/' suj '/elan/' suj '.pt' num2str(prt) '.' cnd_list{cnd} '.pack.mat'],'package');
            
            clear package
            
        end
        
        clear prt
        
    end
    
    clear cnd suj_list cnd_list
    
end