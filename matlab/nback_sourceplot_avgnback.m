clear ; global ft_default
ft_default.spmversion   = 'spm12';

suj_list                                             	= [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    subjectname                                         = ['sub' num2str(suj_list(nsuj))];
    list_time                                       	= {'m940m200' 'p260p1000'};
    
    list_cond                                           = {'first.alpha' 'target.alpha' 'first.beta' 'target.beta'};
    
    load('../data/stock/template_grid_0.5cm.mat');
    
    for ncond = 1:length(list_cond)
        
        for nback = 1:2
            for ntime = 1:2
                fname                               	= dir(['J:/nback/source/combined/' subjectname '.' num2str(nback) 'back.' list_cond{ncond} ... 
                    '.*.' list_time{ntime} '.dicsCombined.mat']);
                fprintf('loading %s\n',fname.name);
                load([fname.folder filesep fname.name]);
                tmp_time{ntime}                         = source.pow; clear source;
            end
            tmp_back{nback}                             = (tmp_time{2} - tmp_time{1}) ./ tmp_time{1}; clear tmp_time;
        end
        
        source.pos                                      = template_grid.pos;
        source.dim                                      = template_grid.dim;
        source.pow                                      = nanmean([tmp_back{1} tmp_back{2}],2);
        alldata{nsuj,ncond}                             = source; clear source tmp_back
        
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
list_test                                   = [1 2; 3 4; 3 1; 4 2];

for ncond = 1:size(list_test,1)
    
    new_gavg                                = gavg{1};
    new_gavg.pow                          	= (gavg{list_test(ncond,1)}.pow - gavg{list_test(ncond,2)}.pow);
    
    new_gavg.pow(new_gavg.pow <0)           = NaN;
    
    test_title                              = {[list_cond{list_test(ncond,1)} ' vs'],[list_cond{list_test(ncond,2)}]};
    
    cfg                                     = [];
    cfg.method                              = 'surface';
    cfg.funparameter                        = 'pow';
    cfg.maskparameter                       = cfg.funparameter;
    cfg.funcolorlim                         = [-0.1 0.1];
    cfg.funcolormap                         = brewermap(256,'*RdBu');
    cfg.projmethod                          = 'nearest';
    cfg.camlight                            = 'no';
    cfg.surfinflated                        = 'surface_inflated_both_caret.mat';
    %     cfg.projthresh                          = 0.3;
    
    ft_sourceplot(cfg, new_gavg);
    view ([-90 0 0]);
    light ('Position',[-90 0 0]);
    material dull
    title(test_title);
    saveas(gcf,['D:/Dropbox/project_me/figures_me/nback/post-kia/source/univar/avg/avg.nback.alpha.source.' num2str(ncond) '.left.png']);
    
    ft_sourceplot(cfg, new_gavg);
    view ([90 0 0]);
    light ('Position',[90 0 0]);
    material dull
    title(test_title);
    saveas(gcf,['D:/Dropbox/project_me/figures_me/nback/post-kia/source/univar/avg/avg.nback.alpha.source.' num2str(ncond) '.right.png']);

    
end