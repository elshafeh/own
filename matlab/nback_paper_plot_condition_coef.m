clear;close all;

suj_list                                = [1:33 35:36 38:44 46:51];
alldata                                 = [];

load ../data/stock/template_grid_0.5cm.mat

for nsuj = 1:length(suj_list)
    
    sub_carr                            = [];
    i                                   = 0;
    
    for ncond = 1:2
        fname_list                      = dir(['J:/temp/nback/data/source/coef/sub' num2str(suj_list(nsuj)) '.sess' num2str(ncond) '.' ...
            num2str(ncond-1) 'back.lockedon.all.dwn70.bsl.excl.deocdingCond.coef.lcmv.mat']);
        
        for nfile = 1:length(fname_list)
            i                           = i+1;
            fprintf('loading %50s\n',[fname_list(nfile).folder filesep fname_list(nfile).name]);
            load([fname_list(nfile).folder filesep fname_list(nfile).name]);
            data.avg                    = abs(data.avg);
            sub_carr(:,:,i)             = data.avg; 
            time_axis = data.time; clear data;
        end
        
    end
    
    fprintf('\n');
    
    sub_carr                            = squeeze(mean(sub_carr,3));
    
    time_window                         = [0 0.2; 0.2 0.4; 0.4 0.6; 0.6 0.8; 0.8 1];
    
    for ntime = 1:size(time_window,1)
        
        [indx_time]                    	= h_findval(time_axis,time_window(ntime,:),2);
        [indx_bsl]                    	= h_findval(time_axis,[-0.1 0],2);
        
        act                             = mean(sub_carr(:,indx_time),2);
        bsl                             = mean(sub_carr(:,indx_bsl),2);
        
        source                          = [];
        source.pos                      = template_grid.pos;
        source.dim                      = template_grid.dim;
        source.pow                      = nan(length(source.pos),1);
        
        indx                            = find(template_grid.inside ==1);
        source.pow(indx)                = (act-bsl)./bsl; clear act bsl t1 t2
        
        alldata{nsuj,ntime}           	= source; clear source;
        
    end
    
    clear sub_carr
    
end

keep alldata;

for ntime = 1:size(alldata,2)
    data{ntime}                         = ft_sourcegrandaverage([],alldata{:,ntime});
end

cfg                                     = [];
cfg.method                              = 'surface';
cfg.funparameter                        = 'pow';
cfg.maskparameter                       = cfg.funparameter;
cfg.funcolorlim                         = [0 5];
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
    saveas(gcf,['D:/Dropbox/project_me/pub/Papers/postdoc/nback_manuscript/_figures/condition_coef/condition.coef.concat.' ...
        num2str(ntime) '.left.png']);
    close all;
    
    ft_sourceplot(cfg, data{ntime});
    view ([90 0 0]);
    light ('Position',[90 0 0]);
    material dull
    
    title(num2str(ntime));
    saveas(gcf,['D:/Dropbox/project_me/pub/Papers/postdoc/nback_manuscript/_figures/condition_coef/condition.coef.concat.' ...
        num2str(ntime) '.right.png']);
    close all;
    
end