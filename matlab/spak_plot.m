function spak_plot(cfg_in,data_slct)

% for information check: 
% https://eelkespaak.nl/blog/customizing-common-m-eeg-plots-part-2-the-time-frequency-representation-tfr/

figure();
ax_main             = axes('Position', [0.1 0.2 0.55 0.55]);

if strcmp(cfg_in.up_plot,'yes')
    ax_top          = axes('Position', [0.1 0.8 0.55 0.1]);
end

if strcmp(cfg_in.right_plot,'yes')
    ax_right        = axes('Position', [0.7 0.2 0.1 0.55]);
end

axes(ax_main);
cfg                 = [];
cfg.layout          = 'CTF275_helmet.mat';
cfg.marker          = 'off';
cfg.colormap        = brewermap(256, '*RdBu');
cfg.zlim            = cfg_in.zlim;
ft_singleplotTFR(cfg, data_slct);
title('');

for nv = [0 1.5 3 4.5]
    vline(nv,'--k');
end

if strcmp(cfg_in.up_plot,'yes')
    
    axes(ax_top);
    pow                 = mean(squeeze(mean(data_slct.powspctrm,1)),1);
    area(data_slct.time, pow,'EdgeColor', 'none', 'FaceColor', [0.5 0.5 0.5]);
    xlim([data_slct.time(1) data_slct.time(end)]);
    
    box off;
    ax_top.XTickLabel = [];
    hold on;
    
    for nv = [0 1.5 3 4.5]
        vline(nv,'--k');
    end
    
end

if strcmp(cfg_in.right_plot,'yes')
    
    axes(ax_right);
    pow                 = mean(squeeze(mean(data_slct.powspctrm,1)),2);
    area(data_slct.freq, pow','EdgeColor', 'none', 'FaceColor', [0.5 0.5 0.5]);
    xlim([data_slct.freq(1) data_slct.freq(end)]);
    view([270 90]); % this rotates the plot
    ax_right.YDir       = 'reverse';
    box off;
    ax_right.XTickLabel = [];

end