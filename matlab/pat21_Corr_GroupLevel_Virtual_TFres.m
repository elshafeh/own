clear ; clc ;

load ../data/yctot/ArsenalGavg.mat
% load ../data/yctot/ArsenalVirtual2taper.mat

for sb = 1:14
    for n = 1:6
        navg(sb,n,:,:) = source_avg{sb,4,n}(:,:);
    end
end

source_avg = navg ; clearvars -except source_avg ;


for f  = 1:2
    
    orig_list   = -0.7:0.1:1.2;
    tlist       = 0.2:0.1:1;
    
    for t = 1:length(tlist)
        
        t1    = find(round(orig_list,1)== round(tlist(t),1));
        t2    = find(round(orig_list,1)== round(tlist(t),1));
        
        load ../data/yctot/rt_CnD_adapt.mat ;
        
        for n = 1:6
            
            X = mean(squeeze(source_avg(:,n,f,t1:t2)),2);
            
            Y = cellfun(@median,rt_all);
            
            [rho_val(n),p_val(n)] = corr(X,Y', 'type', 'Spearman');
            
            meanP(n) = mean(X);
            clear X Y
            
        end
        
        summ{t,f} = [rho_val' p_val' meanP'];
        
        clear rho_val p_val meanP
        
    end
    
end