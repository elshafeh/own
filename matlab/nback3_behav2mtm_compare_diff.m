clear;clc;

suj_list                          	= [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    dir_data                        = '~/Dropbox/project_me/data/nback/peak/';
    
    fname_in                    	= [dir_data 'sub' num2str(suj_list(nsuj)) '.alphabeta.peak.package.0back.equalhemi.mat'];
    fprintf('loading %s\n',fname_in);
    load(fname_in);
    
    allalphapeaks(nsuj,1)         	= apeak;
    allbetapeaks(nsuj,1)            = bpeak;
    
end

%%

for nsuj = 1:length(suj_list)
    
    list_behav                      = {'fast' 'slow'};
    list_band                       = {'alpha' 'beta'};
    
    data_sub                        = [];
    
    for nbehav = 1:2
        
        % load data
        pow                         = [];
        
        for nback = 1:2
            
            dir_data              	= '~/Dropbox/project_me/data/nback/tf/behav2tf/';
            fname_in              	= [dir_data 'sub' num2str(suj_list(nsuj)) '.' num2str(nback) 'back.target'];
            fname_in               	= [fname_in '.' list_behav{nbehav} '.mtm.mat'];
            fprintf('loading %s\n',fname_in);
            load(fname_in);
            pow(nback,:,:,:)     	= freq_comb.powspctrm;
            
        end
        
        % average over nback
        freq_comb.powpsctrm         = squeeze(mean(pow,1)); clear pow
        
        
        % center data around peaks
        for nband = 1:length(list_band)
            
            test_band      	= list_band{nband};
            
            switch test_band
                case 'alpha'
                    f_focus	= allalphapeaks(nsuj);
                    f_width	= 1;
                case 'beta'
                    f_focus	= allbetapeaks(nsuj);
                    f_width	= 2;
            end
            
            f1           	= nearest(freq_comb.freq,f_focus-f_width);
            f2            	= nearest(freq_comb.freq,f_focus+f_width);
            pow           	= squeeze(nanmean(freq_comb.powspctrm(:,f1:f2,:),2));
            
            data_sub(nband,nbehav,:,:,:)  = pow; clear pow;
            
            
        end
    end
    
    % normalize across bins
    for nband = [1 2]
        
        sub_pow          	= squeeze(data_sub(nband,:,:,:));
        bsl              	= squeeze(mean(sub_pow,1));
        
        for nbehav = [1 2]
            
            avg           	= [];
            avg.time      	= freq_comb.time;
            avg.label      	= freq_comb.label;
            avg.dimord    	= 'chan_time';
            avg.avg       	= squeeze(sub_pow(nbehav,:,:)) ./ bsl;
            tmp{nbehav} 	= avg; clear avg;
            
        end
        
        alldata{nsuj,nband}         = tmp{1};
        alldata{nsuj,nband}.avg     = tmp{1}.avg - tmp{2}.avg;
        
        
        clear sub_pow bsl
        
    end
    
end

%% 

keep alldata

nbsuj                                           = size(alldata,1);
[design,neighbours]                             = h_create_design_neighbours(nbsuj,alldata{1,1},'elekta','t');

cfg                                             = [];
cfg.latency                                     = [-1 2];
cfg.statistic                                   = 'ft_statfun_depsamplesT';
cfg.method                                      = 'montecarlo';
cfg.correctm                                    = 'cluster';
cfg.clusteralpha                                = 0.05;
cfg.clusterstatistic                            = 'maxsum';
cfg.minnbchan                                   = 3; % important %
cfg.tail                                        = 0;
cfg.clustertail                                 = 0;
cfg.alpha                                       = 0.025;
cfg.numrandomization                            = 1000;
cfg.uvar                                        = 1;
cfg.ivar                                        = 2;
cfg.neighbours                                  = neighbours;
cfg.design                                      = design;
stat{1}                                         = ft_timelockstatistics(cfg,alldata{:,1},alldata{:,2});
[min_p(1),p_val{1}]                             = h_pValSort(stat{1});clc;

%%

close all;

plimit                                          = 0.025;
nrow                                            = 2;
ncol                                            = 2;
i                                               = 0;

for nband = 1:length(stat)
    if min_p(nband) < plimit
                
        nw_data                                 = alldata;
        nw_stat                                 = stat{nband};
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
        cfg.zlim                                = [-3 3];
        cfg.colormap                            = brewermap(256,'*BuPu');
        cfg.marker                              = 'off';
        cfg.comment                             = 'no';
        cfg.colorbar                            = 'yes';
        cfg.colorbartext                        = 't-values';
        
        cfg.xlim                                = [-0.3 0.6];
        i = i + 1;
        cfg.figure                              = subplot(nrow,ncol,i);
        
        nwplot                                  = statplot;
        nwplot.avg(nwplot.avg > 0)              = NaN;
        ft_topoplotER(cfg,nwplot);
        title({['alpha vs beta '],['p = ' num2str(round(min_p(nband),3))]});
        
        set(gca,'FontSize',14,'FontName', 'Calibri','FontWeight','normal');
        
        cfg.xlim                                = [0.7 1];
        i = i + 1;
        cfg.figure                              = subplot(nrow,ncol,i);
        
        nwplot                                  = statplot;
        nwplot.avg(nwplot.avg < 0)              = NaN;
        ft_topoplotER(cfg,nwplot);
        title({['alpha vs beta '],['p = ' num2str(round(min_p(nband),3))]});
        
        set(gca,'FontSize',14,'FontName', 'Calibri','FontWeight','normal');
        
        find_sig_chan                           = mean(statplot.avg,2);
        find_sig_chan                           = find(find_sig_chan ~= 0);
        list_chan                               = nw_stat.label(find_sig_chan);
        
        list_chan                               = {'MEG1632+1633', 'MEG1842+1843', 'MEG1912+1913', ... 
            'MEG1942+1943', 'MEG2012+2013', 'MEG2042+2043'};
        
        cfg                                     = [];
        cfg.channel                             = list_chan;
        cfg.time_limit                          = nw_stat.time([1 end]);
        cfg.color                               = [109 179 177; 111 71 142];
        cfg.color                               = cfg.color ./ 256;

        cfg.z_limit                             = [-0.4 0.4];
        
        cfg.linewidth                           = 5;
        cfg.lineshape                           = '-r';
        
        i = i + 1;
        subplot(nrow,ncol,i)
        h_plotSingleERFstat_selectChannel_nobox(cfg,nw_stat,nw_data);
        
        legend({'alpha' '' 'beta' ''});
        
        xlim(statplot.time([1 end]));
        hline(0,'-k');
        vline(0,'-k');
        set(gca,'FontSize',14,'FontName', 'Calibri','FontWeight','normal');
        
    end
end

mask_mean                   = mean(nw_stat.mask,1);
mask_mean(mask_mean ~= 0)   = 1;
sig_time                    = mask_mean .* nw_stat.time;