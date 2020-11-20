clear;close all;

suj_list                        	= [1:33 35:36 38:44 46:51];
alldata                             = [];

for ns = 1:length(suj_list)
    
    file_list                       = dir(['J:/temp/nback/data/stim_ag_all/sub' num2str(suj_list(ns)) ... 
        '.sess*.stim*.against.all.bsl.dwn70.auc.mat']);
    tmp                             = [];
    
    for nf = 1:length(file_list)
        fname                       = [file_list(nf).folder filesep file_list(nf).name];
        fprintf('loading %s\n',fname);
        load(fname);
        tmp(nf,:)                   = scores; clear scores;
    end
    
    if ~isempty(tmp)
        alldata                     = [alldata;mean(tmp,1)];
    end
    
end

keep alldata time_axis

bounds_mean                         = squeeze(mean(alldata,1));
bounds                              = nanstd(nanstd(alldata, [], 1));
bounds_sem                          = bounds ./ sqrt(size(alldata,1));

figure;
boundedline(time_axis,bounds_mean , squeeze(bounds),'-k','alpha'); % alpha makes bounds transparent
xlim([-0.1 1]);

ax = gca();
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
ax.TickDir = 'out';
box off;
ax.XLabel.Position(2) = -80;
box off;

ylim([0.49 0.6]);
yticks([0.49 0.5 0.6]);
xticks([0 0.2 0.4 0.6 0.8 1]);
xlim([-0.1 1]);
% alldata               	= squeeze(mean(alldata,1));
%
% lm1                     = find(round(time_axes,3) == round(0.1,3));
% lm2                     = find(round(time_axes,3) == round(0.5,3));
%
% alldata              	= mean(alldata(:,lm1:lm2),2);
%
% matrx_to_plot           = nan(10,10);
%
% for nt = 1:length(test_done)
%
%     x                   = test_done(nt,1);
%     y                   = test_done(nt,2);
%
%     matrx_to_plot(x,y)  = alldata(nt);
%
% end
%
% for x = 1:size(matrx_to_plot,1)
%     for y = 1:size(matrx_to_plot,2)
%
%         if x == y
%             matrx_to_plot(x,y)             = NaN;
%         end
%
%         %         for n = 1:size(matrx_to_plot,1)
%         %             if n > x
%         %                 matrx_to_plot(x,n)         = NaN;
%         %             end
%         %         end
%
%     end
% end
%
% keep matrx_to_plot
%
% freq                    = [];
% freq.freq               = 1:10;
% freq.time               = 1:10;
% freq.label              = {'stim'};
% freq.powspctrm(1,:,:)   = matrx_to_plot;
%
% figure;
% cfg                     = [];
% cfg.zlim                = [0.5 0.6];
% ft_singleplotTFR(cfg,freq);
% colormap(brewermap(256, '*RdBu'));
% title('');
%
% set(gca,'FontSize',16);
%
% c                        = colorbar;
% c.Ticks                  = cfg.zlim ;
%
% xticks(1:10)
% yticks(1:10)
%
% xticklabels({'B' 'X' 'F' 'R' 'H' 'S' 'Y' 'J' 'L' 'M' 'Q' 'W'});
% yticklabels({'B' 'X' 'F' 'R' 'H' 'S' 'Y' 'J' 'L' 'M' 'Q' 'W'});
%
% set(gca,'FontSize',40,'FontName', 'Calibri');