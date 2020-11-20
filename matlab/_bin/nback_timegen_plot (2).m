clear ;

suj_list                                    = dir('../data/decode/timegen/*.stim9.2back.decode.auc.mat');

for ns = 1:length(suj_list)
    
    suj_name                                = strsplit(suj_list(ns).name,'.');
    suj_name                                = suj_name{1};
    
    for nback = [0 1 2]
        for nstim = 1:9
            
            fname                           = ['../data/decode/timegen/' suj_name '.stim' num2str(nstim) '.' num2str(nback) 'back.decode.auc.mat'];
            fprintf('Loading %s\n',fname);
            load(fname);
            
            tmp(nstim,:,:)                  = scores; clear scores;
            
        end
        
        pow(nback+1,:,:)                    = squeeze(mean(tmp,1));
        
    end
    
    load timgen_time_axes.mat
    
    freq                                    = [];
    freq.dimord                             = 'chan_freq_time';
    freq.label                              = {'0 BACK','1 BACK','2 BACK'};
    freq.freq                               = time_axes;
    freq.time                               = time_axes;
    freq.powspctrm                          = pow ; clear pow;
    
    alldata{ns,1}                           = freq; clear freq;
    
end

keep alldata

gavg                                        = ft_freqgrandaverage([],alldata{:,1});
i                                           = 0;

list_time                                   = [0 2; 2 4; 4 6];

for nt = 1:3
    for nc = 1:length(gavg.label)
        
        nrow                                = 3;
        ncol                                = 3;
        
        
        cfg                                 = [];
        cfg.channel                         = gavg.label{nc};
        cfg.marker                          = 'off';
        cfg.comment                         = 'no';
        cfg.colormap                        = brewermap(256, '*Spectral');
        cfg.colorbar                        = 'yes';
        cfg.xlim                            = [list_time(nt,:)];
        cfg.ylim                            = cfg.xlim;
        cfg.zlim                            = [0.5 1];
        
        i                                   = i + 1;
        subplot(nrow,ncol,i)
        ft_singleplotTFR(cfg, gavg);
        title(gavg.label{nc});
        set(gca,'FontSize',16);
        
    end
    
    %     for nv = [2 4]
    %         vline(nv,'--y');
    %         hline(nv,'--y');
    %     end
    
end