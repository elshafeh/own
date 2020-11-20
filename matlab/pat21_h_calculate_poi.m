function new_allsuj = h_calculate_poi(allsuj,i_A,i_B,i_all)

for sb = 1:size(allsuj,1)
    
    itc_A                               = allsuj{sb,i_A}.powspctrm ;
    itc_B                               = allsuj{sb,i_B}.powspctrm ;
    itc_all                             = allsuj{sb,i_all}.powspctrm ;
    
    poi                                 = itc_A + itc_B - (2*itc_all);
    
    new_allsuj{sb,1}                    = allsuj{sb,i_A};
    new_allsuj{sb,1}.powspctrm          = poi;
    
    clear itc* poi
    
    new_allsuj{sb,2}                    = new_allsuj{sb,1} ;
    new_allsuj{sb,2}.powspctrm(:,:,:)   = 0;
    
end