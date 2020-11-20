clear ; clc ;

clear; clc ; dleiftrip_addpath ;

load('../data/yctot/NewIAFNewMotorandMax_time.mat'); % sub,chn,time,time/freq,min/max

t = 4;

audAlpha1 =   bigassmatrix_freq(:,3,t,1,2);
audAlpha2 =   bigassmatrix_freq(:,4,t,1,2);
audAlpha3 =   bigassmatrix_freq(:,5,t,1,2);
audAlpha4 =   bigassmatrix_freq(:,6,t,1,2);
motAlpha1 =   bigassmatrix_freq(:,7,t,1,2);
motAlpha2 =   bigassmatrix_freq(:,8,t,1,2);
motAlpha3 =   bigassmatrix_freq(:,9,t,1,2);
motAlpha4 =   bigassmatrix_freq(:,10,t,1,2);

aud       =   mean(cat(2,audAlpha1,audAlpha2,audAlpha3,audAlpha4),2);
mot       =   mean(cat(2,motAlpha1,motAlpha2,motAlpha3,motAlpha4),2);
% 
% aud =   median(cat(2,audAlpha1,audAlpha2,audAlpha3,audAlpha4),2);
% mot =   median(cat(2,motAlpha1,motAlpha2,motAlpha3,motAlpha4),2);

p_am = permutation_test([mot aud],1000);

% [h,p_am] = ttest(aud,mot);
% 
% if p_va < 0.05
%     figure;
%     boxplot([viz aud],'Labels',{'visAlpha','audAlpha'});
%     title([cnd_time{t} ' , p < 0.05'])
% end
% 
% if p_vm < 0.05
%     figure;
%     boxplot([viz mot],'Labels',{'visAlpha','motAlpha'});
%     title([cnd_time{t} ' , p < 0.05'])
% end
% 
% if p_am < 0.05
%     figure;
%     boxplot([aud mot],'Labels',{'audAlpha','motAlpha'});
%     title([cnd_time{t} ' , p < 0.05'])
% end

% aud_L = mean(cat(2,audAlpha1,audAlpha3),2);
% mot_L = mean(cat(2,motAlpha1,motAlpha3),2);
% aud_R = mean(cat(2,audAlpha2,audAlpha4),2);
% mot_R = mean(cat(2,motAlpha2,motAlpha4),2);

aud_L = median(cat(2,audAlpha1,audAlpha3),2);
mot_L = median(cat(2,motAlpha1,motAlpha3),2);
aud_R = median(cat(2,audAlpha2,audAlpha4),2);
mot_R = median(cat(2,motAlpha2,motAlpha4),2);

% [h,p_L] = ttest(aud_L,mot_L);
% [h,p_R] = ttest(aud_R,mot_R);

p_L = permutation_test([aud_L mot_L],1000);
p_R = permutation_test([aud_R mot_R],1000);
