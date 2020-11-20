clear ;

for nback = [0 1 2]
    
    i                                       = 0;
    alldata{nback+1}                        = {};
    
    for ns = [1:33 35:36 38:44 46:51]
        
        check_name                          = dir(['../data/tf/data_sess*s' num2str(ns) '_3stacked_' num2str(nback) 'back_freqComb.mat']);
        
        for nf = 1:length(check_name)
        
            fname                           = [check_name(nf).folder filesep check_name(nf).name];
            fprintf('loading %s\n',fname);
            load(fname);
            
            cfg                             = [];
            cfg.baseline                    = [-0.4 -0.2];
            cfg.baselinetype                = 'relchange';
            freq                            = ft_freqbaseline(cfg,freq_comb);
            
            load(['../data/peak/s' num2str(ns) '.max10chan.p50p200ms.postonset.mat']);
            
            cfg                             = [];
            %             cfg.latency                     = [-0.6 0];
            %             cfg.avgovertime                 = 'yes';
            cfg.channel                     = max_chan;
            cfg.avgoverchan                 = 'yes';
            freq                            = ft_selectdata(cfg,freq);
            
            freq.dimord                     = 'chan_freq';
            freq                            = rmfield(freq,'time');
            
            
            alldata{nback+1}{end+1}         = freq ; clear freq freq_comb;
            
        end
    end
end


keep alldata

for nback = 1:size(alldata,2)
    gavg{nback}                             = ft_freqgrandaverage([],alldata{nback}{:});
end

cfg                                         = [];
cfg.layout                                  = 'neuromag306cmb.lay';
cfg.marker                                  = 'off';
cfg.comment                                 = 'no';
cfg.colormap                                = brewermap(256, '*RdBu'); % PuBuGn % *RdYlBu

cfg.colorbar                                = 'no';
cfg.zlim                                    = 'maxabs'; % maxabs % minzero % zeromax

ft_topoplotTFR(cfg, gavg{:});