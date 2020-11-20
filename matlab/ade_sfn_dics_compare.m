clear ; clc;

load ../data/goodsubjects-07-Oct-2019.mat;
load ../data/template_grid_0.5cm.mat;

for nm = 1:length(list_modality)
    
    list_suj                                    = goodsubjects{nm};
    modality                                    = list_modality{nm};
    
    for ns = 1:length(list_suj)
        
        for nb = 1:6
            
            subjectName                         = list_suj{ns};
            
            %             fname                               = ['../data/' subjectName '.' modality '.sfn.powerpeak.dicsRegress.b' num2str(nb) '.mat'];
            fname                               = ['../data/' subjectName '.' modality '.sfn.powerpeak.dics.b' num2str(nb) '.mat'];
            
            fprintf('load %s \n',fname);
            load(fname);
            
            data{nm}{ns,nb}                     = [];
            data{nm}{ns,nb}.pos                 = template_grid.pos;
            data{nm}{ns,nb}.dim                 = template_grid.dim;
            data{nm}{ns,nb}.inside              = template_grid.inside;
            
            if isfield(source,'avg')
                
                source.pow                      = source.avg.pow ./ source.avg.noise;
                data{nm}{ns,nb}.pow             = source.pow;
                
            end
            
            clear source
            
        end
        
    end
    
end

clearvars -except data list_modality suj_group; close all;

list_side                           = [1 2 3];

for i = 1:length(list_side)
    for nb = 1:6
        
        data1                       = ft_sourcegrandaverage([],data{1}{:,nb});
        data2                       = ft_sourcegrandaverage([],data{2}{:,nb});
        
        dataplot                    = data1;
        dataplot.pow                = data1.pow - data2.pow;
        
        clear data1 data2
        
        flg                         = list_side(i);
        
        lst_side                    = {'left','right','both'};
        lst_view                    = [-95 1;95 1;0 10];
        
        cfg                         = [];
        cfg.method                  = 'surface';
        cfg.funparameter            = 'pow';
        
        cfg.maskparameter           = cfg.funparameter;
        
        cfg.opacitylim              = 'maxabs'; % maxabs zeromax minzero
        cfg.funcolorlim             = 'maxabs'; % maxabs zeromax minzero
        cfg.camlight                = 'no';
        
        cfg.opacitymap              = 'rampup';
        cfg.projmethod              = 'nearest';
        
        %             cfg.funcolormap             = brewermap(256,'Reds');
        
        cfg.surffile                = ['surface_white_' lst_side{flg} '.mat'];
        cfg.surfinflated            = ['surface_inflated_' lst_side{flg} '_caret.mat'];
        ft_sourceplot(cfg, dataplot);
        
        title(num2str(nb));
        
        view(lst_view(flg,:));
        
        %             fout                        = ['../figures/sfn/source/relative2B1.' list_modality{nm} '.' num2str(nb)  '.' num2str(i) '.png'];
        %             saveas(gca,fout);
        %             close all;
        
    end
end