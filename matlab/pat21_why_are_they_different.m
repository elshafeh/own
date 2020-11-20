clear ; clc ;

ext = {'single','averaged'};

for t = 1:2
    
    load(['../data/yctot/gavg/CnD_' ext{t} '.mat']);
    
    for cnd = 1:2
        gavg{cnd}.pow     = nanmean(gavg{cnd}.pow,2);
    end
    
    cfg                 = [];
    cfg.parameter       = 'pow';
    cfg.operation       = '(x1-x2)./(x2)';
    bsl_corr{t}         = ft_math(cfg,gavg{2},gavg{1});
    clear gavg;
    
end

for ntest = 1:length(bsl_corr)
    source_int                  = h_interpolate(bsl_corr{ntest});
    cfg                         = [];
    cfg.method                  = 'slice';
    cfg.funparameter            = 'pow';
    cfg.nslices                 = 16;
    cfg.slicerange              = [70 84];
    cfg.funcolorlim             = 'minzero';
    ft_sourceplot(cfg,source_int);clc;
end

% load('../data/yctot/stat/CNV_single.mat','stat');
% carr{1} = stat ; clear stat ;
% load('../data/yctot/stat/CNV_averaged.mat','stat');
% carr{2} = stat ; clear stat ; stat = carr ; clear carr ;

% for iside = 1:3
%     for ntest = 1:1:length(bsl_corr)
%         lst_side                = {'left','right','both'};
%         lst_view                = [-95 1;95,11;0 50];
%         %         clear source
%         %         stat{ntest}.mask        = stat{ntest}.prob < 0.05;
%         %         source.pos              = stat{ntest}.pos ;
%         %         source.dim              = stat{ntest}.dim ;
%         %         source.pow              = stat{ntest}.stat .* stat{ntest}.mask;
%         cfg                     =   [];
%         cfg.method              =   'surface';
%         cfg.funparameter        =   'pow';
%         cfg.funcolorlim         =   [-1 1];
%         cfg.opacitylim          =   [-1 1];
%         cfg.opacitymap          =   'rampup';
%         cfg.colorbar            =   'off';
%         cfg.camlight            =   'no';
%         cfg.projthresh          =   0.2;
%         cfg.projmethod          =   'nearest';
%         cfg.surffile            =   ['surface_white_' lst_side{iside} '.mat'];
%         cfg.surfinflated        =   ['surface_inflated_' lst_side{iside} '_caret.mat'];
%         ft_sourceplot(cfg, bsl_corr{t});
%         view(lst_view(iside,1),lst_view(iside,2))
%     end
% end