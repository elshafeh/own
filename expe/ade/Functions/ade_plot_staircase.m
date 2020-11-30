function ade_plot_staircase(Info)
% Function to plot Staircase performance across all block
% Plots trials in green and red symbols for correct and incorrect trials
% respectively ; in the title you have the name of the subject ;
% the number of block ; AND the percentage of correct response.

figure;
ifig                            = 0;

for nbloc = 1:length(Info.block) % separate trials according to block
    
    res_side                    = [Info.block(nbloc).trial.side];
    
    ifig = ifig + 1;
    subplot(1,length(Info.block),ifig);
    
    res_differences             = [Info.block(nbloc).trial.difference];
    res_performances            = [Info.block(nbloc).trial.correct];
    
    stairs(res_differences);
    
    nb_correctTrials            = length(res_performances(res_performances==1));
    percentagePerformance       = (nb_correctTrials/length(res_performances)) * 100;
    
    correctTrials               = res_performances==1;
    hold on
    plot(find(correctTrials),res_differences(correctTrials),'ko','MarkerFaceColor','g'); % plot correct in green
    
    incorrectTrials             = res_performances~=1;
    plot(find(incorrectTrials),res_differences(incorrectTrials),'ko','MarkerFaceColor','r'); % plot incorrect in red
    
    xlabel('Trial Number')
    ylabel('SNR');
    
    % set figure limits
    
    if strcmp(Info.modality,'aud')
        ylim([-200 200])
    elseif strcmp(Info.modality,'vis')
        ylim([0 10])
    end
    
    xlim([0 length(res_differences)+1])
    title(['sub' Info.name ' ' Info.modality ' block ' num2str(nbloc) ' ' num2str(round(percentagePerformance,2)) ' % ']);
    
end

% save figure in full screen
set(gcf,'position',get(0,'screensize'));

figure_name     = ['Logfiles' filesep 'sub' Info.name filesep];
figure_name     = [figure_name 'sub' Info.name '_' Info.modality '_' Info.experiment '_' Info.runtype '_' num2str(Info.runnumber) '.fig'];

tic; savefig(gcf, figure_name, 'compact'); toc;
% saveas(gcf,figure_name);