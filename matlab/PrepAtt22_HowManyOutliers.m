clear ; clc ;

behav_summary             = [];

for sb = 1:21
    
    suj                       = ['yc' num2str(sb)];
    behav_in_recoded          = load(['../data/' suj '/pos/' suj '.pat22.rec.behav.fdis.bad.epoch.rej.fin.fdis.pos']);
    
    ntrl                      = length(behav_in_recoded(behav_in_recoded(:,2)==255));

    behav_in_recoded          = [behav_in_recoded(:,3)  behav_in_recoded(:,3) behav_in_recoded(:,2) behav_in_recoded(:,1)];
    
    i                         = 0;
    
    suj_matrix                = [];
    
    for n = 1:length(behav_in_recoded)
        if  floor(behav_in_recoded(n,3)/1000)==1
            
            i        = i + 1;
            code     = behav_in_recoded(n,3)-1000;  CUE=floor(code/100);  DIS=floor((code-100*CUE)/10); TAR=mod(code,10); if TAR>2;XP=2;else XP=1;end;
            
            
            fcue=1; p=1; cnsnt = 5/3;
            
            while fcue==1 && n+p <=length(behav_in_recoded)
                
                acc_width = behav_in_recoded(n+p,4) - behav_in_recoded(n,4);
                acc_width = acc_width * cnsnt;
                
                if floor(behav_in_recoded(n+p,3)/1000)~=1 && (behav_in_recoded(n+p,4) > behav_in_recoded(n+p-1,4)) && acc_width <= 5000
                    p=p+1;
                else
                    fcue=2;
                end
                
            end
            
            if i < ntrl;p                   = p-2;else p = p -1;end;
            
            trl                 = behav_in_recoded(n-1:n+p,:);
            trl_tot{i}          = trl;
            
            if DIS == 0 && unique(trl(:,1)) == 0
                
                cuetmp              = find(floor(trl(:,3)/1000)==1);
                tartmp              = find(floor(trl(:,3)/1000)==3);
                reptmp              = find(floor(trl(:,3)/1000)==9);
                
                cueON               = trl(cuetmp(1),4);
                tarON               = trl(tartmp(1),4);
                
                RT                  = trl(reptmp(1),4)-tarON;
               
                suj_matrix          = [suj_matrix; RT i];
                
            end
        end
    end
    
    clearvars -except sb suj_matrix behav_summary trl_tot suj behav_in_recoded
    
    new_data                         = PrepAtt22_calc_tukey(suj_matrix(:,1));
    suj_matrix                       = [suj_matrix(:,2) new_data]; clear new_data ;
    noutliers                        = length(suj_matrix(suj_matrix(:,3)==2));
    
    o_array                          = suj_matrix(suj_matrix(:,3)==2,1);
    i_array                          = PrepAtt22_fun_create_rand_array(suj_matrix(suj_matrix(:,3)==1,1),noutliers);
    
    posOUT                           = [];
    
    for n = 1:length(trl_tot)
        
        i_in = i_array(i_array == n);
        o_in = o_array(o_array == n);
        
        if length(i_in) == 1
            code_add = 10000;
        elseif length(o_in) == 1
            code_add = 20000;
        else
            code_add = 0;
        end
        
        posOUT       = [posOUT; trl_tot{n}(1,4) trl_tot{n}(1,3) trl_tot{n}(1,2)];
        
        for k = 2:length(trl_tot{n})
            posOUT  = [posOUT;trl_tot{n}(k,4) trl_tot{n}(k,3)+code_add trl_tot{n}(k,2)];
        end
        
    end
    
    clearvars -except sb suj posOUT behav_in_recoded;
    
    posnameout                  = ['../data/' suj '/pos/' suj '.pat22.rec.behav.fdis.bad.epoch.rej.fin.fdis.outliers.pos'];
    
    dlmwrite(posnameout,posOUT,'Delimiter','\t' ,'precision','%10d');
    
    clearvars -except sb
    
end