clear ; clc ;

for sb = [11:17 2:4 8:9]
    
    suj         =   ['yc' num2str(sb)];
    

    PrepAtt2_fun_noncorr_eeg2field_cue(suj,4,4)
    
end