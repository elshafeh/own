clear ; clc; close all;

if isunix
    project_dir                             = '/project/3015079.01/';
else
    project_dir                             = 'P:/3015079.01/';
end

load ../data/bil_goodsubjectlist.27feb20.mat;
load ../data/stock/template_grid_0.5cm.mat;

for nsuj = 1:length(suj_list)
    
    subjectName                             = suj_list{nsuj};
    sub_avg                                 = [];
    
    for nbin    = 1:5
        
        fname                               = dir([project_dir 'data/' subjectName '/source/*.m1000m0.preCue1alphasorted.bin' num2str(nbin) '.AlphaReconDics.mat']);
        fname                               = [fname(1).folder filesep fname(1).name];
        fprintf('loading %s\n',fname);
        load(fname); act = source; clear source;
        
        sub_avg                            	= [sub_avg act];
        
        source                              = [];
        source.pos                          = template_grid.pos;
        source.dim                          = template_grid.dim;
        source.pow                          = (act); 
        
        alldata{nsuj,nbin}                  = source;
        
    end
    
    sub_avg                                 = nanmean(sub_avg,2);
    
    for nbin = 1:5
        alldata{nsuj,nbin}.pow              = (alldata{nsuj,nbin}.pow - sub_avg) ./ sub_avg;
    end
    
    clear sub_avg;
    
end

clearvars -except alldata

cfg                                     = [];
cfg.method                              = 'surface';
cfg.funparameter                        = 'pow';
cfg.maskparameter                       = cfg.funparameter;
cfg.funcolorlim                         = [-0.5 0.5];% [0 0.05]; % %[0 0.5]; %
cfg.funcolormap                         = brewermap(256,'*RdBu'); % brewermap(256,'Reds');
cfg.projmethod                          = 'nearest';
cfg.camlight                            = 'no';
cfg.surfinflated                        = 'surface_inflated_both_caret.mat';
% cfg.projthresh                          = 0.6;
list_view                               = [-90 0 0; 90 0 0; 0 0 90];

for nview = [3]
    for nbin = [1 2 3 4 5]
        
        ft_sourceplot(cfg, ft_sourcegrandaverage([],alldata{:,nbin}));
        view (list_view(nview,:));
        light ('Position',list_view(nview,:));
        material dull
        title(['bin' num2str(nbin)]);
        saveas(gcf,['../figures/bil/source/alpha/sortedbins.b' num2str(nbin) '.v' num2str(nview) '.png']);
        close all;
        
    end
end