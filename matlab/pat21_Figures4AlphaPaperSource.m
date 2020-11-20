% Sensor Level %

clear ; clc ; dleiftrip_addpath ; close all;

load ../data/yctot/stat/NewSourceDpssStat.mat ;

% for cf = 1:2
%     for ct = 1:2
%         [min_p(cf,ct),p_val{cf,ct}] = h_pValSort(stat{cf,ct}); clc ;
%     end
% end

% for cf = 1:2
%     for ct = 1:2
%         stat_int                = h_interpolate(stat{cf,ct});
%         stat_int.mask           = stat_int.prob < 0.05;
%         stat_int.stat           = stat_int.stat .* stat_int.mask;
%         cfg                     = [];
%         cfg.method              = 'slice';
%         cfg.funparameter        = 'stat';
%         cfg.maskparameter       = 'mask';
%         cfg.nslices             = 1;
%         cfg.slicerange          = [70 80];
%         cfg.funcolorlim         = [-4 4];
%         cfg.colorbar            = 'no';
%         cfg.opacitymap          = 0.5;
%         ft_sourceplot(cfg,stat_int);clc;
%         %         saveFigure(gcf,['/Users/heshamelshafei/Desktop/source.cf' num2str(cf) '.ct' num2str(ct) '.png']);
%     end
% end

limlim = 4;

for cf = 1:2
    for ct = 1:2
        for iside = 1:3
            
            lst_side                = {'left','right','both'};
            lst_view                = [-95 1;95,11;0 50];
            %             lst_view                = [-35 39;35,39;0 50];
            
            clear source
            
            stat{cf,ct}.mask        =   stat{cf,ct}.prob < 0.05;
            source.pos              =   stat{cf,ct}.pos ;
            source.dim              =   stat{cf,ct}.dim ;
            source.pow              =   stat{cf,ct}.stat .* stat{cf,ct}.mask;
            
            cfg                     =   [];
            cfg.method              =   'surface';
            cfg.funparameter        =   'pow';
            cfg.funcolorlim         =   [-limlim limlim];
            cfg.opacitylim          =   [-limlim limlim];
            cfg.opacitymap          =   'rampup';
            cfg.colorbar            =   'off';
            cfg.camlight            =   'no';
            cfg.projthresh          =   0.2;
            cfg.projmethod          =   'nearest';
            cfg.surffile            =   ['surface_white_' lst_side{iside} '.mat'];
            cfg.surfinflated        =   ['surface_inflated_' lst_side{iside} '_caret.mat'];
            ft_sourceplot(cfg, source);
            view(lst_view(iside,1),lst_view(iside,2))
            saveas(gcf,['/Users/heshamelshafei/Desktop/source.cf' num2str(cf) '.ct' num2str(ct) '.' num2str(iside) '.png']);
            close all;
        end
    end
end