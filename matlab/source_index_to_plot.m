clear ; clc ; addpath(genpath('../fieldtrip-20151124/')); close all;


% load(['/Volumes/dycog/Aurelie/DATA/MEG/PAT_EXPE22/data_fieldtrip/index/broadAudSchTPJMniPFC.mat']);

load ../data/template/template_grid_0.5cm.mat

%     list_H                          = {'audL','audR'};
%     index_H(index_H(:,2) == 1 | index_H(:,2) == 3 | index_H(:,2) ==5,2) = 10;
%     index_H(index_H(:,2) == 2 | index_H(:,2) == 4 | index_H(:,2) ==6,2) = 20;
%     index_H(:,2)                    = index_H(:,2)/10;

source.pos                      = template_grid.pos;
source.dim                      = template_grid.dim;
source.pow                      = nan(length(source.pos),1);

list_roi                        = 1;

% for nroi = 1:length(list_roi)
%
%
%     vinterest                   = index_H(index_H(:,2) == list_roi(nroi),1);
%     source.pow(vinterest)       = NaN; % source.pos(vinterest,2);
%
%     %     vinterest                           = [vinterest source.pos(vinterest,2)];
%     %     vinterest                           = vinterest(vinterest(:,2) > 3,1);
%
%
% end

for iside = 1:3
    
%     lst_side                        =   {'left','right','left','right','left','right'};
%     lst_view                        =   [-95 1; 95 1; 88 -2; -88 -2; -125 3; 125 3];
    
    lst_side                                    = {'left','right','both'};
    lst_view                                    = [-95 1;95,11;0 50];
    
    z_lim                           =   length(list_roi);
    
    cfg                             =   [];
    cfg.method                      =   'surface';
    cfg.funparameter                =   'pow';
    cfg.funcolorlim                 =   [0 15];
    cfg.opacitylim                  =   [0 15];
    cfg.opacitymap                  =   'rampup';
    cfg.colorbar                    =   'no';
    cfg.camlight                    =   'no';
    cfg.projmethod                  =   'nearest';
    cfg.surffile                    =   ['surface_white_' lst_side{iside} '.mat'];
    cfg.surfinflated                =   ['surface_inflated_' lst_side{iside} '_caret.mat'];
    
    ft_sourceplot(cfg, source);
    view(lst_view(iside,:))
    %             title(list_H{list_roi(nroi)});
    
    %     colormap(cool)
    
    %             fname_out                       = ['~/GoogleDrive/PhD/Publications/Papers/distractor2018/cortex2018/_prep/emptyplot_' list_H{list_roi(nroi)} '.' num2str(iside) '.png'];
    %             fname_out                       = ['~/GoogleDrive/PhD/Publications/Papers/distractor2018/cortex2018/_prep/emptyplot_' num2str(iside) '.png'];
    %             saveas(gcf,fname_out);
    %             close all;
    
end