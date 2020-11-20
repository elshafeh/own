clear ; clc ; dleiftrip_addpath ;

load ../data/yctot/stat/new.dis.lcmv.stat.mat

tmp{1} = stat ; clear stat 

load ../data/yctot/stat/nDT.lcmv.stat.mat ; 

tmp{2} = stat{1} ; clear stat ; stat = tmp ; clear tmp ;

for n = 1:2
    stat{n}.mask      = stat{n}.prob < 0.05;
    stat{n}.stat      = stat{n}.stat .* stat{n}.mask;
    %     list{n}           = FindSigClusters(stat{n},0.05);
end

% common_areas = intersect(list{1,1}(:,1),list{:,2}(:,1));
% 
% for n = 1:length(stat{1}.stat)
%     
%     if stat{1}.stat(n) ~= 0 && stat{2}.stat(n) ~= 0 && ~isnan(stat{1}.stat(n)) && ~isnan(stat{2}.stat(n))
%         common_stat.pow(n,1) = 5; 
%     else
%         common_stat.pow(n,1) = 0;
%     end
%     
% end
% 
% common_stat.dim = stat{1}.dim ; 
% common_stat.pos = stat{1}.pos ;
% 
% common_vox_list    = FindNonEmptyClusters(common_stat);
% common_int         = h_interpolate(common_stat);
% 
% cfg                         = [];
% cfg.method                  = 'slice';
% cfg.funparameter            = 'pow';
% cfg.nslices                 = 16;
% cfg.slicerange              = [70 84];
% cfg.funcolorlim             = [0 5];
% ft_sourceplot(cfg,common_int);clc;
% 
% lst_side = {'left','right','both'};
% lst_view = [-96 8;96 8;0 50];
% 
% for iside = 1:3
%     
%     cfg                     =   [];
%     cfg.method              =   'surface';
%     cfg.funparameter        =   'pow';
%     cfg.funcolorlim         =   [-5 5];
%     cfg.opacitylim          =   [-5 5];
%     cfg.opacitymap          =   'rampup';
%     cfg.colorbar            =   'off';
%     cfg.camlight            =   'no';
%     cfg.projthresh          =   0.1;
%     cfg.projmethod          =   'nearest';
%     cfg.surffile            =   ['surface_white_' lst_side{iside} '.mat'];
%     cfg.surfinflated        =   ['surface_inflated_' lst_side{iside} '_caret.mat'];
%     ft_sourceplot(cfg, common_stat);
%     view(l% common_areas = intersect(list{1,1}(:,1),list{:,2}(:,1));
% 
% for n = 1:length(stat{1}.stat)
%     
%     if stat{1}.stat(n) ~= 0 && stat{2}.stat(n) ~= 0 && ~isnan(stat{1}.stat(n)) && ~isnan(stat{2}.stat(n))
%         common_stat.pow(n,1) = 5; 
%     else
%         common_stat.pow(n,1) = 0;
%     end
%     
% end
% 
% common_stat.dim = stat{1}.dim ; 
% common_stat.pos = stat{1}.pos ;
% 
% common_vox_list    = FindNonEmptyClusters(common_stat);
% common_int         = h_interpolate(common_stat);
% 
% cfg                         = [];
% cfg.method                  = 'slice';
% cfg.funparameter            = 'pow';
% cfg.nslices                 = 16;
% cfg.slicerange              = [70 84];
% cfg.funcolorlim             = [0 5];
% ft_sourceplot(cfg,common_int);clc;
% 
% lst_side = {'left','right','both'};
% lst_view = [-96 8;96 8;0 50];
% 
% for iside = 1:3
%     
%     cfg                     =   [];
%     cfg.method              =   'surface';
%     cfg.funparameter        =   'pow';
%     cfg.funcolorlim         =   [-5 5];
%     cfg.opacitylim          =   [-5 5];
%     cfg.opacitymap          =   'rampup';
%     cfg.colorbar            =   'off';
%     cfg.camlight            =   'no';
%     cfg.projthresh          =   0.1;
%     cfg.projmethod          =   'nearest';
%     cfg.surffile            =   ['surface_white_' lst_side{iside} '.mat'];
%     cfg.surfinflated        =   ['surface_inflated_' lst_side{iside} '_caret.mat'];
%     ft_sourceplot(cfg, common_stat);
%     view(lst_view(iside,1),lst_view(iside,2))
%     saveFigure(gcf,['../../../../Desktop/common.3dSource' '.' lst_side{iside} '.png']);
%     
% endst_view(iside,1),lst_view(iside,2))
%     saveFigure(gcf,['../../../../Desktop/common.3dSource' '.' lst_side{iside} '.png']);
%     
% end