clear ; clc ; dleiftrip_addpath ; close all ;

load('../data/yctot/stat/sourceBasline_gavg.mat','stat')

for ifreq = 1:2
    for itime = 1:3
        [min_p(ifreq,itime),p_val{ifreq,itime}]     =   h_pValSort(stat{ifreq,itime});
    end
end

cnd_time = {'early','late','post'};
cnd_freq = {'low','high'};

% for itime = 2 % 1:3
%     for ifreq = 1 % 1:2
%
%
%         load ../data/template/source_struct_template_MNIpos.mat ; ha = source ; clear source ;
%
%         source.pos      = stat{ifreq,itime}.pos ;
%         source.dim      = stat{ifreq,itime}.dim ;
%         source.pow      = stat{ifreq,itime}.stat .* stat{ifreq,itime}.mask;
%         source.inside   = ha.inside;
%
%         source_int = h_interpolate(source);
%
%         clear mask tmp
%
%         cfg                     = [];
%         cfg.method              = 'surface';
%         cfg.funparameter        = 'pow';
%         cfg.funcolorlim         = [-4 4];
%         cfg.opacitylim          = [-4 4];
%         cfg.opacitymap          = 'rampup';
%         cfg.colorbar            = 'off';
%         cfg.projmethod          = 'nearest';
%         cfg.camlight            = 'no';
%         cfg.surffile            = 'surface_white_left.mat' ;
%         cfg.projthresh          = 0.1;
%         ft_sourceplot(cfg, source);
%
%     end
% end


for itime = 2 % 1:3
    for ifreq = 1 % 1:2
        for iside = 1:3
            
            lst_side = {'left','right','both'};
            lst_view = [-134 3;134,3;0 50];
            
            clear source
            
            source.pos = stat{ifreq,itime}.pos ;
            source.dim = stat{ifreq,itime}.dim ;
            source.pow = stat{ifreq,itime}.stat .* stat{ifreq,itime}.mask;
            
            source_int = h_interpolate(source);
            
            cfg                     =   [];
            cfg.method              =   'surface';
            cfg.funparameter        =   'pow';
            cfg.funcolorlim         =   [-4 4];
            cfg.opacitylim          =   [-4 4];
            cfg.opacitymap          =   'rampup';
            cfg.colorbar            =   'off';
            cfg.camlight            =   'no';
            cfg.projthresh          =   0.2;
            cfg.projmethod          =   'nearest';
            cfg.surffile            =   ['surface_white_' lst_side{iside} '.mat'];
            cfg.surfinflated        =   ['surface_inflated_' lst_side{iside} '_caret.mat'];
            ft_sourceplot(cfg, source);
            view(lst_view(iside,1),lst_view(iside,2))
            saveFigure(gcf,['/Users/heshamelshafei/Desktop/paper_fig/source.' cnd_time{itime} '.' cnd_freq{ifreq} '.' lst_side{iside} '.png']);
            %             saveFigure(gcf,['/Users/heshamelshafei/Desktop/paper_fig/source.' cnd_time{itime} '.' cnd_freq{ifreq} '.' lst_side{iside} '.svg']);
            %             close all ;
            
        end
    end
end

%             %                 tmp         = abs(source.pow) ;
%             %                 mask        = tmp > 2;
%             %                 source.pow  = mask .* source.pow ;
%
%             clear mask tmp
%
%             cfg                     = [];
%             cfg.method              = 'surface';
%             cfg.funparameter        = 'pow';
%             cfg.funcolorlim         = [-4 4];
%             cfg.opacitylim          = [-4 4];
%             cfg.opacitymap          = 'rampup';
%             cfg.colorbar            = 'off';
%             cfg.projmethod          = 'nearest';
%             cfg.camlight            = 'no';
%             cfg.surffile            = ['surface_white_' lst_side{iside} '.mat'] ;
%             %             cfg.surfinflated        = ['surface_inflated_' lst_side{iside} '_caret.mat'] ; % ['surface_white_' lst_side{iside} '.mat'] ;
%             cfg.projthresh          = 0.1;
%             ft_sourceplot(cfg, source);
%             %             material dull
%             view(lst_view(iside,1),lst_view(iside,2))
%             saveFigure(gcf,['/Users/heshamelshafei/Desktop/paper_fig/source.' cnd_time{itime} '.' cnd_freq{ifreq} '.' lst_side{iside} '.png']);
%             close all ;

% load ../data/template/source_struct_template_MNIpos.mat
%
% source.avg.pow(:,:) = NaN ;
%
% indxH = h_createIndexfieldtrip(source);
%
% % n_indx = indxH(indxH(:,2) == 80 | indxH(:,2) == 82,1);
% %
% % source.avg.pow(n_indx) = -10 ;
%
% n_indx = indxH(indxH(:,2) == 49 | indxH(:,2) == 51 | indxH(:,2) == 53 | indxH(:,2) == 50 | indxH(:,2) == 52 | indxH(:,2) == 54,1);
%
% source.avg.pow(n_indx) = 10 ;
