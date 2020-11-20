function trl = PrepAtt2_target_eq_LRHiLo(inpt)

pos  = inpt ;
code = pos - 3000 ;

ntrl = [];

for n = 1:4    
    ntrl = [ ntrl length(code(mod(code,10)==n))] ;
end

mn_trl = min(ntrl);

trl = [];

for n = 1:4
   
    trl_sn  = find(mod(code,10) == n); 
    trl_rnd = PrepAtt2_fun_create_rand_array(length(trl_sn),mn_trl);
    trl_slct = trl_sn(trl_rnd);
    trl = [trl;trl_slct];
    
    clear trl_*
    
end

trl = sort(trl);