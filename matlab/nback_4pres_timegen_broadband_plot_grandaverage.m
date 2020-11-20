clear ; close all;

suj_list    = [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    suj_name                                    = ['sub' num2str(suj_list(nsuj))];
    list_lock                                   = {'target'};
    
    for nback = [0 1 2]
        for nlock = 1:length(list_lock)
            
            i                                   = 0;
            
            for nsess = 1:2
                
                ext_lock                        = list_lock{nlock};
                fname                           = ['J:/temp/nback/data/timegen_per_target/' suj_name '.sess' num2str(nsess) ...
                    '.' num2str(nback) 'back.dwn70.excl.' ext_lock '.auc.timegen.mat'];
                
                if exist(fname)
                    i                        	= i +1;
                    fprintf('Loading %s\n',fname);
                    load(fname);
                    tmp(i,:,:)                  = scores; clear scores;
                end
            end
            
            pow(nlock,:,:)                      = squeeze(mean(tmp,1)); clear tmp;
        end
        
        freq                                  	= [];
        freq.dimord                          	= 'chan_freq_time';
        freq.label                            	= list_lock;
        freq.freq                              	= time_axis;
        freq.time                             	= time_axis;
        freq.powspctrm                         	= pow;
        
        alldata{nsuj,nback+1}                  = freq; clear pow ;
        
    end
end

keep alldata ns pow time_axis ext_lock

i                                         	= 0;
nrow                                    	= 2;
ncol                                     	= 3;

plimit                                      = 0.05;

for ncond = 1:size(alldata,2)
    
    gavg                                    = ft_freqgrandaverage([],alldata{:,ncond});
    
    for nchan = 1:length(gavg.label)
        
        cfg                          	= [];
        cfg.colormap                	= brewermap(256, '*RdBu');
        cfg.channel                 	= nchan;
        cfg.parameter               	= 'powspctrm';
        cfg.zlim                      	= [0 1];
        cfg.colorbar                  	='yes';
        
        i = i +1;
        subplot(nrow,ncol,i)
        ft_singleplotTFR(cfg,gavg);
        
        title([gavg.label '  broadband']);
        
        c = colorbar;
        c.Ticks = cfg.zlim;
        
        ylabel('Training Time');
        xlabel('Testing Time');
        
        ylim([-0.5 2]);
        xlim([-0.5 2]);
        
        xticks([-0.5 0 0.5 1 1.5 2]);
        yticks([-0.5 0 0.5 1 1.5 2]);
        
        vline(0,'-k');
        hline(0,'-k');
        
        set(gca,'FontSize',10,'FontName', 'Calibri','FontWeight','normal');
        
        
    end
end