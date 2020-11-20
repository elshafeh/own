clear ; global ft_default; clc;
ft_default.spmversion   = 'spm12';

suj_list                                             	= [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    subjectname                                         = ['sub' num2str(suj_list(nsuj))];
    list_time                                       	= {'m720m200' 'p340p860'};
    
    list_cond                                           = {'1back.first' '2back.first' '1back.target' '2back.target'};
    
    load('../data/stock/template_grid_0.5cm.mat');
    
    for ncond = 1:length(list_cond)
        
        list_temp                                       = {'alpha' 'beta'};
        
        for ntemp = 1:2
            for ntime = 1:2
                fname                               	= dir(['J:/nback/source/combined/' subjectname '.' list_cond{ncond} '.' list_temp{ntemp} ... 
                    '.*.' list_time{ntime} '.dicsCombined.mat']);
                fprintf('loading %s\n',fname.name);
                load([fname.folder filesep fname.name]);
                tmp_time{ntime}                         = source.pow; clear source;
            end
            tmp_temp{ntemp}                             = (tmp_time{2} - tmp_time{1}) ./ tmp_time{1}; clear tmp_time;
        end
        
        source.pos                                      = template_grid.pos;
        source.dim                                      = template_grid.dim;
        source.pow                                      = nanmean([tmp_temp{1} tmp_temp{2}],2);
        alldata{nsuj,ncond}                             = source; clear source tmp_temp
        fprintf('\n');
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
list_test                                   = [1 3; 2 4; 4 2];
list_z                                      = [0.15 0.1 0.025];

for ntest = 1:size(list_test,1)
    
    new_gavg                                = gavg{1};
    new_gavg.pow                          	= (gavg{list_test(ntest,1)}.pow - gavg{list_test(ntest,2)}.pow);
    
    new_gavg.pow(new_gavg.pow <0)           = NaN;
    
    test_title                              = {[list_cond{list_test(ntest,1)} ' vs'],[list_cond{list_test(ntest,2)}]};
    
    cfg                                     = [];
    cfg.method                              = 'surface';
    cfg.funparameter                        = 'pow';
    cfg.maskparameter                       = cfg.funparameter;
    cfg.funcolorlim                         = [-list_z(ntest) list_z(ntest)];
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
    saveas(gcf,['D:/Dropbox/project_me/figures_me/nback/post-kia/source/univar/avg/avg.osc.' num2str(ntest) '.left.png']);
    
    ft_sourceplot(cfg, new_gavg);
    view ([90 0 0]);
    light ('Position',[90 0 0]);
    material dull
    title(test_title);
    saveas(gcf,['D:/Dropbox/project_me/figures_me/nback/post-kia/source/univar/avg/avg.osc.' num2str(ntest) '.right.png']);

    
end