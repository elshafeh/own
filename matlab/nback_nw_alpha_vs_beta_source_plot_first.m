clear ; global ft_default
ft_default.spmversion   = 'spm12';

suj_list                                                 	= [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    subjectname                                          	= ['sub' num2str(suj_list(nsuj))];
    list_time                                            	= {'m800m200','p340p940'};
    
    list_cond                                               = {'1back.first.alpha' '2back.first.alpha' '1back.first.beta' '2back.first.beta'};
    
    load('../data/stock/template_grid_0.5cm.mat');
    
    for ncond = 1:length(list_cond)
        
        for ntime = 1:length(list_time)
            
            fname                                           = dir(['J:/nback/source/combined/' subjectname '.' list_cond{ncond} '.*.' list_time{ntime} '.dicsCombined.mat']);
            fprintf('loading %s\n',fname.name);
            load([fname.folder filesep fname.name]);
            
            source.pos                                      = template_grid.pos;
            source.dim                                      = template_grid.dim;
            
            if ntime == 1 % keep first as baseline
                bsl                                         = source.pow;
            else
                source.pow                                  = (source.pow - bsl) ./ bsl;
                alldata{nsuj,ncond}                         = source;
            end
            
            clear source
            
        end
    end    
end

clearvars -except alldata list_cond;

%%

for ncond = 1:size(alldata,2)
    gavg{ncond}	= ft_sourcegrandaverage([],alldata{:,ncond});
end

clearvars -except alldata list_cond gavg;

%%

close all;
list_test                                   = [3 1; 4 2; 3 4];
zlim                                        = [0.2 0.15 0.2];
dir_mask                                    = [];

for ncond = 1:size(list_test,1)
    
    new_gavg                                = gavg{1};
    new_gavg.pow                          	= (gavg{list_test(ncond,1)}.pow - gavg{list_test(ncond,2)}.pow);% ./ gavg{list_test(ncond,2)}.pow;
    
    new_gavg.pow(new_gavg.pow < 0)          = 0;
    
    test_title                              = {[list_cond{list_test(ncond,1)} ' vs'],[list_cond{list_test(ncond,2)}]};
    
    cfg                                     = [];
    cfg.method                              = 'surface';
    cfg.funparameter                        = 'pow';
    cfg.maskparameter                       = cfg.funparameter;
    cfg.funcolorlim                         = [-zlim(ncond) zlim(ncond)];%'maxabs';
    cfg.funcolormap                         = brewermap(256,'*RdBu');
    cfg.projmethod                          = 'nearest';
    cfg.camlight                            = 'no';
    cfg.surfinflated                        = 'surface_inflated_both_caret.mat';
    cfg.projthresh                          = 0.4;
    
    ft_sourceplot(cfg, new_gavg);
    view ([-90 0 0]);
    light ('Position',[-90 0 0]);
    material dull
    title(test_title);
    saveas(gcf,['D:\Dropbox\project_me\figures_me\nback\post-kia\source\univar\alpha v beta\first\test' num2str(ncond) '.left.png']);
    
    ft_sourceplot(cfg, new_gavg);
    view ([90 0 0]);
    light ('Position',[90 0 0]);
    material dull
    title(test_title);
    saveas(gcf,['D:\Dropbox\project_me\figures_me\nback\post-kia\source\univar\alpha v beta\first\test' num2str(ncond) '.right.png']);
    
end