clear ; clc ; close ; dleiftrip_addpath ;

load ../data/yctot/RevComeOnKeepTrialsExtWav.mat;

% smooth

for sb = 1:size(allsuj,1)
    
    t_orig = -3:0.05:3 ;
    f_orig = 1:20 ;
    
    for cnd = 1:size(allsuj,2)
        
        t1 = find(round(t_orig,2) == -0.70);
        t2 = find(round(t_orig,2) == 1.3);
        
        allsuj{sb,cnd} = allsuj{sb,cnd}(:,:,:,t1:t2);
        
        clear t1 t2 f1 f2
        
        ts = -0.7:0.05:1.3;
        
        tbsl1 = find(round(ts,2) == -0.60);
        tbsl2 = find(round(ts,2) == -0.20);
        bsl   = mean(allsuj{sb,cnd}(:,:,:,tbsl1:tbsl2),4);
        
        for chn = 1:6
            
            ix_t = 0 ;
            
            for t = 1:2:size(allsuj{sb,cnd},4)-1
                
                ix_t = ix_t + 1 ;
                
                mtm = squeeze(mean(allsuj{sb,cnd}(:,:,:,t:t+2),4));
                mtm = (mtm - bsl) ./ bsl ;
                
                frq_list = [9 13];
                
                for f = 1:2
                    
                    tp  = 2;
                    t_mtm = mean(mtm(:,chn,frq_list(f)-tp:frq_list(f)+tp),3);
                    
                    new_avg{sb,cnd,chn}(f,ix_t,:) = t_mtm ;
                    
                    clear t_mtm
                    
                end
                
                clear mtm
                
            end
            
        end
        
    end
    
end

source_avg = new_avg ;

clearvars -except source_avg

save('../data/yctot/ArsenalVirtualKT2taper');