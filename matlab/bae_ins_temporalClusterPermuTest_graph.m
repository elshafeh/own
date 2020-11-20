% ins_temporalClusterPermuTest_graph.m
function result = ins_temporalClusterPermuTest_graph(set1, set2, stat_set1_set2, def, cfg)
% http://meg.univ-amu.fr/wiki/Main_Page %%%%%%%%%%%%%
%
% Specific function to draw graphics of functions
% ins_temporalClusterPermuTest_XXX
%
% DEPENDANCES:
% This function uses the function 'jbfill' to shade area between two curves
% (http://www.mathworks.com/matlabcentral/fileexchange/13188-shade-area-between-two-curves/content/jbfill.m)
%
% USAGE:
% result = ins_temporalClusterPermuTest_graph(
%                               set1,
%                               set2,
%                               stat_set1_set2,
%                               def,
%                               cfg)
%
% INPUTS:
% cf. function ins_temporalClusterPermuTest_XXX.m
%
% OUTPUTS:
% result = true or false if error
% ________________________________
% Bernard Giusiano & Sophie Chen
% INSERM UMR 1106 Institut de Neurosciences des Systèmes
% Sept/2015 (first version)
% Nov/2015 (this version)
% http://ins.univ-amu.fr
%
result = false;
 
%% trace %%%%%%%%%%%%%%%%
p = min(stat_set1_set2.prob);
st=dbstack;
fprintf(cfg.fid, '%s;%s;%6.4f\n', st(2,1).name, stat_set1_set2.title, p);
%%%%%%%%%%%%%%%%%%%%%%%%%
 
plot(set1.GM.time,set1.mean,'b','linewidth',2);
hold on;
plot(set2.GM.time,set2.mean,'r','linewidth',2);
 
plot(set1.GM.time,stat_set1_set2.stat,'g','linewidth',0.5);
line(cfg.latency,[0 0],'Color',[0.1 0.1 0.1],'linestyle','--');  % xlim
 
y1 = stat_set1_set2.mask;
y2(~y1) = nan ;
y2(y1) = 0.0 ;
plot(set1.GM.time,y2,'Color',[1.0,0.4,0.0],'linewidth',10); % clusters significatifs en orange
 
legend(set1.legend,set2.legend,'stat diff','Location','NorthWest');
 
x = jbfill(set1.GM.time,(set1.mean+1.96*set1.stdmean).',(set1.mean-1.96*set1.stdmean).','b','b',0,0.05);
x = jbfill(set2.GM.time,(set2.mean+1.96*set2.stdmean).',(set2.mean-1.96*set2.stdmean).','r','r',0,0.05);
 
title(stat_set1_set2.title,'FontWeight','bold','FontSize',14)
xlabel(def.time);ylabel(stat_set1_set2.ylabel);
hold off;
 
%%
result = true;