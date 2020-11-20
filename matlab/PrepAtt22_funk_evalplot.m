% Creates a graphic for all trials with different legends for each condition to get an overview of your behavioral data 

function PrepAtt22_funk_evalplot(summary)

%  1. sub 2. bloc 3. ntrial 4. code 5. cue 6. dis 7. target 8. expected 9. sub 10. correct
% 11. rt 12. error (1 miss 2 mr 3 fa)    13. cue_idx 14. CT 15. DT 16. CuON
% 17. TarON 18. DisOn

rpt = repmat(1,length(summary),1);
% new : cue dis na na na na RT CT DT Error

nw_summary = [summary(:,5) summary(:,6) rpt rpt rpt rpt summary(:,11) summary(:,14) summary(:,15) summary(:,12)];

summary = nw_summary;

% ---- FOR CORRECT, MISSES AND FALSE ALARMS --- %

%inf nodis
to_plot = NaN(1,size(summary,1));
to_plot(summary(:,1)>0 & summary(:,10)~=2) = summary(summary(:,1)>0 & summary(:,10)~=2, 7);
to_plot(summary(:,2)~=0) = NaN;
plot(to_plot, 'h', 'Color', [0 1 0], 'MarkerSize', 5, 'MarkerFaceColor', [0 1 0])
hold on
% inf d1
to_plot = NaN(1,size(summary,1));
to_plot(summary(:,1)>0 & summary(:,10)~=2) = summary(summary(:,1)>0 & summary(:,10)~=2, 7);
to_plot(summary(:,2)~=1) = NaN;
plot(to_plot, 'd', 'Color', [0 .9 0], 'MarkerSize', 5, 'MarkerFaceColor', [0 .9 0])
% inf d2
to_plot = NaN(1,size(summary,1));
to_plot(summary(:,1)>0 & summary(:,10)~=2) = summary(summary(:,1)>0 & summary(:,10)~=2, 7);
to_plot(summary(:,2)~=2) = NaN;
plot(to_plot, 'd', 'Color', [0 .5 0], 'MarkerSize', 5, 'MarkerFaceColor', [0 .5 0])

% unf nodis
to_plot = NaN(1,size(summary,1));
to_plot(summary(:,1)==0 & summary(:,10)~=2) = summary(summary(:,1)==0 & summary(:,10)~=2, 7);
to_plot(summary(:,2)~=0) = NaN;
plot(to_plot, 'h', 'Color', [0 .5 1], 'MarkerSize', 5, 'MarkerFaceColor', [0 .5 1])
% unf d1
to_plot = NaN(1,size(summary,1));
to_plot(summary(:,1)==0 & summary(:,10)~=2) = summary(summary(:,1)==0 & summary(:,10)~=2, 7);
to_plot(summary(:,2)~=1) = NaN;
plot(to_plot, 'o', 'Color', [0 .5 .8], 'MarkerSize', 5, 'MarkerFaceColor', [0 .5 .8])
% unf d2
to_plot = NaN(1,size(summary,1));
to_plot(summary(:,1)==0 & summary(:,10)~=2) = summary(summary(:,1)==0 & summary(:,10)~=2, 7);
to_plot(summary(:,2)~=2) = NaN;
plot(to_plot, 'o', 'Color', [0 .3 .7], 'MarkerSize', 5, 'MarkerFaceColor', [0 .3 .7])


% ---- FOR MULTIPLE RESPONSE --- %

%inf nodis
to_plot = NaN(1,size(summary,1));
to_plot(summary(:,1)>0 & summary(:,10)==2) = summary(summary(:,1)>0 & summary(:,10)==2, 7);
to_plot(summary(:,2)~=0) = NaN;
plot(to_plot, 'h', 'Color', [0 1 0], 'MarkerSize', 12, 'MarkerFaceColor', [0 1 0])
hold on
% inf d1
to_plot = NaN(1,size(summary,1));
to_plot(summary(:,1)>0 & summary(:,10)==2) = summary(summary(:,1)>0 & summary(:,10)==2, 7);
to_plot(summary(:,2)~=1) = NaN;
plot(to_plot, 'd', 'Color', [0 .9 0], 'MarkerSize', 12, 'MarkerFaceColor', [0 .9 0])
% inf d2
to_plot = NaN(1,size(summary,1));
to_plot(summary(:,1)>0 & summary(:,10)==2) = summary(summary(:,1)>0 & summary(:,10)==2, 7);
to_plot(summary(:,2)~=2) = NaN;
plot(to_plot, 'd', 'Color', [0 .5 0], 'MarkerSize', 12, 'MarkerFaceColor', [0 .5 0])

% unf nodis
to_plot = NaN(1,size(summary,1));
to_plot(summary(:,1)==0 & summary(:,10)==2) = summary(summary(:,1)==0 & summary(:,10)==2, 7);
to_plot(summary(:,2)~=0) = NaN;
plot(to_plot, 'h', 'Color', [0 .5 1], 'MarkerSize', 12, 'MarkerFaceColor', [0 .5 1])
% unf d1
to_plot = NaN(1,size(summary,1));
to_plot(summary(:,1)==0 & summary(:,10)==2) = summary(summary(:,1)==0 & summary(:,10)==2, 7);
to_plot(summary(:,2)~=1) = NaN;
plot(to_plot, 'o', 'Color', [0 .5 .8], 'MarkerSize', 12, 'MarkerFaceColor', [0 .5 .8])
% unf d2
to_plot = NaN(1,size(summary,1));
to_plot(summary(:,1)==0 & summary(:,10)==2) = summary(summary(:,1)==0 & summary(:,10)==2, 7);
to_plot(summary(:,2)~=2) = NaN;
plot(to_plot, 'o', 'Color', [0 .3 .7], 'MarkerSize', 12, 'MarkerFaceColor', [0 .3 .7])

plot([0 length(to_plot)], [0 0], 'k') %ligne ?? 0
text(0.5, -60, 'Target onset', 'Color', 'k');
% ligne horizontale pour dis1 onset
serie_dis1 = summary(summary(:,2) == 1, 9);
dis1_target=nanmean(serie_dis1);
plot([0 length(to_plot)], [-dis1_target -dis1_target], ':', 'Color', [0 .9 0])
text(0.5, -60-dis1_target, 'Mean Dis1 onset', 'Color', [0 .9 0]);
% ligne horizontale pour dis2 onset
serie_dis2 = summary(summary(:,2) == 2, 9);
dis2_target=nanmean(serie_dis2);
plot([0 length(to_plot)], [-dis2_target -dis2_target], ':', 'Color', [0 .5 0])
text(0.5, -60-dis2_target, 'Mean Dis2 onset', 'Color', [0 .5 0]);

% ligne horizontale pour cue onset
cue_target=nanmean(summary(:,8));
plot([0 length(to_plot)], [-cue_target -cue_target], 'Color', 'r')
text(0.5, -60-cue_target, 'Mean Cue onset', 'Color', 'r');

%lignes horizontales pour limites en TR pour exclusion des outliers, upper limit = mean + 2*std
plot([0 length(to_plot)], [nanmean(summary(summary(:,7)>0, 7)) nanmean(summary(summary(:,7)>0, 7))], 'Color', [0 .3 .7])
text(0.5, nanmean(summary(summary(:,7)>0, 7))+60, 'Mean', 'Color', [0 .3 .7]);
upperRTlimit=nanmean(summary(summary(:,7)>0, 7))+2*std(summary(summary(:,7)>0, 7));
plot([0 length(to_plot)], [upperRTlimit upperRTlimit], 'Color', [1 .7 0])
text(0.5, upperRTlimit+60, 'Upper Limit = Mean + 2*std', 'Color', [1 .7 0]);
lowerRTlimit=200;
plot([0 length(to_plot)], [lowerRTlimit lowerRTlimit], 'Color', [1 .7 0])
text(0.5, lowerRTlimit-60, 'Lower Limit = 200ms', 'Color', [1 .7 0]);

h = findobj(gca, 'Type', 'axes');
h.XLim = [0 length(to_plot)+1];
h.XLabel.String = 'Trial number';
h.YLabel.String = 'TR  target/response    (ms)';
% title([suj ': TR story'])
g = legend('Inf NoDis', 'Inf Dis1', 'Inf Dis2',...
    'UnInf NoDis', 'UnInf Dis1', 'UnInf Dis2' , 'Location', 'best');
g.Interpreter = 'none';

ylim([-1500 5000]);

% dirOUT = ['/dycog/Aurelie/DATA/MEG/PAT_MEG/pat.meeg/data/' suj '/behav/'];
% saveFigure(gcf,[dirOUT suj '.rt.story.png']);
% close all;
% print(figL, '-djpeg', [fig_name  '.jpg'])
% h=figL;
% set(h,'PaperOrientation','landscape');
% set(h,'PaperUnits','normalized');
% set(h,'PaperPosition', [0 0 1 1]);
% print(fig_name, '-dpdf', '-r300')
% print(fig_name, '-djpeg', '-r300')
% print(figL, '-dpdf', '-r150', )
% lignes verticales d??limitant les blocs
% plot([bloc_size(1) bloc_size(1); bloc_size(2) bloc_size(2)]', [nanmax(summary(:,5)) min(-[serie_dis1; serie_dis2; serie_dis3; cue_target]); nanmax(summary(:,5)) min(-[serie_dis1; serie_dis2; serie_dis3; cue_target])]', '--k')
% clear serie_dis1 serie_dis2 serie_dis3 cue_target
% text(round(bloc_size(1)/2)-3, -1300, 'block1');
% text(bloc_size(1)+round((bloc_size(2)-bloc_size(1))/2)-3, -1300, 'block2');
% text(bloc_size(2)+round((bloc_size(3)-bloc_size(2))/2)-3, -1300, 'block3');