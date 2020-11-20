clear ; close all; global ft_default
ft_default.spmversion = 'spm12';

load suj_list_peak.mat

for nsuj = 1:length(suj_list)
    
    subjectname                                     = ['sub' num2str(suj_list(nsuj))];
    list_time                                       = {'m700m200','p300p800','p1300p1800','p2300p2800','p3300p3800','p4300p4800'};
    
    load('../data/template/template_grid_1cm.mat');
    
    for nsession = 1:2
        
        for ntime = 1:length(list_time)
            
            fname                                   = dir(['../data/source/alpha/' subjectname '.session' num2str(nsession) '.allback.*.' list_time{ntime} '.dics.mat']);
            fprintf('loading %s\n',fname.name);
            load([fname.folder filesep fname.name]);
            
            source.pos                              = template_grid.pos;
            
            if ntime == 1 % bsl
                bsl                                 = source.pow;
            else
                source.pow                          = (source.pow - bsl) ./ bsl; % source.pow ./ source.noise; % 
                alldata{nsuj,nsession,ntime-1}      = source;
            end
            
            clear source
            
        end
    end
    
    list_time                                       = list_time(2:end);
    
end

keep alldata list_time;

for ntime = 1:size(alldata,3)
    gavg{ntime}                                     = ft_sourcegrandaverage([],alldata{:,:,ntime});
end

keep alldata gavg list_time;

cfg                                                  = [];
cfg.method                                           = 'surface';
cfg.funparameter                                     = 'pow';
cfg.funcolorlim                                      = [-0.5 0.5];
cfg.opacitylim                                       = cfg.funcolorlim;
cfg.opacitymap                                       = 'rampup';
cfg.colorbar                                         = 'off';
cfg.camlight                                         = 'no';
cfg.projmethod                                       = 'nearest';
cfg.surffile                                         = 'surface_white_both.mat';
cfg.surfinflated                                     = 'surface_inflated_both_caret.mat';
cfg.projthresh                                       = 0.4;

for ntime = 1:length(gavg)
    ft_sourceplot(cfg, gavg{ntime});
    view([-2 4]);
    title(list_time{ntime});
end