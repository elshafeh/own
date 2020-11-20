clear ;

suj_list    = [1:33 35:36 38:44 46:51];

for ns = 1:length(suj_list)
    
    suj_name                                    = ['sub' num2str(suj_list(ns))];
    
    for nback = [0 1 2]
        
        i                                     	= 0;
        
        for nsess = 1:2
            for nstim = 1:9
                
                fname                           = ['K:/nback/timegen/' suj_name '.sess' num2str(nsess) '.stim' num2str(nstim) '.' num2str(nback) 'back.dwn60.auc.timegen.mat'];
                
                if exist(fname)
                    i                               = i +1;
                    fprintf('Loading %s\n',fname);
                    load(fname);
                    
                    tmp(i,:,:)                  = scores; clear scores;
                end
                
            end
            
            pow(nback+1,:,:)                    = squeeze(mean(tmp,1));
            
        end
        
    end
    
    freq                                        = [];
    freq.dimord                                 = 'chan_freq_time';
    freq.label                                  = {'0 BACK','1 BACK','2 BACK'};
    freq.freq                                   = time_axis;
    freq.time                                   = time_axis;
    freq.powspctrm                              = pow ;
    
    alldata{ns,1}                               = freq; clear freq pow;
    
    
end

keep alldata

gavg                                        = ft_freqgrandaverage([],alldata{:,1});
i                                           = 0;
nrow                                        = 3;
ncol                                        = 1;


for nc = 1:length(gavg.label)
    
    cfg                                 = [];
    cfg.channel                         = gavg.label{nc};
    cfg.marker                          = 'off';
    cfg.comment                         = 'no';
    cfg.colormap                        = brewermap(256, '*RdBu');
    cfg.colorbar                        = 'yes';
    %     cfg.xlim                            = [];
    %     cfg.ylim                            = cfg.xlim;
    cfg.zlim                            = [0. 1];
    
    i                                   = i + 1;
    subplot(nrow,ncol,i)
    ft_singleplotTFR(cfg, gavg);
    title(gavg.label{nc});
    set(gca,'FontSize',16);
    
end
