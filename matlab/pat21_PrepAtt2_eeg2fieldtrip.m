clear ; clc ; dleiftrip_addpath ; 

for sb = 11:17
    
    suj      =   ['yc' num2str(sb)];
    PrepAtt2_fun_construct_fieldstruct_custom_hc_bp(suj,9,3,3)
    
end