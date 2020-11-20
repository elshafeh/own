%% Analysis all Participants

close all
clear all

n = 3;

Input1 = 'Perf_logs.mat'; % ('C:\Users\cororl\Documents\project_eyes\data\Group Analysis\Perf_logs.mat');
load (Input1);
Input2 = 'RT_logs.mat'; % ('C:\Users\cororl\Documents\project_eyes\data\Group Analysis\RT_logs.mat');
load (Input2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%ALL Subjects combined%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

se_all_open = [std(Perf_logs(:,2))/sqrt(n),std(Perf_logs(:,3))/sqrt(n),std(Perf_logs(:,4))/sqrt(n)]; %standard error
se_all_closed = [std(Perf_logs(:,8))/sqrt(n),std(Perf_logs(:,9))/sqrt(n),std(Perf_logs(:,10))/sqrt(n)]; %standard error

se_all_RT_open = [std(RT_logs(:,2))/sqrt(n),std(RT_logs(:,4))/sqrt(n),std(RT_logs(:,4))/sqrt(n)]; %standard error
se_all_RT_closed = [std(RT_logs(:,8))/sqrt(n),std(RT_logs(:,9))/sqrt(n),std(RT_logs(:,10))/sqrt(n)]; %standard error

line_size   = 3;
font_size   = 16;

fig4 = figure; 
hold on;

for i = 1:2
    subplot(1,2,i); hold on;
    if i == 1
        errorbar([mean(Perf_logs(:,3))*100,mean(Perf_logs(:,4))*100],[se_all_open(2)*100,se_all_open(3)*100],'k','LineWidth',line_size)
        errorbar([mean(Perf_logs(:,9))*100,mean(Perf_logs(:,10))*100],[se_all_closed(2)*100,se_all_closed(3)*100],'b','LineWidth',line_size-1)
        
        %         title('Performance All Pilots')
        ylim([50 100]);
        grid;
    else
        
        errorbar([median(RT_logs(:,3)),median(RT_logs(:,4))],[se_all_RT_open(2),se_all_RT_open(3)],'k','LineWidth',line_size)
        errorbar([median(RT_logs(:,9)),median(RT_logs(:,10))],[se_all_RT_closed(2),se_all_RT_closed(3)],'b','LineWidth',line_size-1)
        
        %         title('RTs All Pilots')
        ylim([400 1000]);
        grid;
        
    end
    
    xlim([0.80 2.20])
    
    str = {'Left';'Right'};
    set(gca,'XTickLabel',str,'XTick',1:numel(str))
    if i == 1
        ylabel('%Correct','FontWeight','bold')
    else
        ylabel('Reaction Times (ms)','FontWeight','bold')
    end
    xlabel('Cue','FontWeight','bold')
    legend('Open','Closed')
    
    
    set(gca,'fontsize', font_size);
    
end


% output = strcat('C:\Users\cororl\Documents\project_eyes\data\Group Analysis\figures\All_Pilots_logs');
% saveas(fig4,output,'png'); %Save figure in participant figures folder