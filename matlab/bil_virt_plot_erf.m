clear;clc; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName         = suj_list{nsuj};
    dir_data            = '~/Dropbox/project_me/data/bil/virt/';
    
    fname               = [dir_data subjectName '.mni.slct.allCue.correct.erf.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    ix1                 = find(round(avg.time,3) == round(-0.1,3));
    ix2                 = find(round(avg.time,3) == round(0,3));
    bsl                 = mean(avg.avg(:,ix1:ix2),2);
    act                 = avg.avg;
    
    avg.avg             = act - bsl;
    
    alldata{nsuj,1}     = avg; clear avg;
    
end

keep alldata



%

for ntime = [0:0.2:5]
    
    tmp                     = [];
    
    for nsuj = 1:size(alldata,1)
        
        ix1                 = find(round(alldata{nsuj,1}.time,3) == round(ntime,3));
        ix2                 = find(round(alldata{nsuj,1}.time,3) == round(ntime+0.2,3));
        
        pow             	= mean(alldata{nsuj,1}.avg(:,ix1:ix2),2);
        
        tmp(:,nsuj)     	= pow; clear ix1 ix2 pow scores;
        
    end
    
    keep alldata tmp gavg
    
    cfg                     = [];
    cfg.template_file      	= '../data/stock/template_grid_0.5cm.mat';
    cfg.index_file          = '../data/index/mnislct4bil.mat';
    cfg.label               = alldata{1,1}.label;
    source              	= h_towholebrain(cfg,mean(tmp,2));
    
    for iside = [3]
        
        lst_side        	= {'left','right','both'};
        lst_view        	= [-95 1;97 5;0 50];
        
        cfg                 = [];
        cfg.method          = 'surface';
        cfg.funparameter   	= 'pow';
        %     cfg.maskparameter  	= cfg.funparameter;
        %     cfg.funcolorlim    	= [0 0.5];  % 'zeromax'; %
        cfg.funcolormap   	= brewermap(256,'*RdBu');
        cfg.projmethod     	= 'nearest';
        cfg.camlight      	= 'no';
        cfg.surfinflated   	= 'surface_inflated_both_caret.mat';
        
        ft_sourceplot(cfg, source);
        
        view(lst_view(iside,:));
        
    end
        
end