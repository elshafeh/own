clear ; clc ;

suj_list                            = {'oc1','oc2','oc3','oc4','oc5','oc6','oc7','oc8','oc9','oc10','oc11','oc12','oc13','oc14', ...
    'yc1','yc10','yc11','yc4','yc18','yc21','yc7','yc19','yc15','yc14','yc5','yc13','yc16','yc12'};


delay_check                         = [];
all_data                            = [];


for sb = 1:length(suj_list)
    
    suj                             = suj_list{sb};
    
    behav_table                     = h_behavdis_eval(suj);
    behav_table                     = behav_table(behav_table.CORR ==1,:);
    
    vctr                            = [behav_table.CD behav_table.RT];
    vctr                            = sortrows(vctr,1);
    
    data_sub{sb}                    = vctr;
    
    all_data                        = [all_data;vctr];
    
    delay_check                     = [delay_check; unique(vctr(:,1))];
    
end

delay_check                         = unique(delay_check);
% delay_check                         = delay_check(delay_check>0);

keep delay_check suj_list data_sub all_data

% mtrx_data                           = [];
% for nd = 1:length(delay_check)
%     tmp                             = all_data(all_data(:,1) == delay_check(nd),2);
%     if ~isempty(tmp)
%         mtrx_data(nd)               = median(tmp); clear tmp;
%     end
%     clear tmp;
% end

mtrx_data                           = nan(length(suj_list),length(delay_check));

for sb = 1:length(suj_list)
    
    vctr                            = data_sub{sb};
    
    for nd = 1:length(delay_check)
        
        tmp                         = vctr(vctr(:,1) == delay_check(nd),2);
        
        if ~isempty(tmp)
            mtrx_data(sb,nd)        = median(tmp) ./ median(vctr(:,2));
        end
        
        clear tmp;
        
    end
    
end

mtrx_data                           = nanmean(mtrx_data,1);

hold on; 

delay_check                         = delay_check(2:end);
avg                                 = mtrx_data(1);
mtrx_data                           = mtrx_data(2:end);

data                                = mtrx_data;
data(data < avg)                    = NaN;
scatter(delay_check,data,'r');

data                                = mtrx_data;
data(data > avg)                    = NaN;
scatter(delay_check,data,'b');

hline(avg,'--k');

% Use the standard deviation over trials as error bounds:
% mean_data                           = nanmean(mtrx_data,1);
% bounds                              = nanstd(mtrx_data, [], 1);
% bounds_sem                          = bounds ./ sqrt(size(mtrx_data,1));
% 
% plot(mean_data)

% time_axs                            = delay_check;
%
% boundedline(time_axs, mean_data, bounds_sem,'-k','alpha'); % alpha makes bounds transparent
%
% xlabel('Delay (ms)')
% ylabel('Median Reaction Time (ms)')
% set(gca,'FontSize',20,'FontName', 'Calibri');

% ylim([0 800]);
% xticks([0 150 200 250 300 350 400 450 500])
% xlim([time_axs(1) time_axs(end)]);