function trl = PrepAtt2_trial_equilibrium(trl_left,trl_right)

trl = [];

for i = 1:250
    
    flag = 0;
    
    while flag == 0
        
        x = randi(size(trl_left,1));
        
        if isempty(trl(trl == trl_left(x)))
            
            trl = [trl trl_left(x)];
            flag = 1;
        end
        
    end
    
end

for i = 1:250
    
    flag = 0;
    
    while flag == 0
        
        x = randi(size(trl_right,1));
        
        if isempty(trl(trl == trl_right(x)))
            
            trl = [trl trl_right(x)];
            flag = 1;
        end
        
    end
    
end

trl = sort(trl);