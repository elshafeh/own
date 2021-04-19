clear;clc;

suj_list                                    = [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    list_behav                              = {'fast' 'slow'};
    
    for nback = 1:2
        for nbehav = 1:2
            
            dir_data                        = '~/Dropbox/project_me/data/nback/erf/behav2erf/';
            fname_in                        = [dir_data 'sub' num2str(suj_list(nsuj)) '.' num2str(nback) 'back.target'];
            fname_in                        = [fname_in '.' list_behav{nbehav} '.erfComb.mat'];
            
            try
                fprintf('loading %s\n',fname_in);
                load(fname_in,'avg_comb');
                
                t1                          = nearest(avg_comb.time,-0.1);
                t2                          = nearest(avg_comb.time,0);
                bsl                         = mean(avg_comb.avg(:,t1:t2),2);
                avg_comb.avg                = avg_comb.avg - bsl ; clear bsl t1 t2;
                
                alldata{nsuj,nback,nbehav}  = avg_comb; clear avg_comb;
                
            catch
                
                alldata{nsuj,nback,nbehav}  = [];
                
            end
            
        end
    end
    
end

keep alldata

bad_suj                                         = [];

for nsuj = 1:size(alldata,1)
    for nback = 1:size(alldata,2)
        for nbehav = 1:size(alldata,3)
            if isempty(alldata{nsuj,nback,nbehav})
                bad_suj = [bad_suj;nsuj];
            end
        end
    end
end

bad_suj                                         = unique(bad_suj);
alldata(bad_suj,:,:)                            = [];

%%

keep alldata

nbsuj                                       	= size(alldata,1);
[design,neighbours]                             = h_create_design_neighbours(nbsuj,alldata{1,1},'elekta','t');

for nback = 1:size(alldata,2)
    
    cfg                                         = [];
    cfg.latency                                 = [-0.01 0.5];
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
    stat{nback}                               	= ft_timelockstatistics(cfg,alldata{:,nback,1},alldata{:,nback,2});
    [min_p(nback),p_val{nback}]               	= h_pValSort(stat{nback});clc;
    
end

%%

close all;

plimit                                          = 0.15;
nrow                                            = 2;
ncol                                            = 2;
i                                               = 0;

for nback = 1:length(stat)
    if min_p(nback) < plimit
        
        nw_data                                 = squeeze(alldata(:,nback,:));
        nw_stat                                 = stat{nback};
        nw_stat.mask                            = nw_stat.prob < plimit;
        
        statplot                                = [];
        statplot.avg                            = nw_stat.mask .* nw_stat.stat;
        statplot.label                          = nw_stat.label;
        statplot.dimord                         = nw_stat.dimord;
        statplot.time                           = nw_stat.time;
            
        cfg                                     = [];
        cfg.layout                              = 'neuromag306cmb.lay';
        cfg.zlim                                = [-2 2];
        %         cfg.xlim                        = [0.1 0.15];
        cfg.colormap                            = brewermap(256,'*RdBu');
        cfg.marker                              = 'off';
        cfg.comment                             = 'no';
        cfg.colorbar                            = 'no';
        
        i = i + 1;
        subplot(nrow,ncol,i)
        ft_topoplotER(cfg,statplot);
        title({[num2str(nback) 'B good - bad'],['p = ' num2str(round(min_p(nback),3))]});
        
        set(gca,'FontSize',14,'FontName', 'Calibri','FontWeight','normal');
        
        if nback == 1
            list_chan                           = {'MEG2112+2113', 'MEG2332+2333'};
        else
            list_chan                           = {'MEG0212+0213', 'MEG0222+0223'};
        end

        
        list_chan                               = nw_stat.label;
        
        cfg                                     = [];
        cfg.channel                             = list_chan;
        cfg.time_limit                          = nw_stat.time([1 end]);
        cfg.color                               = [109 179 177; 111 71 142];
        cfg.color                               = cfg.color ./ 256;
        cfg.z_limit                             = [-0.5e-12 5.5e-12];
        cfg.linewidth                           = 10;
        i = i + 1;
        subplot(nrow,ncol,i)
        h_plotSingleERFstat_selectChannel_nobox(cfg,nw_stat,nw_data);
        
        legend({'good' '' 'bad' ''});
        
        xlim(statplot.time([1 end]));
        hline(0,'-k');
        vline(0,'-k');
        xticks([0 0.1 0.2 0.3 0.4 0.5]);
        set(gca,'FontSize',16,'FontName', 'Calibri','FontWeight','normal');
        
    end
end
