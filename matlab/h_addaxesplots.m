function h_addaxesplots(data_slct)

values_top          = [0.57 0.93 0.3360 0.06];
ax_top              = axes('Position', values_top);

values_right        = [0.91 0.585 0.06 0.34];
ax_right            = axes('Position', values_right); % 0.91

axes(ax_top);
pow                 = mean(squeeze(mean(data_slct.powspctrm,1)),1);
area(data_slct.time, pow,'EdgeColor', 'none', 'FaceColor', [0.5 0.5 0.5]);
xlim([data_slct.time(1) data_slct.time(end)]);
yticks([]);


box off;
ax_top.XTickLabel = [];
hold on;

axes(ax_right);
pow                 = mean(squeeze(mean(data_slct.powspctrm,1)),2);
area(data_slct.freq, pow','EdgeColor', 'none', 'FaceColor', [0.5 0.5 0.5]);
xlim([data_slct.freq(1) data_slct.freq(end)]);
view([270 90]); % this rotates the plot
ax_right.YDir       = 'reverse';
box off;
ax_right.XTickLabel = [];
yticks([]);