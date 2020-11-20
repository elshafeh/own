clear; clc ; dleiftrip_addpath ;

load('../data/yctot/PaperIAF_Freq.mat');

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
    
    mean_viz =   mean(cat(2,visAlpha1,visAlpha2),2);
    mean_aud =   mean(cat(2,audAlpha1,audAlpha2,audAlpha3,audAlpha4),2);
    mean_mot =   mean(cat(2,motAlpha1,motAlpha2,motAlpha3,motAlpha4),2);
    
    median_viz =   median(cat(2,visAlpha1,visAlpha2),2);
    median_aud =   median(cat(2,audAlpha1,audAlpha2,audAlpha3,audAlpha4),2);
    median_mot =   median(cat(2,motAlpha1,motAlpha2,motAlpha3,motAlpha4),2);
    
    p_mean_va(t) = permutation_test([mean_viz mean_aud],1000);
    p_mean_vm(t) = permutation_test([mean_viz mean_mot],1000);
    p_mean_am(t) = permutation_test([mean_mot mean_aud],1000);
    
    p_median_va(t) = permutation_test([median_viz median_aud],1000);
    p_median_vm(t) = permutation_test([median_viz median_mot],1000);
    p_median_am(t) = permutation_test([median_mot median_aud],1000);
    
    %     figure;
    %     boxplot([viz aud],'Labels',{'visual Alpha','auditory Alpha'});
    %     title([cnd_time{t} ' , p = ' num2str(round(p_va,4))])
    %     ylim([6 16])
    
    %     figure;
    %     boxplot([viz mot],'Labels',{'visual Alpha','motor Alpha'});
    %     title([cnd_time{t} ' , p = ' num2str(round(p_vm,4))])
    %     ylim([6 16])
    
    %     figure;
    %     boxplot([aud mot],'Labels',{'auditory Alpha','motor Alpha'});
    %     title([cnd_time{t} ' , p = ' num2str(round(p_am,4))])
    %     ylim([6 16])
    
    aud_mean_L = mean(cat(2,audAlpha1,audAlpha3),2);
    mot_mean_L = mean(cat(2,motAlpha1,motAlpha3),2);
    aud_mean_R = mean(cat(2,audAlpha2,audAlpha4),2);
    mot_mean_R = mean(cat(2,motAlpha2,motAlpha4),2);
    
    aud_median_L = median(cat(2,audAlpha1,audAlpha3),2);
    mot_median_L = median(cat(2,motAlpha1,motAlpha3),2);
    aud_median_R = median(cat(2,audAlpha2,audAlpha4),2);
    mot_median_R = median(cat(2,motAlpha2,motAlpha4),2);

    p_mean_L(t) = permutation_test([aud_mean_L mot_mean_L],1000);
    p_mean_R(t) = permutation_test([aud_mean_R mot_mean_R],1000);
    
    p_median_L(t) = permutation_test([aud_median_L mot_median_L],1000);
    p_median_R(t) = permutation_test([aud_median_R mot_median_R],1000);
    
end