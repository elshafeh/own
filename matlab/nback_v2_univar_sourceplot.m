clear ; global ft_default
ft_default.spmversion   = 'spm12';

suj_list                                                 	= [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    subjectname                                          	= ['sub' num2str(suj_list(nsuj))];
    list_time                                            	= {'m480m200','p720p1000'};
    
    list_cond                                               = {'1back.target.alpha' '2back.target.alpha'};
    
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
                source.pow                                  = (source.pow - bsl) ./ bsl;%source.pow; %
                alldata{nsuj,ncond}                         = source;
            end
            
            clear source
            
        end
    end    
end

clearvars -except alldata list_cond;clc;

%%

for ncond = 1:size(alldata,2)
    gavg{ncond}	= ft_sourcegrandaverage([],alldata{:,ncond});
end

clearvars -except alldata list_cond gavg;

%%

close all;
list_test                                   = [1 2];

for ncond = 1:size(list_test,1)
    
    new_gavg                                = gavg{1};
    new_gavg.pow                          	= (gavg{list_test(ncond,1)}.pow - gavg{list_test(ncond,2)}.pow);
    %     new_gavg.pow                          	= (gavg{list_test(ncond,1)}.pow - gavg{list_test(ncond,2)}.pow) ./ gavg{list_test(ncond,2)}.pow;
    
    test_title                              = {[list_cond{list_test(ncond,1)} ' vs'],[list_cond{list_test(ncond,2)}]};
    zlim                                    = 0.1;
    
    cfg                                     = [];
    cfg.method                              = 'surface';
    cfg.funparameter                        = 'pow';
    cfg.maskparameter                       = cfg.funparameter;
    cfg.funcolorlim                         = [-zlim zlim];
    cfg.funcolormap                         = brewermap(256,'*RdBu');
    cfg.projmethod                          = 'nearest';
    cfg.camlight                            = 'no';
    cfg.surfinflated                        = 'surface_inflated_both_caret.mat';
    %     cfg.projthresh                          = 0.8;
    
    ft_sourceplot(cfg, new_gavg);
    view ([-90 0 0]);
    light ('Position',[-90 0 0]);
    material dull
    title(test_title);
    
    fig_dir                                 = 'D:/Dropbox/project_me/pub/Papers/postdoc/nback_manuscript_v2/_new_prep/source/';
    fig_ext                                 = 'univar.alpha.source';
    saveas(gcf,[fig_dir fig_ext '.left.png']);
    
    ft_sourceplot(cfg, new_gavg);
    view ([90 0 0]);
    light ('Position',[90 0 0]);
    material dull
    title(test_title);
    
    saveas(gcf,[fig_dir fig_ext '.right.png']);
    
end