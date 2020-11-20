clear ; clc ; 

for sb = 1:14
   
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))];
    pos_orig       = load(['../pos/' suj '.pat2.fin.pos']);
    
    lock = 1 ;
    
    pos_orig = pos_orig(pos_orig(:,3)==0,:);
    pos_orig = pos_orig(floor(pos_orig(:,2)/1000)==lock,1:2);
    pos_orig(:,3)=pos_orig(:,2) - (lock*1000);
    pos_orig(:,4)=floor(pos_orig(:,3)/100);
    pos_orig(:,5)    = floor((pos_orig(:,3)-100*pos_orig(:,4))/10);     % Determine the DIS latency
    
    pos_orig = pos_orig(pos_orig(:,5) == 0,:);
    
    rt_indx{sb,1} = find(pos_orig(:,4) ~= 0); % 1 inf 2 unf
    rt_indx{sb,2} = find(pos_orig(:,4) == 0); % 1 inf 2 unf
    
    clear pos_orig
    
end

load ../data/yctot/rt/rt_CnD_adapt.mat;

for sb = 4
    for cond = 1:2
        tmp = rt_indx{sb,cond} ;
        mx  = length(rt_all{sb});
        tmp(tmp>mx) = [];
        rt_indx{sb,cond} = tmp ;
    end
end

clearvars -except rt*

for sb = 1:14
    for cond = 1:2
        rt_classified{sb,cond} = rt_all{sb}(rt_indx{sb,cond});
    end
end

clearvars -except rt*

save('../data/yctot/rt/rt_cond_classified_iunf.mat');