clear;close all;

suj_list                        	= [1:33 35:36 38:44 46:51];
alldata                             = [];

load ../data/stock/template_grid_0.5cm.mat

for ns = 1:length(suj_list)
    
    sub_carr                            = [];
    
    for nsession = 1:2
        
        sess_carr                       = [];
        
        for nstim = 1:10
            
            fname                       = ['J:/temp/nback/data/stim_ag_all/sub' num2str(suj_list(ns)) '.sess' num2str(nsession) ... 
                '.stim' num2str(nstim)  '.against.all.bsl.dwn70.coef.lcmv.mat'];
            
            fprintf('loading %50s\n',fname);
            load(fname);
            
            data.avg                    = abs(data.avg);
            
            sess_carr(:,:,nstim)        = data.avg; time_axis = data.time; clear data;
            
        end
        
        sub_carr(:,:,nsession)          = squeeze(mean(sess_carr,3)); clear sess_carr;
        fprintf('\n');
        
    end
    
    sub_carr                            = squeeze(mean(sub_carr,3));
    
    time_window                         = [0 0.1; 0.1 0.2; 0.2 0.3; 0.3 0.4; 0.4 0.5];
    
    for ntime = 1:size(time_window,1)
        
        t1                              = find(round(time_axis,2) == round(time_window(ntime,1),2));
        t2                              = find(round(time_axis,2) == round(time_window(ntime,2),2));
        act                             = mean(sub_carr(:,t1:t2),2);
        
        t1                              = find(round(time_axis,2) == round(-0.1,2));
        t2                              = find(round(time_axis,2) == round(0,2));
        
        if isempty(t1) || isempty(t2) || length(t1)>1 || length(t2)>1
            error('problem with baseline indices');
        end
        
        bsl                             = mean(sub_carr(:,t1:t2),2);
        
        source                          = [];
        source.pos                      = template_grid.pos;
        source.dim                      = template_grid.dim;
        source.pow                      = nan(length(source.pos),1);
        
        indx                            = find(template_grid.inside ==1);
        source.pow(indx)                = (act-bsl)./bsl; clear act bsl t1 t2
        
        alldata{ns,ntime}              	= source; clear source;
        
    end
    
    clear sub_carr
    
end

keep alldata;

for ntime = 1:size(alldata,2)
    data{ntime}                         = ft_sourcegrandaverage([],alldata{:,ntime});
end

cfg = [];
cfg.method                              = 'surface';
cfg.funparameter                        = 'pow';
cfg.maskparameter                       = cfg.funparameter;
cfg.funcolorlim                         = [0 6];
cfg.funcolormap                         = brewermap(256,'Reds');
cfg.projmethod                          = 'nearest';
cfg.camlight                            = 'no';
cfg.surfinflated                        = 'surface_inflated_both_caret.mat';
% cfg.projthresh                          = 0.6;

for ntime = 1:length(data)
    ft_sourceplot(cfg, data{ntime});
    view ([-90 0 0]);
    light ('Position',[-90 0 0]);
    material dull
    
    title(num2str(ntime));
    saveas(gcf,['D:/Dropbox/project_me/pub/Papers/postdoc/nback_manuscript/_figures/stim_ag_all_coef/stim.ag.all.nothresh.' num2str(ntime) '.left.png']);
    close all;
    
    ft_sourceplot(cfg, data{ntime});
    view ([90 0 0]);
    light ('Position',[90 0 0]);
    material dull
    
    title(num2str(ntime));
    saveas(gcf,['D:/Dropbox/project_me/pub/Papers/postdoc/nback_manuscript/_figures/stim_ag_all_coef/stim.ag.all.nothresh.' num2str(ntime) '.right.png']);
    close all;
    
end


% cfg = [];
% cfg.method         = 'surface';
% cfg.funparameter   = 'parcel';
% cfg.funcolorlim    = [-30 30];
% cfg.funcolormap    = 'jet';
% cfg.projmethod     = 'nearest';
% cfg.surfinflated   = 'surface_inflated_both_caret.mat';
% cfg.projthresh     = 0.8;
% cfg.camlight       = 'no';
% ft_sourceplot(cfg, source_int);
% view ([-70 20 50])
% light ('Position',[-70 20 50])
% material dull