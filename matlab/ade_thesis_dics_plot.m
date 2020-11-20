clear; close all;

load ~/Downloads/source_data_new.mat;

alldata{1}                              = alldata{1}([2:4 6:end],:);

for nm = 1:2
    
    list_side                           = [1 2];
    
    for i = 1:length(list_side)
        
        for nb = 1:4
            
            dataplot                    = ft_sourcegrandaverage([],alldata{nm}{:,nb});
           
            flg                         = list_side(i);
            
            lst_side                    = {'left','right','both'};
            lst_view                    = [-95 1;95 1;0 10];
            
            cfg                         = [];
            cfg.method                  = 'surface';
            cfg.funparameter            = 'pow';
            cfg.maskparameter           = cfg.funparameter;
            
            cfg.opacitylim              = [0.9 1.1]; %
            cfg.funcolorlim             = cfg.opacitylim;
            cfg.camlight                = 'no';
            
            %             cfg.projthresh              = 0.8;
            
            cfg.opacitymap              = 'rampup';
            cfg.projmethod              = 'nearest';
            
            cfg.surffile                = ['surface_white_' lst_side{flg} '.mat'];
            cfg.surfinflated            = ['surface_inflated_' lst_side{flg} '_caret.mat'];
            ft_sourceplot(cfg, dataplot);
            
            title([num2str(nm) ' ' num2str(nb)]);
            
            view(lst_view(flg,:));
            
            
        end
    end
end