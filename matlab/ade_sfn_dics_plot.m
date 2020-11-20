clear ; clc;

load ../data/goodsubjects-07-Oct-2019.mat;
load ../data/template_grid_0.5cm.mat;

for nm = 1:length(list_modality)
    
    list_suj                                    = goodsubjects{nm};
    modality                                    = list_modality{nm};
    
    for ns = 1:length(list_suj)
        
        baseline                                = [];
        
        for nb = 1:6
            
            subjectName                         = list_suj{ns};
            
            ext_name                            = '.sfn.powerpeak.dics.b';
            
            fname                               = ['../data/' subjectName '.' modality ext_name num2str(nb) '.mat'];

            fprintf('load %s \n',fname);
            load(fname);
            
            data{nm}{ns,nb}                     = [];
            data{nm}{ns,nb}.pos                 = template_grid.pos;
            data{nm}{ns,nb}.dim                 = template_grid.dim;
            data{nm}{ns,nb}.inside              = template_grid.inside;
            
            baseline                            = [baseline source.avg.pow];
            data{nm}{ns,nb}.pow                 = source.avg.pow;
            
            clear source
            
        end
        
        baseline                                = mean(baseline,2);
        
        for nb = 1:6
            data{nm}{ns,nb}.pow                 = (data{nm}{ns,nb}.pow - baseline) ./baseline;
        end
        
        clear baseline;
        
    end
    
end

clearvars -except data list_modality suj_group; 
close all;

for nm = 1:2
    
    list_side   = 1:3;
    
    for i = 1:length(list_side)
        
        for nb = 6
            
            dataplot                    = ft_sourcegrandaverage([],data{nm}{:,nb});
           
            flg                         = list_side(i);
            
            lst_side                    = {'left','right','both'};
            lst_view                    = [-95 1;95 1;0 10];
            
            cfg                         = [];
            cfg.method                  = 'surface';
            cfg.funparameter            = 'pow';
            
            cfg.maskparameter           = cfg.funparameter;
            
            zlim_list                   = [0.5 0.5];
            zlim                        = zlim_list(nm);
            
            cfg.opacitylim              = 'maxabs'; %
            cfg.funcolorlim             = 'maxabs'; %[-zlim zlim]; % 
            cfg.camlight                = 'no';
            
            cfg.funcolormap             = brewermap(256,'PuBuGn');
            
            cfg.opacitymap              = 'rampup';
            cfg.projmethod              = 'nearest';
            
            %             cfg.projthresh              = 0.5;
            
            cfg.surffile                = ['surface_white_' lst_side{flg} '.mat'];
            cfg.surfinflated            = ['surface_inflated_' lst_side{flg} '_caret.mat'];
            ft_sourceplot(cfg, dataplot);
            
            title([list_modality{nm} ' ' num2str(nb)]);
            
            view(lst_view(flg,:));
            
            fout                        = ['../figures/source/final/genBaseline.' list_modality{nm} '.' num2str(nb)  '.' num2str(flg) '.png'];
            
            saveas(gca,fout);
            close all;
            
        end
    end
end