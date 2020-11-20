clear ; clc ;

lck = 'CnD';
    
for s = [1:4 8:17]
    
    suj = ['yc' num2str(s)] ;
    
    conds_sep = {'L','R'};
    
    for p = 1:3
        
        fprintf('\n Loading %30s\n',[suj '.pt' num2str(p) '.V' lck]);
        load(['../data/' suj '/elan/' suj '.pt' num2str(p) '.V' lck '.mat']);
        
        data = data_elan ;
        
        clear data_elan
        
        trl = data.trialinfo ;
        
        trl(:,2) = trl(:,1) - 1000;
        trl(:,3) = floor(trl(:,2)/100);
        
        cnd_sav = {'L','R'};
        
        for c = 1:2
            
            trl_array = find(trl(:,3) == c);
            
            cfg        = [];
            cfg.trials = trl_array;
            data_elan  = ft_selectdata(cfg,data);
            
            fprintf('\n Saving %30s\n',[suj '.pt' num2str(p) '.' cnd_sav{c} lck]);
            save(['../data/' suj '/elan/' suj '.pt' num2str(p) '.' cnd_sav{c} lck '.mat'],'data_elan','-v7.3');
            
            clear data_elan trl_array
            
        end
        
        clear data trl
        
    end
    
end