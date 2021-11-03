clear;clc;

suj_list                                 	= [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    list_behav                              = {'fast.pre' 'slow.pre'};
    
    pow                                     = [];
    
    for nbehav = 1:2
        for nback = 1:2
            
            dir_data                      	= '~/Dropbox/project_me/data/nback/tf/behav2tf/';
            fname_in                       	= [dir_data 'sub' num2str(suj_list(nsuj)) '.' num2str(nback) 'back.target'];
            fname_in                    	= [fname_in '.' list_behav{nbehav} '.fft.mat'];
            
            fprintf('loading %s\n',fname_in);
            load(fname_in);
            
            pow(nback,:,:)            	= freq_comb.powspctrm;
            
        end

        data_sub(nbehav,:,:)            = squeeze(mean(pow,1)); clear pow;
        
    end
    
    for nbehav = [1 2]
        
        avg                             = [];
        avg.label                       = freq_comb.label;
        avg.time                        = freq_comb.freq;
        avg.avg                         = squeeze(data_sub(nbehav,:,:)) ./ squeeze(mean(data_sub,1));
        avg.dimord                      = 'chan_time';
        alldata{nsuj,nbehav}            = avg; clear avg;
        
    end
    
end

%%

keep alldata

nbsuj                                 	= size(alldata,1);
[design,neighbours]                  	= h_create_design_neighbours(nbsuj,alldata{1,1},'elekta','t');

cfg                                   	= [];
cfg.latency                          	= [1 35];
cfg.statistic                        	= 'ft_statfun_depsamplesT';
cfg.method                          	= 'montecarlo';
cfg.correctm                         	= 'cluster';
cfg.clusteralpha                      	= 0.05;
cfg.clusterstatistic                 	= 'maxsum';
cfg.minnbchan                        	= 2;
cfg.tail                             	= 0;
cfg.clustertail                       	= 0;
cfg.alpha                           	= 0.025;
cfg.numrandomization                    = 1000;
cfg.uvar                            	= 1;
cfg.ivar                            	= 2;
cfg.neighbours                          = neighbours;
cfg.design                            	= design;
stat                                	= ft_timelockstatistics(cfg,alldata{:,1},alldata{:,2});
[min_p,p_val]                        	= h_pValSort(stat);clc;

%%


plimit                               	= 0.2;
nrow                                	= 2;
ncol                                	= 2;
i                                       = 0;

if min_p < plimit
    
    for nsign = [-1]
        
        nw_data                  	= alldata;
        nw_stat                 	= stat;
        
        if nsign  == -1
            nw_stat.mask           	= nw_stat.prob < plimit & nw_stat.stat < 0;
        else
            nw_stat.mask           	= nw_stat.prob < plimit & nw_stat.stat > 0;
        end
        
        statplot                 	= [];
        statplot.avg            	= nw_stat.mask .* nw_stat.stat;
        statplot.label            	= nw_stat.label;
        statplot.dimord          	= nw_stat.dimord;
        statplot.time             	= nw_stat.time;
        
        find_sig_time           	= mean(statplot.avg,1);
        find_sig_time               = find(find_sig_time ~= 0);
        list_time                   = [min(statplot.time(find_sig_time)) max(statplot.time(find_sig_time))];
        
        cfg                     	= [];
        cfg.layout               	= 'neuromag306cmb_helmet.mat';
        cfg.xlim                  	= list_time;
        cfg.zlim                	= [-2 2];
        cfg.colormap            	= brewermap(256,'*RdBu');
        cfg.marker              	= 'off';
        cfg.comment               	= 'no';
        cfg.colorbar            	= 'no';
        
        i = i + 1;
        cfg.figure               	= subplot(nrow,ncol,i);
        ft_topoplotER(cfg,statplot);
        title(['p = ' num2str(round(min_p,3))]);
        
        set(gca,'FontSize',14,'FontName', 'Calibri','FontWeight','normal');
        
        find_sig_chan           	= mean(statplot.avg,2);
        find_sig_chan               = find(find_sig_chan ~= 0);
        list_chan                   = nw_stat.label(find_sig_chan);
        
        cfg                         = [];
        cfg.channel             	= list_chan;
        cfg.time_limit              = nw_stat.time([1 end]);
        cfg.color                	= [144 134 255; 196 39 96];
        cfg.color                	= cfg.color ./ 256;
        cfg.lineshape           	= '-k';
        
        val                         = 0.9;
        cfg.z_limit                 = [val 1+(1-val)];

        cfg.linewidth               = 10;
        i = i + 1;
        subplot(nrow,ncol,i)
        h_plotSingleERFstat_selectChannel_nobox(cfg,nw_stat,nw_data);
        
        hline(1,'-k');
        
        legend({'fast' '' 'slow' ''});
        
        xlim(statplot.time([1 end]));
        hline(0,'-k');
        vline(0,'-k');
                
        set(gca,'FontSize',16,'FontName', 'Calibri','FontWeight','normal');
        
    end
end