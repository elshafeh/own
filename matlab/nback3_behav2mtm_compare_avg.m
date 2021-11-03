clear;clc;

suj_list                          	= [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
        
    fname_in                    	= ['~/Dropbox/project_me/data/nback/peak/sub' num2str(suj_list(nsuj)) '.alphabeta.peak.package.0back.mat'];
    fprintf('loading %s\n',fname_in);
    load(fname_in);
    
    allbetapeaks(nsuj,1)            = bpeak;
    
end

mean_beta_peak                      = round(nanmedian(allbetapeaks));
allbetapeaks(isnan(allbetapeaks))   = mean_beta_peak;

%%

for nsuj = 1:length(suj_list)
    
    list_behav                      = {'fast' 'slow'};
    test_band                      	= 'beta';
    
    fname_in                    	= ['~/Dropbox/project_me/data/nback/peak/sub' num2str(suj_list(nsuj)) '.alphabeta.peak.package.0back.mat'];
    fprintf('loading %s\n',fname_in);
    load(fname_in);
    
    for nback = 1:2
        
        for nbehav = 1:2
        
            dir_data              	= '~/Dropbox/project_me/data/nback/tf/behav2tf/';
            fname_in               	= [dir_data 'sub' num2str(suj_list(nsuj)) '.' num2str(nback) 'back.target'];
            fname_in             	= [fname_in '.' list_behav{nbehav} '.mtm.mat'];
            fprintf('loading %s\n',fname_in);
            load(fname_in);
            
            switch test_band
                case 'theta'
                    f_focus        	= 4;
                    f_width       	= 1;
                case 'alpha'
                    f_focus       	= apeak;
                    f_width       	= 1;
                case 'beta'
                    f_focus        	= allbetapeaks(nsuj);
                    f_width        	= 2;
                case 'high-beta'
                    f_focus        	= 25;
                    f_width        	= 5;
                case 'gamma'
                    f_focus      	= 50;
                    f_width        	= 10;
            end
            
            f1                     	= find(round(freq_comb.freq) == round(f_focus-f_width));
            f2                    	= find(round(freq_comb.freq) == round(f_focus+f_width));
            pow                     = squeeze(nanmean(freq_comb.powspctrm(:,f1:f2,:),2));
            
            avg                 	= [];
            avg.time             	= freq_comb.time;
            avg.label            	= freq_comb.label;
            avg.dimord           	= 'chan_time';
            avg.avg             	= pow;
            alldata{nsuj,nback,nbehav}    = avg; clear avg pow f1 f2 f_*;
            
        end
    end
end

%%

keep alldata test_band

nbsuj                                       	= size(alldata,1);
[design,neighbours]                             = h_create_design_neighbours(nbsuj,alldata{1,1},'elekta','t');

for nback = 1:size(alldata,2)
    
    cfg                                         = [];
    cfg.latency                                 = [-0.5 0.5];
    cfg.statistic                               = 'ft_statfun_depsamplesT';
    cfg.method                                  = 'montecarlo';
    cfg.correctm                                = 'cluster';
    cfg.clusteralpha                            = 0.05;
    cfg.clusterstatistic                        = 'maxsum';
    cfg.minnbchan                               = 3; % important %
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

plimit                                          = 0.3;
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
            
        
        find_sig_time                           = mean(statplot.avg,1);
        find_sig_time                           = find(find_sig_time ~= 0);
        list_time                               = [min(statplot.time(find_sig_time)) max(statplot.time(find_sig_time))];
        
        cfg                                     = [];
        cfg.layout                              = 'neuromag306cmb.lay';
        cfg.xlim                                = list_time;
        cfg.zlim                                = [-2 2];
        cfg.colormap                            = brewermap(256,'*RdBu');
        cfg.marker                              = 'off';
        cfg.comment                             = 'no';
        cfg.colorbar                            = 'no';
        
        i = i + 1;
        subplot(nrow,ncol,i)
        ft_topoplotER(cfg,statplot);
        title({[num2str(nback) 'B good - bad'],['p = ' num2str(round(min_p(nback),3))]});
        
        set(gca,'FontSize',14,'FontName', 'Calibri','FontWeight','normal');
        
        find_sig_chan                           = mean(statplot.avg,2);
        find_sig_chan                           = find(find_sig_chan ~= 0);
        list_chan                               = nw_stat.label(find_sig_chan);
        
        cfg                                     = [];
        cfg.channel                             = list_chan;
        cfg.time_limit                          = nw_stat.time([1 end]);
        cfg.color                               = [109 179 177; 111 71 142];
        cfg.color                               = cfg.color ./ 256;
        
        if strcmp(test_band,'theta')
            cfg.z_limit                     	= [0 2e-23];
        elseif strcmp(test_band,'alpha')
            cfg.z_limit                     	= [0 2e-23];
        elseif strcmp(test_band,'beta')
            cfg.z_limit                     	= [0 1e-23];
        elseif strcmp(test_band,'high-beta')
            cfg.z_limit                     	= [0 0.3e-23];
        elseif strcmp(test_band,'gamma')
            cfg.z_limit                     	= [0.2e-24 0.9e-24];
        end
        
        cfg.linewidth                           = 10;
        i = i + 1;
        subplot(nrow,ncol,i)
        h_plotSingleERFstat_selectChannel_nobox(cfg,nw_stat,nw_data);
        
        legend({'good' '' 'bad' ''});
        
        xlim(statplot.time([1 end]));
        hline(0,'-k');
        vline(0,'-k');
        %         xticks([0 0.1 0.2 0.3 0.4 0.5]);
        set(gca,'FontSize',16,'FontName', 'Calibri','FontWeight','normal');
        
    end
end