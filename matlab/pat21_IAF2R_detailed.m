clear; clc ; dleiftrip_addpath ;

load('../data/yctot/PaperIAF_Freq.mat');

fOUT = '../txt/mean_IAF4R_perCond.txt';
fid  = fopen(fOUT,'W+');
fprintf(fid,'%5s\t%5s\t%5s\t%5s\n','SUB','TIME','ROI','IAF');

for t = 1:4
    
    cnd_time = {'bsl','early','late','post'};
    
    visAlpha1 =   bigassmatrix_freq(:,1,t,2);
    visAlpha2 =   bigassmatrix_freq(:,2,t,2);
    audAlpha1 =   bigassmatrix_freq(:,3,t,1);
    audAlpha2 =   bigassmatrix_freq(:,4,t,1);
    audAlpha3 =   bigassmatrix_freq(:,5,t,1);
    audAlpha4 =   bigassmatrix_freq(:,6,t,1);
    motAlpha1 =   bigassmatrix_freq(:,7,t,1);
    motAlpha2 =   bigassmatrix_freq(:,8,t,1);
    motAlpha3 =   bigassmatrix_freq(:,9,t,1);
    motAlpha4 =   bigassmatrix_freq(:,10,t,1);
    
    mean_iaf{t,1} = mean(cat(2,audAlpha1,audAlpha3),2);
    mean_iaf{t,2} = mean(cat(2,motAlpha1,motAlpha3),2);
    mean_iaf{t,3} = mean(cat(2,audAlpha2,audAlpha4),2);
    mean_iaf{t,4} = mean(cat(2,motAlpha2,motAlpha4),2);
    
    median_iaf{t,1} = median(cat(2,audAlpha1,audAlpha3),2);
    median_iaf{t,2} = median(cat(2,motAlpha1,motAlpha3),2);
    median_iaf{t,3} = median(cat(2,audAlpha2,audAlpha4),2);
    median_iaf{t,4} = median(cat(2,motAlpha2,motAlpha4),2);
    
    roi_list = {'aud_L','mot_L','aud_R','mot_R'};
    
    for sb = 1:14
        
        for r = 1:3
            
            sub = ['yc' num2str(sb)];
            roi = roi_list{r};
            iaf = mean_iaf{t,r}(sb);
            
            fprintf(fid,'%5s\t%5s\t%5s\t%.3f\n',sub,cnd_time{t},roi,iaf);
            
            clear sub roi iaf
            
        end
        
    end
    
end

fclose(fid);