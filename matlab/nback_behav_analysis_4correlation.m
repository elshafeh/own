clear;close all;

suj_list                                        = [1:33 35:36 38:44 46:51];
allperf                                         = [];
allrt                                           = [];

for ns = 1:length(suj_list)
    
    data_behav                                  = [];
    
    
    load(['~/Dropbox/project_me/data/nback/behav_h/sub' num2str(suj_list(ns)) '.behav.mat'] ,'data_behav');
    
    for nback = [4 5 6]
        
        %         if nback == 4
        %             data_sub                            = data_behav(data_behav(:,1) == nback,:);
        %             data_sub                            = data_sub+1;
        %         elseif nback == 5
        %             data_sub                            = data_behav(data_behav(:,1) == nback,3);
        %             data_sub                            = data_sub+1;
        %         else
        %             data_sub                            = data_behav(data_behav(:,1) == nback,:);
        %             data_sub                            = data_sub+1;
        %         end
        
        allperf(ns,nback-3)                    	= sum(data_sub) ./ length(data_sub); clear data_sub;
        
    end
    
    behav_struct(ns).suj                        = ['sub' num2str(suj_list(ns))];
    
    behav_struct(ns).corr_0back              	= allperf(ns,1);
    behav_struct(ns).corr_1back              	= allperf(ns,2);
    behav_struct(ns).corr_2back               	= allperf(ns,3);

    for nback = [4 5 6]
        
        if nback == 4
            data_sub                            = data_behav(data_behav(:,1) == nback,4);
        elseif nback == 5
            data_sub                            = data_behav(data_behav(:,1) == nback,4);
        else
            data_sub                            = data_behav(data_behav(:,1) == nback,4);
        end
        
        data_sub                                = data_sub(data_sub~=0);
        allrt(ns,nback-3)                    	= median(data_sub); clear data_sub;
        
    end
    
    
    behav_struct(ns).rt_0back                 	= allrt(ns,1);
    behav_struct(ns).rt_1back                	= allrt(ns,2);
    behav_struct(ns).rt_2back                 	= allrt(ns,3);
    
    
end

keep allperf allrt behav_struct

behav_table                                     = struct2table(behav_struct);

writetable(behav_table,'../doc/nback_behav_data.csv');

% figure;
% subplot(1,2,1);
% hold on;
% 
% for n = 1:3
%     z   = [[1:length(allperf)]*0.01]';
%     z(1:length(z/2))    = z(1:length(z/2)) * -0.4;
%     x   = repmat(n,length(allperf),1) + z;
%     y   = allperf(:,n);
%     scatter(x,y,50);
% end
% 
% xlim([0 4]);
% xticks([1 2 3]);
% ylim([0.7 0.9]);
% yticks([0.7 0.75 0.8 0.85 0.9]);
% xticklabels({'0 back','1 back','2 back'});
% ylabel('% correct');
% set(gca,'FontSize',16,'FontName', 'Calibri');
% grid;
% 
% subplot(1,2,2);
% hold on;
% 
% for n = 1:3
%     z   = [[1:length(allrt)]*0.01]';
%     z(1:length(z/2))    = z(1:length(z/2)) * -0.4;
%     x   = repmat(n,length(allrt),1) + z;
%     y   = allrt(:,n);
%     scatter(x,y,50);
% end
% 
% ylim([200 1000]);
% yticks([200 400 600 800 1000]);
% xlim([0 4]);
% xticks([1 2 3]);
% xticklabels({'0 back','1 back','2 back'});
% ylabel('median reaction time');
% set(gca,'FontSize',16,'FontName', 'Calibri');
% grid;