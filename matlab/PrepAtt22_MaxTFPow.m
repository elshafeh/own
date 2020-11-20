clear ; clc ;

% plot per subject

[~,suj_list,~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_list        = suj_list(2:22);

big_data        = [];
big_max         = [];

for sb = 1:length(suj_list)
    
    suj         = suj_list{sb};
    
    %     ext_name    = 'BroadAud5perc.50t110Hz.m200p400msCov.waveletPOW.50t110Hz.m200p600.MinEvokedKeepTrials';
    
    ext_name    = 'BroadAud5perc.1t110Hz.m200p400msCov.waveletPOW.5t110Hz.m200p600.MinEvokedKeepTrials';
    fname_in    = ['/Volumes/dycog/Aurelie/DATA/MEG/PAT_EXPE22/data/' suj '/field/' suj '.DIS.' ext_name '.mat'];
    
    if exist(fname_in)
        fprintf('loading %s\n',fname_in);
        load(fname_in)
        
        cfg                 = [];
        %     cfg.latency         = [0.1 0.3];
        cfg.frequency       = [45 110];
        freq                = ft_selectdata(cfg,freq);
        
        data                = squeeze(freq.powspctrm)./1e22;
        
        lm_1                = find(round(freq.time,3) == round(0.1,3));
        lm_2                = find(round(freq.time,3) == round(0.3,3));
        data                = squeeze(mean(data(:,:,lm_1:lm_2),3));
        data                = mean(data,1);
        find_max            = round(freq.freq(find(data == max(data))));
        plot_y_axis         = freq.freq;
        
        %     lm_1            = find(round(freq.freq,1) == round(60,1));
        %     lm_2            = find(round(freq.freq,1) == round(100,1));
        %     data            = squeeze(mean(data(:,lm_1:lm_2,:),2));
        %     data            = mean(data,1);
        %     find_max        = round(freq.time(find(data == max(data))),3);
        %     plot_y_axis       = freq.time;
        
        big_max(sb,1)       = find_max;
        big_data(sb,:)      = data;
    end
end

clearvars -except big_data big_max plot_y_axis

plot_x_axis = 0:size(big_data,1)+1;
c_lim       = 6;

figure();
ax_main     = axes('Position', [0.1 0.2 0.55 0.55]);
ax_top      = axes('Position', [0.1 0.8 0.55 0.1]);
ax_right    = axes('Position', [0.7 0.2 0.1 0.55]);

% plot main

axes(ax_main);
im_main = imagesc(plot_y_axis,plot_x_axis,big_data);
xlim([ plot_y_axis(1) plot_y_axis(end)]);
axis xy;
xlabel('Frequency (Hz)');
ylabel('Subjects');
caxis([0 c_lim]);
set(gca,'YDir','normal')
colormap(brewermap(256, '*RdYlBu'));

% plot up

axes(ax_top);
area(plot_y_axis,squeeze(mean(big_data,1)),'EdgeColor', 'none', 'FaceColor', [0.5 0.5 0.5]);
xlim([plot_y_axis(1) plot_y_axis(end)]);
caxis([0 c_lim]);
box off;
ax_top.XTickLabel = [];
ylabel('Power (fT)');
hold on;
plot([0 0], [0 c_lim], 'k:');

% plot right

axes(ax_right);
area(plot_x_axis(2:end-1), squeeze(mean(big_data,2)), 'EdgeColor', 'none', 'FaceColor', [0.5 0.5 0.5]);
view([270 90]); % this rotates the plot
ax_right.YDir = 'reverse';
caxis([0 c_lim]);
box off;
ax_right.XTickLabel = [];
ylabel('Power (fT)');

h = colorbar(ax_main, 'manual', 'Position', [0.85 0.2 0.05 0.55]);
ylabel(h, 'Power (fT)');

% hold on;
% imagesc(plot_y_axis,plot_x_axis,big_data)
% xlabel('Frequency (Hz)');
% ylabel('Subjects');
% % scatter(big_max,1:size(big_data,1),70,'MarkerEdgeColor',[0 .5 .5],...
% %     'MarkerFaceColor',[0 .7 .7],...
% %     'LineWidth',1.5)
%
% clim        = max(abs(big_data(:)));
% ylim([plot_x_axis(1) plot_x_axis(end)]);
% colormap(brewermap(256, '*RdYlBu'));
% h = colorbar();
% ylabel(h, 'Power ft ./1e22 )');