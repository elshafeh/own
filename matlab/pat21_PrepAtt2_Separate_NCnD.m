clear ; clc ;

lck = 'nDT';
    
for s = [1:4 8:17]
    
    suj = ['yc' num2str(s)] ;
    
    for p = 1:3
        
        fprintf('\n Loading %30s\n',[suj '.pt' num2str(p) '.N' lck]);
        load(['../data/' suj '/elan/' suj '.pt' num2str(p) '.N' lck '.mat']);
        
        data = data_elan ;
        
        clear data_elan
        
        trl = data.trialinfo ;
        
        trl(:,2) = trl(:,1) - 3000;
        trl(:,3) = floor(trl(:,2)/100);
        trl(:,4) = trl(:,2) - 3000*trl(:,3);
        
        cnd_sav = {'LT','RT'};
        
        for c = 1:2
            
            trl_array = sort([find(trl(:,4) == c);find(trl(:,4) == c+2)]);
            
            cfg        = [];
            cfg.trials = trl_array;
            data_elan  = ft_selectdata(cfg,data);
            
            fprintf('\n Saving %30s\n',[ suj '.pt' num2str(p) '.N' lck(1:2) cnd_sav{c} '.mat']);
            save(['../data/' suj '/elan/' suj '.pt' num2str(p) '.N' lck(1:2) cnd_sav{c} '.mat'],'data_elan','-v7.3');
            
            clear data_elan trl_array
            
        end
        
        clear data trl
        
    end
    
end