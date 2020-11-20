function trl_array = PrepAtt2_fun_create_rand_array(ntrl,limit)

trl_array = [];

for i = 1:limit
    
    flag = 0;
    
    while flag == 0
        
        x = randi(length(ntrl));
        
        if isempty(trl_array(trl_array == ntrl(x)))
            
            trl_array = [trl_array ntrl(x)];
            
            flag = 1;
            
        end
        
    end
    
end

