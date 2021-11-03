clear ; close all; global ft_default
ft_default.spmversion = 'spm12';

suj_list                   	= [1:33 35:36 38:44 46:51];
suj_list(suj_list == 19)  	= [];
suj_list(suj_list == 38)  	= [];

for nsuj = 1:length(suj_list)
    
    subjectname         = ['sub' num2str(suj_list(nsuj))];
    
    dir_data           	= '~/Dropbox/project_me/data/nback/peak/';
    ext_peak           	= 'alphabeta.peak.package.0back.equalhemi';
    fname_in          	= [dir_data 'sub' num2str(suj_list(nsuj)) '.' ext_peak '.mat'];
    fprintf('loading %s\n',fname_in);
    load(fname_in);
    
    dataplot(nsuj,1)    = apeak;
    dataplot(nsuj,2)    = bpeak(1);
    
end

keep dataplot

sm_alpha                = sem(dataplot(:,1));
sm_betaa                = sem(dataplot(:,2));


% %%
% 
% dataplot(isnan(dataplot(:,2)),2)  = round(nanmean(dataplot(:,2)));
% 
% %%
% 
% d{1} = dataplot(:,1);
% d{2} = dataplot(:,2);
% 
% try
%     % get nice colours from colorbrewer
%     % (https://uk.mathworks.com/matlabcentral/fileexchange/34087-cbrewer---colorbrewer-schemes-for-matlab)
%     [cb] = cbrewer('qual', 'Set3', 12, 'pchip');
% catch
%     % if you don't have colorbrewer, accept these far more boring colours
%     cb = [0.5 0.8 0.9; 1 1 0.7; 0.7 0.8 0.9; 0.8 0.5 0.4; 0.5 0.7 0.8; 1 0.8 0.5; 0.7 1 0.4; 1 0.7 1; 0.6 0.6 0.6; 0.7 0.5 0.7; 0.8 0.9 0.8; 1 1 0.4];
% end
% 
% cl(1, :)    = cb(4, :);
% cl(2, :)    = cb(1, :);
% 
% subplot(1, 1, 1)
% h           = rm_raincloud(d, cl);
% 
% legend({'alpha' '' 'beta1' '' 'beta2' ''});
% xlabel('Peak Frequency Hz');
% yticklabels({''});
% yticks([]);
% 
% set(gca,'FontSize',16,'FontName', 'Calibri');
% 
% %%
% 
% figure;
% hold on;
% 
% for n = [1 2 3]
%     x_axes  = repmat(n,length(dataplot),1) + [1.1e-2*(1:length(dataplot))]';
%     scatter(x_axes,dataplot(:,n),100);
% end
% 
% xticks([1.2 2.3]);
% xlim([0.9 3.5]);
% ylim([5 30]);
% xticklabels({'alpha','beta1' ,'beta2'});
