clear;clc; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

load ../data/bil_goodsubjectlist.27feb20.mat

tmp                     = [];

for nsuj = 1:length(suj_list)
    
    subjectName         = suj_list{nsuj};
    dir_data            = '~/Dropbox/project_me/data/bil/virt/';
    
    fname               = [dir_data subjectName '.mni.slct.alpha.beta.peak.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    peak_focus          = 2;
    allpeaks            = allpeaks(:,peak_focus);
    fnd_nan             = find(isnan(allpeaks));
    
    if ~isempty(fnd_nan)
        allpeaks(fnd_nan)   = nanmean(allpeaks);
    end
    
    tmp(:,nsuj)         = allpeaks; clear allpeaks fnd_nan;
    
end

keep alldata tmp gavg peak_focus

load ~/Dropbox/project_me/data/bil/virt/sub001.mni.slct.allCue.correct.erf.mat;

cfg                     = [];
cfg.template_file      	= '../data/stock/template_grid_0.5cm.mat';
cfg.index_file          = '../data/index/mnislct4bil.mat';
cfg.label               = avg.label;
source              	= h_towholebrain(cfg,mean(tmp,2));

for iside = [1 2 3]
    
    lst_side        	= {'left','right','both'};
    lst_view        	= [-95 1;97 5;0 50];
    
    cfg                 = [];
    cfg.method          = 'surface';
    cfg.funparameter   	= 'pow';
    %     cfg.maskparameter  	= cfg.funparameter;
    
    zlimit              = [7 15;15 35];
    cfg.funcolorlim    	= zlimit(peak_focus,:);
    cfg.funcolormap   	= brewermap(256,'*Spectral');
    cfg.projmethod     	= 'nearest';
    cfg.camlight      	= 'no';
    cfg.surfinflated   	= 'surface_inflated_both_caret.mat';
    
    ft_sourceplot(cfg, source);
    
    view(lst_view(iside,:));
    
end