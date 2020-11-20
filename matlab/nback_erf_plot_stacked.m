clear ; clc; close all;

i = 0;

for ns = [1:33 35:36 38:44 46:51]
    
    for nses = 1:2
        
        subjectname                	= ['s' num2str(ns)];
        fname                    	= ['../data/erf/data_sess' num2str(nses) '_' subjectname '_erfComb.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        tmp{nses}                   = avg_comb; clear avg_comb;
        
    end
    
    avg                             = ft_timelockgrandaverage([],tmp{:}); clear tmp;
    
    i                               = i+1;
    alldata{i}                      = avg; clear avg;
    
end

gavg                                = ft_timelockgrandaverage([],alldata{:});

keep gavg;

cfg                                 = [];
cfg.layout                          = 'neuromag306cmb.lay';
cfg.ylim                            = 'maxabs';
cfg.marker                          = 'off';
cfg.comment                         = 'no';
cfg.colormap                        = brewermap(256,'*RdBu');
cfg.colorbar                        = 'no';
cfg.xlim                            = [0.1 0.2];
ft_topoplotER(cfg, gavg);