clear;

clear ; global ft_default; clc;
ft_default.spmversion   = 'spm12';

suj_list                                             	= [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    subjectname                                         = ['sub' num2str(suj_list(nsuj))];
    
    list_time                                       	= {'m560m200' 'p640p1000'};
    list_nback                                          = {'1back' '2back'};
    list_band                                           = {'alpha' 'beta'};
        
    load('../data/stock/template_grid_0.5cm.mat');
    
    for nband = 1:length(list_band)        
        for nback = 1:length(list_nback)
            for ntime = 1:2
                
                fname                               	= dir(['J:/nback/source/combined/' subjectname '.' list_nback{nback} '.target.' ...
                    list_band{nband} '.*.' list_time{ntime} '.dicsCombined.mat']);
                fprintf('loading %s\n',fname.name)
                load([fname.folder filesep fname.name]);
                tmp_time{ntime}                         = source.pow; clear source;
            end
            %             tmp_nbk{nback}                              = tmp_time{2}; clear tmp_time; %
            tmp_nbk{nback}                              = (tmp_time{2} - tmp_time{1}) ./ tmp_time{1}; clear tmp_time;
        end
        
        source.pos                                      = template_grid.pos;
        source.dim                                      = template_grid.dim;
        source.pow                                      = tmp_nbk{1} - tmp_nbk{2};
        alldata{nsuj,nband}                             = source; clear source tmp_nbk
        fprintf('\n');
    end
end

clearvars -except alldata list_band;

%%

for ncond = 1:size(alldata,2)
    gavg{ncond}	= ft_sourcegrandaverage([],alldata{:,ncond});
end

close all;
list_test                                   = [1 2];
list_z                                      = [0.2];

for ntest = 1
    
    new_gavg                                = gavg{1};
    new_gavg.pow                          	= (gavg{list_test(ntest,1)}.pow - gavg{list_test(ntest,2)}.pow);
    
    new_gavg.pow(new_gavg.pow <0)           = NaN;
    
    test_title                              = {[list_band{list_test(ntest,1)} ' vs'], ...
        [list_band{list_test(ntest,2)}]};
    
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
    %     saveas(gcf,['D:/Dropbox/project_me/figures_me/nback/post-kia/source/univar/avg/avg.stim.' num2str(ntest) '.left.png']);
    
    ft_sourceplot(cfg, new_gavg);
    view ([90 0 0]);
    light ('Position',[90 0 0]);
    material dull
    title(test_title);
    %     saveas(gcf,['D:/Dropbox/project_me/figures_me/nback/post-kia/source/univar/avg/avg.stim.' num2str(ntest) '.right.png']);

    
end

