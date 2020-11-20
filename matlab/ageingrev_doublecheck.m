clear ; clc ;

suj_list                    = {'oc1','oc2','oc3','oc4','oc5','oc6','oc7','oc8','oc9','oc10','oc11','oc12','oc13','oc14', ...
    'yc1','yc10','yc11','yc4','yc18','yc21','yc7','yc19','yc15','yc14','yc5','yc13','yc16','yc12'};

alldisdelay                     = [];

for nb_bin                      = 10
    
    for sb = 1:length(suj_list)
        
        suj                     = suj_list{sb};
        fprintf('Handling %s\n',suj);
        
        behav_table             = h_behavdis_eval(suj);
        behav_table             = behav_table(behav_table.CORR ==1,:);
        
        vctr                    = [behav_table.CD behav_table.RT behav_table.DIS];
        
        list_bin                = linspace(148,503,nb_bin);
        
        bin_width               = list_bin(2) - list_bin(1);
        list_bin                = [0 list_bin];
        
        for nbin = 1:length(list_bin)-1
            
            if nbin ==1
                sb_vctr         = vctr(vctr(:,1) == 0,[2 3]);
            else
                t1              = list_bin(nbin);
                t2              = (t1 + bin_width)-1;
                sb_vctr         = vctr(vctr(:,1) >= t1 & vctr(:,1) <= t2,[2 3]);
                
            end
            
            hi                  = unique(sb_vctr(:,2));
            ho                  = hi;
            
        end
        
        
    end
end