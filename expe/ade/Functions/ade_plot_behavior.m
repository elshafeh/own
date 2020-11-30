function ade_plot_behavior(Info)

close all;
load('Analysis/corr_blind_matrix.mat')

% block,noise,side,measure
[perc_to_plot]  = ade_behav_plot_prep(Info);
ifig            = 0;

for nblock = 1:size(perc_to_plot,1)
    for nmeasure = 1:size(perc_to_plot,4)
        
        ifig = ifig + 1;
        subplot(size(perc_to_plot,1),size(perc_to_plot,4),ifig)
        hold on;
        
        max_tick        = 300;
        tick_noisef     = 100;
        tick_noisey     = 200;
        
        plot(corr_blind,'Color',1/255*[200,200,200]);
        
        for nside = 1:size(perc_to_plot,3)
            mtrx = squeeze(perc_to_plot(nblock,:,nside,nmeasure));
            plot([tick_noisef tick_noisey],mtrx,'MarkerSize',10,'LineWidth',5);
        end
        
        
        ax              = gca;
        ax.XTick        = 0:max_tick;
        ax.XTickLabel   = repmat({''},max_tick+2);
        
        ax.XTickLabel{tick_noisef} = 'Noise-0';
        ax.XTickLabel{tick_noisey} = 'Noise-1';
        
        ylim([0 1.1]);
        xlim([0 max_tick]);
        
        legend({'blind perf','left hemi','right hemi'},'Location','southeast');
        
        list_measure    = {'ratio correct','ratio confident'};
        
        title(['sub' Info.name ' ' Info.modality ' block ' num2str(nblock) ' ' list_measure{nmeasure}]);
        
    end
end


set(gcf,'position',get(0,'screensize'));

figure_name     = ['Logfiles' filesep 'sub' Info.name filesep];
figure_name     = [figure_name 'sub' Info.name '_' Info.modality '_' Info.experiment '_' Info.runtype '_' num2str(Info.runnumber) '.fig'];

tic; savefig(gcf, figure_name, 'compact'); toc;
% saveas(gcf,figure_name);