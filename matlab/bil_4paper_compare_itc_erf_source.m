clear ; clc;

if isunix
    project_dir           	= '/project/3015079.01/';
else
    project_dir         	= 'P:/3015079.01/';
end

load ../data/bil_goodsubjectlist.27feb20.mat
load ../data/stock/template_grid_0.5cm.mat ;

for nsuj = 1:length(suj_list)
    
    subjectName          	= suj_list{nsuj};
    list_bin             	= [1 5];
    
    for nbin = 1:length(list_bin)
        
        dir_data           	= [project_dir 'data/' subjectName '/source/'];
        
        fname             	= [dir_data subjectName '.cuelock.rtBin' num2str(list_bin(nbin)) '.p3700p5000ms.lcmvsource.mat'];
        fprintf('loading %s\n',fname);
        load(fname); act = source; clear source;
        
        source            	= [];
        source.pos        	= template_grid.pos;
        source.dim        	= template_grid.dim;
        source.pow        	= act;
        
        tmp{nbin}         	= source; clear source act;
        
    end
    
    alldata{nsuj,1}        	= tmp{1};
    alldata{nsuj,1}.pow     = ((tmp{1}.pow - tmp{2}.pow) ./ tmp{2}.pow); clear tmp
    
end

for nsuj = 1:length(suj_list)
    
    subjectName          	= suj_list{nsuj};
    list_window          	= 'p4300p5500';
    
    source_avg            	= [];
    list_time              	= list_window;
    load('../data/stock/template_grid_0.5cm.mat');
    
    for nbin = 1:length(list_bin)
        
        ext_source         	= ['1t5Hz.bin' num2str(list_bin(nbin)) '.withincorrect.pccsource'];
        
        fname               = [project_dir 'data/' subjectName '/source/' subjectName '.itc.' ...
            list_time '.' ext_source '.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        act               	= plf; clear plf;
        
        source          	= [];
        source.pos        	= template_grid.pos;
        source.dim      	= template_grid.dim;
        source.pow        	= (act);
        
        tmp{nbin}         	= source; clear source;
        
    end
    
    alldata{nsuj,2}         = tmp{1};           
    alldata{nsuj,2}.pow     = ((tmp{1}.pow - tmp{2}.pow) ./ tmp{2}.pow); clear tmp
    
end

keep alldata

cfg                         =  [];
cfg.method                  =  'montecarlo';
cfg.statistic               = 'depsamplesT';
cfg.parameter               = 'pow';
cfg.correctm                = 'cluster';

cfg.clusteralpha            = 0.005;  % First Threshold

cfg.clusterstatistic        = 'maxsum';
cfg.numrandomization        = 1000;
cfg.alpha                   = 0.025;
cfg.tail                    = 0;
cfg.clustertail             = 0;

nsuj                        = size(alldata,1);
cfg.design(1,:)             = [1:nsuj 1:nsuj];
cfg.design(2,:)             = [ones(1,nsuj) ones(1,nsuj)*2];
cfg.uvar                    = 1;
cfg.ivar                    = 2;

stat                        = ft_sourcestatistics(cfg, alldata{:,1},alldata{:,2});
[min_p,p_val]               = h_pValSort(stat);

list_view                   = [-90 0 0; 90 0 0; 0 0 90];

%%

for nview = [1 2]
    
    cfg                     = [];
    cfg.method              = 'surface';
    cfg.funparameter        = 'pow';
    cfg.maskparameter       = cfg.funparameter;
    
    zlim                    = 4;
    cfg.funcolorlim         = [-zlim zlim];
    cfg.funcolormap         = brewermap(256,'*RdBu');
    cfg.projmethod          = 'nearest';
    cfg.camlight            = 'no';
    cfg.surfinflated        = 'surface_inflated_both_caret.mat';
    
    source_plot             = [];
    source_plot.pos         = stat.pos;
    source_plot.dim         = stat.dim;
    source_plot.pow         = stat.stat .* stat.mask;
    
    ft_sourceplot(cfg, source_plot);
    view(list_view(nview,:));
    title('erf - itc');
    
end