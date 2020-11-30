clear;

n_rnd               = 10000;

for n = 1:n_rnd
    
    t1  = GetSecs;
    
    x   = 0;
    
    for lu = 1:n_rnd
        x   = x + randi(10);
    end
    
    t2              = GetSecs;
    t_check(n,1)    = t2-t1;

end

plot(t_check(:,1));
ylim([0 0.1]);