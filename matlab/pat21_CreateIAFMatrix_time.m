clear ; clc ; dleiftrip_addpath ;

clear ; clc ; dleiftrip_addpath ;

load ../data/yctot/postConn&NewMotorExtWav.mat

for sb = 1:14
    
    t1 = find(round(template.time,1) == -0.6);
    t2 = find(round(template.time,1) == -0.2);
    
    tmp             = allsuj{sb,5}([1:6 31:34],:,:);
    bsl_prt         = repmat(mean(tmp(:,:,t1:t2),3),1,1,size(tmp,3));
    
    new{sb}       = (tmp-bsl_prt) ./ bsl_prt;
    
    clear tmp bsl_prt
    
end

clearvars -except new template

allsuj = new ; clear new ;

load('../data/yctot/PaperIAF_Freq.mat'); hubahuba = bigassmatrix_freq ;

bigassmatrix_freq = [];

toi_list = [-0.6 0.2 0.6 1.4];
tm_win   = 0.4;
frq_list = 7:15;

for t = 1:length(toi_list)
    
    for sb = 1:14
        
        for chn = 1:size(allsuj{1},1)
            
            t1 = find(round(template.time,2) == round(toi_list(t),2));
            t2 = find(round(template.time,2) == round(toi_list(t)+tm_win,2));
            
            f_min = find(round(template.freq) == hubahuba(sb,chn,t,1));
            f_max = find(round(template.freq) == hubahuba(sb,chn,t,2));
            
            nw_tlist = template.time(t1):0.05:template.time(t2);
            
            pow         = squeeze(allsuj{sb}(chn,f_min,t1:t2));
            t_min       = find(pow==min(min(pow)));
            
            pow         = squeeze(allsuj{sb}(chn,f_min,t1:t2));
            t_max       = find(pow==max(max(pow)));
            
            bigassmatrix_freq(sb,chn,t,1) = nw_tlist(t_min); % min
            bigassmatrix_freq(sb,chn,t,2) = nw_tlist(t_max); % max
            
            clear data frq_sj pow
            
        end
        
        
    end
    
end

clearvars -except bigassmatrix_freq bigassmatrix_time

save('../data/yctot/PaperIAF_time.mat');