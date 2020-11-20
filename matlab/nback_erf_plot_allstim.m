clear ;

i                           = 0;

for nsess = 1:2
    
    for ns = [1:33 35:36 38:44 46:51]
        
        fname               = ['../data/erf/data_sess' num2str(nsess) '_s' num2str(ns) '_erfComb.mat'];
        fprintf('\nloading %s',fname);
        load(fname);
        
        i                   = i+1;
        alldata{i}          = avg_comb; clear avg_comb;
        
    end
    
end

gavg                        = ft_timelockgrandaverage([],alldata{:});


cfg                         = [];
cfg.layout                  = 'neuromag306cmb.lay';
cfg.ylim                    = 'maxabs';
cfg.marker                  = 'off';
cfg.comment                 = 'no';
cfg.colormap                = brewermap(256,'*RdBu');
cfg.colorbar                = 'no';
cfg.xlim                    = [0.1 0.2];

ft_topoplotER(cfg, gavg);
