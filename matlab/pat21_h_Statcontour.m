function h_Statcontour(stat,gavg,chn_list,cfg_plot)

% work under progress:
% input 1: stat structure ; this will define your contour
% input 2: grand average strcutre % this is your palette
% input 3: list of channels to plot

cntr    = squeeze(mean(stat.stat(chn_list,:,:) .* stat.mask(chn_list,:,:),1)); % average across channels
tmatrix = zeros(size(squeeze(mean(gavg.powspctrm(chn_list,:,:),1)),1),size(squeeze(mean(gavg.powspctrm(chn_list,:,:),1)),2));

toplot = [];

for a = 1:size(cntr,1) % freq
    for b = 1:size(cntr,2) % time
        
        indx_t = find(round(gavg.time,2) == round(stat.time(b),2));
        indx_f = find(round(gavg.freq) == round(stat.freq(a)));
        tmatrix(indx_f,indx_t) = cntr(a,b);
        
        if cntr(a,b) ~= 0
            toplot = [toplot; stat.time(b) stat.freq(a)];
        end
        
        clear indx_t indx_f
        
    end
end

toplot = sortrows(toplot,1);

clear a b

cfg_plot.channel     = chn_list;
ft_singleplotTFR(cfg_plot,gavg); %hold on; plot(toplot(:,1),toplot(:,2),'.-');

hold on; 
contour(gavg.time,gavg.freq,tmatrix,1,'LineColor','k','LineWidth',2,'Clipping','off','Visible','on');
xlim([-0.2 2]);
ylim([7 15]);
title('');