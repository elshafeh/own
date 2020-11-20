clear ; clc ;

suj_list = [1:4 8:17] ;

lock = 1 ;

for s = 1:length(suj_list)
    
    suj = ['yc' num2str(suj_list(s))];
    
    pos_orig = load(['/dycog/Aurelie/DATA/MEG/PAT_MEG/pat.meeg/data/' suj '/pos/' suj '.pat2.fin.pos']);
    
    pos_orig        =   pos_orig(pos_orig(:,3)==0,:);
    pos_orig        =   pos_orig(floor(pos_orig(:,2)/1000)==lock,1:2);
    pos_orig(:,3)   =   pos_orig(:,2) - (lock*1000);
    pos_orig(:,4)   =  floor(pos_orig(:,3)/100);
    pos_orig(:,5)   = floor((pos_orig(:,3)-100*pos_orig(:,4))/10);     % Determine the DIS latency
    
    pos_orig        = pos_orig(pos_orig(:,5) == 0,:);
    
    pos_orig(pos_orig(:,4) ~=0,5) =1;
    pos_orig(pos_orig(:,4) ==0,5) =2;
    
    tmp = load(['/dycog/Aurelie/DATA/MEG/PAT_MEG/pat.meeg/data/' suj '/res/' suj '.dsheader.log']);
    dur = tmp(1);
    
    clear tmp
    
    for b = 1:15 
        bloc_dur(b,1) = 600 * dur * (b-1) ;
        bloc_dur(b,2) = 600 * dur * b ;
    end
    
    PrepAtt2_gp_build
    
    clear tmp
    
    cnd     = {'pt1','pt2','pt3'};
    
    % Creating A Fieldtrip Template
    
    for b = 1:3
        
        pos_trans = [];
        
        for n = 1:length(blc_grp{b})
            lim1 = bloc_dur(blc_grp{b}(n),1);
            lim2 = bloc_dur(blc_grp{b}(n),2);
            pos_trans = [pos_trans ; pos_orig(pos_orig(:,1) > lim1 & pos_orig(:,1) < lim2,:)];
        end
        
        for j = 2            
            pos_cond = pos_trans(pos_trans(:,5)==j,:);
            ntrl = 1:length(pos_cond);
            vn_trl_slct{s,b,j} = PrepAtt2_fun_create_rand_array(ntrl,40);
            vn_trl_slct{s,b,j} = sort(vn_trl_slct{s,b,j});      
        end
        
        clear pos_cond ntrl
        
        for j = 1
           
            pos_cond = pos_trans(pos_trans(:,5)==j,:);
            vn_trl_slct{s,b,j} = [];
            
            for p = 1:2
                ntrl = find(pos_cond(:,4) == p);
                xx=PrepAtt2_fun_create_rand_array(ntrl,20);
                vn_trl_slct{s,b,j} = [vn_trl_slct{s,b,j} xx];
                
            end
 
            vn_trl_slct{s,b,j} = sort(vn_trl_slct{s,b,j});
            
        end
        
    end
    
    clearvars -except suj_list vn_trl_slct lock
    
end

save('../data/stat/vn_trl_slct_array.mat','vn_trl_slct')