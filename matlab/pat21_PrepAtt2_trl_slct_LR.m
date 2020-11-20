clear ; clc ;

suj_list = [1:4 8:17] ;

lock = 1 ;

for a = 1:length(suj_list)
    
    suj = ['yc' num2str(suj_list(a))];
    
    clear tmp
    
    cond = {'RCnD','LCnD'};
    
    for b = 1:3
        
        for c = 1:2
            
            fname = [suj '.pt' num2str(b) '.' cond{c} '.mat'];
            fprintf('Loading %30s\n',fname);
            load(['../data/' suj '/elan/' fname]);
            
            ntrl = 1:length(data_elan.trialinfo);
            
            lr_trl_slct{a,b,c} = PrepAtt2_fun_create_rand_array(ntrl,40);
            lr_trl_slct{a,b,c} = sort(lr_trl_slct{a,b,c});
            
            clear pos_cond ntrl
        end
        
    end
    
end

note = 'a is subject b is bloc c is condition : 1 is R and 2 is left';
save('../data/stat/lr_trl_slct_array.mat','lr_trl_slct','note');