clear ; clc ; dleiftrip_addpath ;

load ../data/yctot/PaperExtWav.mat

for sb = 1:14
    
    t1 = find(round(template.time,1) == -0.6);
    t2 = find(round(template.time,1) == -0.2);
    
    tmp             = allsuj{sb,5}(1:10,:,:);
    bsl_prt         = repmat(mean(tmp(:,:,t1:t2),3),1,1,size(tmp,3));
    
    new{sb}       = (tmp-bsl_prt) ./ bsl_prt;
    
    clear tmp bsl_prt
    
end

clearvars -except new template

allsuj = new ; clear new ;

bigassmatrix_freq = [];

toi_list    = [-0.6 0.2 0.6 1.4];
tm_win      = 0.4;
frq_list    = 7:15;

for t = 1:length(toi_list)
    
    for sb = 1:14
        
        for chn = 1:size(allsuj{1},1)
            
            t1 = find(round(template.time,2) == round(toi_list(t),2));
            t2 = find(round(template.time,2) == round(toi_list(t)+0.4,2));
            f1 = find(round(template.freq) == 7);
            f2 = find(round(template.freq) == 15);
            
            pow = squeeze(mean(allsuj{sb}(chn,f1:f2,t1:t2),3));
           
            x = find(pow==max(pow));
            y = find(pow==min(pow));
            
            bigassmatrix_freq(sb,chn,t,1) = frq_list(y(1)); % min
            bigassmatrix_freq(sb,chn,t,2) = frq_list(x(1)); % max
            
            clear data frq_sj pow
            
        end
        
    end
    
end

clearvars -except bigassmatrix_freq

save('../data/yctot/PaperIAF_Freq.mat');