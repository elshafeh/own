clear ;

for nc = 1:3
    
    list_cond                   = {'0back','1back','2back'};
    i                           = 0;
    alldata                     = {};
    
    for nsess = 1:2
        for ns = [1:33 35:36 38:44 46:51]
            
            fname               = ['../data/erf/data_sess' num2str(nsess) '_s' num2str(ns) '_3stacked_' list_cond{nc} '_erfComb.mat'];
            
            if exist(fname)
                
                fprintf('\nloading %s',fname);
                load(fname);
                
                i                   = i+1;
                alldata{i}          = avg_comb; clear avg_comb;
                
            end
            
        end
    end
    
    gavg{nc}                        = ft_timelockgrandaverage([],alldata{:});
    
end

keep gavg;

cfg                                 = [];
cfg.layout                          = 'neuromag306cmb.lay';
cfg.ylim                            = 'maxabs';
cfg.marker                          = 'off';
cfg.comment                         = 'no';
cfg.colormap                        = brewermap(256,'*RdBu');
cfg.colorbar                        = 'no';
cfg.xlim                            = [0.1 0.2];
ft_topoplotER(cfg, gavg{:});
