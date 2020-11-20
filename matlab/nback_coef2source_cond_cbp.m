clear; global ft_default;
ft_default.spmversion = 'spm12';

load ../data/suj.list.alphabetapeak.m1000m0ms.max20chan.p50p200ms.mat
list_suj                              	        = good_list;

load ../data/template_grid_0.5cm.mat

for ns  = 1:length(list_suj)
    
    list_cond                                   = {'0v2B','1v2B'};
    
    for nses = 1:2
        
        
        sub_carr                              	= [];
        time_axis                              	= [];
        
        fname                                   = ['~/Dropbox/project_me/data/nback/source/coef/cond/sub' num2str(list_suj(ns)) '.sess' num2str(nses) '.' list_cond{nses} '.1stwindow.coef.lcmv.mat'];
        fprintf('loading %50s\n',fname);
        load(fname);
        
        sub_carr                                = [sub_carr abs(data.avg)];
        time_axis                               = [time_axis data.time]; clear data;
        
        fname                                   = ['~/Dropbox/project_me/data/nback/source/coef/cond/sub' num2str(list_suj(ns)) '.sess' num2str(nses) '.' list_cond{nses} '.2ndwindow.coef.lcmv.mat'];
        fprintf('loading %50s\n',fname);
        load(fname);
        
        sub_carr                                = [sub_carr(:,1:end-1) abs(data.avg)];
        time_axis                               = [time_axis(1:end-1) data.time]; clear data;
        
        time_width                              = 0.5;
        time_window                             = [0.2 2.2];
        
        for ntime = 1:length(time_window)
            
            t1                                  = abs(time_axis - time_window(ntime));
            t1                                  = find(t1==min(t1));
            
            t2                                  = abs(time_axis - (time_window(ntime)+time_width));
            t2                                  = find(t2==min(t2));
            
            act                                 = mean(sub_carr(:,t1:t2),2);
            
            t1                                  = find(round(time_axis,2) == round(-0.1,2));
            t2                                  = find(round(time_axis,2) == round(0,2));
            bsl                                 = mean(sub_carr(:,t1:t2),2);
            
            source                              = [];
            source.pos                          = template_grid.pos;
            source.dim                          = template_grid.dim;
            source.pow                          = nan(length(source.pos),1);
            indx                                = find(template_grid.inside ==1);
            
            source.pow(indx)                    = (act-bsl)./bsl;
            alldata{ns,ntime,nses}           	= source;
            
            clear act bsl t1 t2 source
            
        end
        
        clear sub_carr
        
    end
end

cfg                                             = [];
cfg.dim                                         = alldata{1}.dim;
cfg.method                                      = 'montecarlo';
cfg.statistic                                   = 'depsamplesT';
cfg.parameter                                   = 'pow';
cfg.correctm                                    = 'cluster';
cfg.clusteralpha                                = 0.05; % First Threshold
cfg.clusterstatistic                            = 'maxsum';
cfg.numrandomization                            = 1000;
cfg.alpha                                       = 0.025;
cfg.tail                                        = 0;
cfg.clustertail                                 = 0;

nsuj                                            = size(alldata,1);

cfg.design(1,:)                                 = [1:nsuj 1:nsuj];
cfg.design(2,:)                                 = [ones(1,nsuj) ones(1,nsuj)*2];
cfg.uvar                                        = 1;
cfg.ivar                                        = 2;

for ntime = 1:size(alldata,2)
    stat{ntime}                             = ft_sourcestatistics(cfg, alldata{:,ntime,1},alldata{:,ntime,2});
    [min_p(ntime),p_val{ntime}]             = h_pValSort(stat{ntime});
end

keep stat min_p p_val alldata

cfg                                             = [];
cfg.method                                      = 'surface';
cfg.funparameter                                = 'pow';
cfg.maskparameter                               = cfg.funparameter;
% cfg.funcolorlim                         = [-4 4];
cfg.funcolormap                                 = brewermap(256,'*RdBu');
% cfg.opacitylim                          = [0 1];
% cfg.opacitymap                          = 'rampup';
cfg.projmethod                                  = 'nearest';
cfg.camlight                                    = 'no';
cfg.surffile                                    = 'surface_white_both.mat';
cfg.surfinflated                                = 'surface_inflated_both.mat';

for ntime = 1:size(stat,1)
    
    plimit                                      = 0.3;
    s_focus                                     = stat{ntime};
    
    if min_p(ntime,nbs) < plimit
        
        s_focus.mask                            = s_focus.prob < plimit;
        
        source                                  = [];
        source.pow                              = s_focus.mask .* s_focus.stat;
        source.pow(source.pow ==0)              = NaN;
        
        source.pos                              = s_focus.pos;
        source.dim                              = s_focus.dim;
        source.inside                           = s_focus.inside;
        
        ft_sourceplot(cfg, source);
        view([0 82]);
    end
end