clear;clc;

suj_list                                 	= [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    %     list_behav                              = {'fast.pre' 'slow.pre'};
    list_behav                              = {'fast.post' 'slow.post'};

    pow                                     = [];
    
    for nbehav = 1:2
        for nback = 1:2
            
            dir_data                      	= '~/Dropbox/project_me/data/nback/tf/behav2tf/';
            fname_in                       	= [dir_data 'sub' num2str(suj_list(nsuj)) '.' num2str(nback) 'back.target'];
            fname_in                    	= [fname_in '.' list_behav{nbehav} '.fft.mat'];
            
            fprintf('loading %s\n',fname_in);
            load(fname_in);
            
            pow(nback,:,:)                  = freq_comb.powspctrm;
            
        end
        
        avg                                 = [];
        avg.label                           = freq_comb.label;
        avg.time                            = freq_comb.freq;
        avg.avg                             = squeeze(mean(pow,1)); clear pow;
        avg.dimord                          = 'chan_time';
        
        alldata{nsuj,nbehav}                = avg; clear avg freq_comb;
        
        
    end
end

%%

keep alldata

nbsuj                                     	= size(alldata,1);
[design,neighbours]                     	= h_create_design_neighbours(nbsuj,alldata{1,1},'elekta','t');

cfg                                         = [];
cfg.latency                                 = [1 35];
cfg.statistic                               = 'ft_statfun_depsamplesT';
cfg.method                                  = 'montecarlo';
cfg.correctm                                = 'cluster';
cfg.clusteralpha                            = 0.05;
cfg.clusterstatistic                        = 'maxsum';
cfg.minnbchan                               = 3;
cfg.tail                                    = 0;
cfg.clustertail                             = 0;
cfg.alpha                                   = 0.025;
cfg.numrandomization                        = 1000;
cfg.uvar                                    = 1;
cfg.ivar                                    = 2;
cfg.neighbours                              = neighbours;
cfg.design                                  = design;
stat                                        = ft_timelockstatistics(cfg,alldata{:,1},alldata{:,2});
[min_p,p_val]                               = h_pValSort(stat);clc;

%%


plimit                                      = 0.15;
nrow                                     	= 2;
ncol                                    	= 2;
i                                           = 0;

if min_p < plimit
    
    nw_data                                 = alldata;
    nw_stat                                 = stat;
    nw_stat.mask                            = nw_stat.prob < plimit;
    
    statplot                                = [];
    statplot.avg                            = nw_stat.mask .* nw_stat.stat;
    statplot.label                          = nw_stat.label;
    statplot.dimord                         = nw_stat.dimord;
    statplot.time                           = nw_stat.time;
    
    find_sig_time                           = mean(statplot.avg,1);
    find_sig_time                           = find(find_sig_time ~= 0);
    list_time                               = [min(statplot.time(find_sig_time)) max(statplot.time(find_sig_time))];
    
    
    cfg                                     = [];
    cfg.layout                              = 'neuromag306cmb.lay';
    cfg.zlim                                = [-2 2];
    cfg.xlim                                = list_time;
    cfg.colormap                            = brewermap(256,'*RdBu');
    cfg.marker                              = 'off';
    cfg.comment                             = 'no';
    cfg.colorbar                            = 'no';
    
    i = i + 1;
    subplot(nrow,ncol,i)
    ft_topoplotER(cfg,statplot);
    title({['Fast - Slow'],['p = ' num2str(round(min_p,3))]});
    
    set(gca,'FontSize',14,'FontName', 'Calibri','FontWeight','normal');
    
    find_sig_chan                           = mean(statplot.avg,2);
    find_sig_chan                           = find(find_sig_chan ~= 0);
    list_chan                               = nw_stat.label(find_sig_chan);
    
    cfg                                     = [];
    cfg.channel                             = list_chan;
    cfg.time_limit                          = nw_stat.time([1 end]);
    cfg.color                               = [109 179 177; 111 71 142];
    cfg.color                               = cfg.color ./ 256;
    cfg.z_limit                             = [0 1e-23];
    
    cfg.linewidth                           = 5;
    cfg.lineshape                         	= '-r';
    
    i = i + 1;
    subplot(nrow,ncol,i)
    h_plotSingleERFstat_selectChannel_nobox(cfg,nw_stat,nw_data);
    legend({'fast' '' 'slow' ''});
    
    xlim(statplot.time([1 end]));

    set(gca,'FontSize',16,'FontName', 'Calibri','FontWeight','normal');
    
end

