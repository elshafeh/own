clear ; clc; close all;
global ft_default
ft_default.spmversion                   = 'spm12';

if isunix
    project_dir                             = '/project/3015079.01/';
else
    project_dir                             = 'P:/3015079.01/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName                             = suj_list{nsuj};
    
    list_window                             = {'p3500p4500' 'p4500p5000' 'p5000p6000'};
    list_bsl                                = {'m1200m200' 'm900m400' 'm1200m200'};
    
    for nbin    = 1:5
        for ntime = 1:length(list_window)
            
            list_time                    	= {list_bsl{ntime},list_window{ntime}};
            
            load('../data/stock/template_grid_0.5cm.mat');
            
            ext_source                      = ['2t4Hz.bin' num2str(nbin) '.pccsource'];
            
            fname                           = [project_dir 'data/' subjectName '/source/' subjectName '.itc.'  ...
                list_time{1} '.' ext_source '.mat'];
            fprintf('loading %s\n',fname);
            load(fname); bsl = plf; clear plf;
            
            fname                           = [project_dir 'data/' subjectName '/source/' subjectName '.itc.' ...
                list_time{2} '.' ext_source '.mat'];
            fprintf('loading %s\n',fname);
            load(fname); act = plf; clear plf;
            
            source                      	= [];
            source.pos                   	= template_grid.pos;
            source.dim                  	= template_grid.dim;
            source.pow                    	= (act- bsl);% ./ bsl;
            
            alldata{nsuj,nbin,ntime}        = source;
            allpoints(nsuj,nbin,ntime,:)    = source.pow; clear source act bsl;
            
        end
    end
end

clearvars -except alldata list_window allpoints

cfg                                         =   [];
cfg.dim                                     =   alldata{1}.dim;
cfg.method                                  =   'montecarlo';
cfg.statistic                               =   'depsamplesT';
cfg.parameter                               =   'pow';
cfg.correctm                                =   'cluster';
cfg.clusteralpha                            =   0.05;             % First Threshold
cfg.clusterstatistic                        =   'maxsum';
cfg.numrandomization                        =   1000;
cfg.alpha                                   =   0.025;
cfg.tail                                    =   0;
cfg.clustertail                             =   0;

nsuj                                        =   size(alldata,1);
cfg.design(1,:)                             =   [1:nsuj 1:nsuj];
cfg.design(2,:)                             =   [ones(1,nsuj) ones(1,nsuj)*2];
cfg.uvar                                    =   1;
cfg.ivar                                    =   2;

for ntime = 1:size(alldata,3)
    stat{ntime}                             =   ft_sourcestatistics(cfg, alldata{:,1,ntime},alldata{:,5,ntime});
end

clearvars -except alldata list_window allpoints stat

for ntime = 1:size(alldata,3)
    [min_p(ntime),p_val{ntime}]             = h_pValSort(stat{ntime});
end

cfg                                         = [];
cfg.method                                  = 'surface';
cfg.funparameter                            = 'pow';
cfg.maskparameter                           = cfg.funparameter;
cfg.funcolorlim                             = [-1 1]; %'zeromax'; %[0 0.5]; %
cfg.funcolormap                             = brewermap(256,'Reds');
cfg.projmethod                              = 'nearest';
cfg.camlight                                = 'no';
cfg.surfinflated                            = 'surface_inflated_both_caret.mat';
% cfg.projthresh                          = 0.6;

list_view                                   = [-90 0 0; 90 0 0; 0 0 90];

for ntime = 2 %1:length(stat)
    
    stolplot                                = stat{ntime};
    stolplot.mask                           = stolplot.prob < 0.1;
    
    source.pos                              = stolplot.pos ;
    source.dim                              = stolplot.dim ;
    tpower                                  = stolplot.stat .* stolplot.mask;
    tpower(tpower == 0)                     = NaN;
    source.pow                              = tpower ; clear tpower;
    
    for nview = [1 2]
        ft_sourceplot(cfg,source);
        view(list_view(nview,:));
        light ('Position',list_view(nview,:));
        material dull
        title([list_window{ntime}]);
    end
    
    clear source stolplot
    
end