clear;clc;dleiftrip_addpath;close all;

load ../data/yctot/postConn&MotorExtWav.mat ; clear allsuj note ext;

load ../data/yctot/Virtual4Anova.mat; virt = source_avg(:,:,:,:,:) ; clear source_avg
load ../data/yctot/TfRes4Anova.mat; tres = source_avg ; clear source_avg

for sb = 1:14
    for chn = 1:34
        for f = 1:size(tres,4)
            for t = size(tres,5)
                tres(sb,5,chn,f,t) = mean([tres(sb,1,chn,f,t) tres(sb,2,chn,f,t)]);
            end
        end
    end
end

source_avg = cat(6,virt,tres); clear virt tres;

frq_list    = [6 9 12 15];
tm_list     = -0.6:0.2:2;
chn_list    = template.label;

% sb,cond,chan,freq,time,calc

for cnd_calc = 1:2
    
    for sb = 1:14
        
        for cnd = 1:3
            
            for chn = 1:34
                
                tmp = squeeze(source_avg(sb,cnd,chn,:,:,cnd_calc)) ;
                
                t1 = find(round(tm_list,2) == -0.6);
                t2 = find(round(tm_list,2) == -0.2);
                
                bsl_prt         = repmat(mean(tmp(:,t1:t2),2),1,size(tmp,2));
                
                tmp = (tmp-bsl_prt) ./ bsl_prt;
                
                source_avg(sb,cnd,chn,:,:,cnd_calc) = tmp;
                
                clear tmp t1 t2 bsl_prt
                
            end
            
        end
        
    end
    
end

clearvars -except source_avg *_list

chn  = 2 ;
f    = 4 ;
t    = 0.4 ; t = find(round(tm_list,2) == round(t,2));
calc = 1;

rcue = squeeze(source_avg(:,1,chn,f,t,calc));
lcue = squeeze(source_avg(:,2,chn,f,t,calc));
ncue = squeeze(source_avg(:,3,chn,f,t,calc));

p_rl = permutation_test([rcue lcue],1000);
p_rn = permutation_test([rcue ncue],1000); 
p_ln = permutation_test([lcue ncue],1000); 

boxplot([rcue lcue ncue])
ylim([-0.5 0.5])