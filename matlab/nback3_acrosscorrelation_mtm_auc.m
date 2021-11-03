clear;

suj_list                            = [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    fname_in                        = ['~/Dropbox/project_me/data/nback/peak/sub' num2str(suj_list(nsuj)) '.alphabeta.peak.package.0back.mat'];
    fprintf('loading %s\n',fname_in);
    load(fname_in);
    
    allalphapeaks(nsuj,1)           = apeak;
    allbetapeaks(nsuj,1)            = bpeak;
    
end

mean_beta_peak                      = round(nanmean(allbetapeaks));
allbetapeaks(isnan(allbetapeaks))               = mean_beta_peak;

keep suj_list all* list* ; clc;

for nsuj = 1:length(suj_list)
    
    dir_data                        = '~/Dropbox/project_me/data/nback/singletrial/';
    sujname                         = ['sub' num2str(suj_list(nsuj))];
    
    
    fname_in                        = [dir_data sujname '.singletrial.trialinfo.mat'];
    fprintf('loading %s\n',fname_in);
    load(fname_in);
    
    fname_in                        = [dir_data sujname '.singletrial.mtm.mat'];
    fprintf('loading %s\n',fname_in);
    load(fname_in)
    
    flg_trials{1}                	= find(trialinfo(:,2) == 2);
    flg_trials{2}                 	= find(trialinfo(:,2) == 2 & rem(trialinfo(:,5),2) ~=0);
    
    list_band                       = {'alpha' 'beta'};
    list_behav                      = {'all trials' 'correct trials'};
    
    for nbehav = [1 2]
        for nband = [1 2]
            
            ext_band                = list_band{nband};
            
            switch ext_band
                case 'alpha'
                    f_focus     	= allalphapeaks(nsuj);
                    f_width     	= 1;
                case 'beta'
                    f_focus       	= allbetapeaks(nsuj);
                    f_width      	= 2;
            end
            
            f1                    	= nearest(freq_comb.freq,f_focus-f_width);
            f2                   	= nearest(freq_comb.freq,f_focus+f_width);
            
            % select trials
            pow                     = squeeze(nanmean(freq_comb.powspctrm(flg_trials{nbehav},:,f1:f2,:),3));
            % normalize
            pow                   	= pow ./ mean(pow,1);
            
            avg                   	= [];
            avg.time            	= freq_comb.time;
            avg.label            	= freq_comb.label;
            avg.dimord          	= 'chan_time';
            avg.avg              	= squeeze(mean(pow,1)); clear pow;
            
            alldata{nsuj,nband,nbehav}  = avg; clear avg;
            
            
            
        end
        
        list_stim                	= [2 3 4 5 7 8 9];
        
        [auc,time_axis]             = h_auc(sujname,list_stim,flg_trials{nbehav});
        t1                          = nearest(time_axis,0.2);
        t2                          = nearest(time_axis,0.4);
        
        allbehav(nsuj,nbehav)       = mean(auc(:,t1:t2));
        
    end
end

keep all* list_*

%%

nbsuj                               = size(alldata,1);
[~,neighbours]                      = h_create_design_neighbours(nbsuj,alldata{1,1},'elekta','t');

cfg                                 = [];
cfg.latency                         = [-1 0.5];
cfg.method                          = 'montecarlo';
cfg.statistic                       = 'ft_statfun_correlationT';
cfg.type                            = 'Pearson';
cfg.clusterstatistics               = 'maxsum';
cfg.correctm                        = 'cluster';
cfg.clusteralpha                    = 0.05;
cfg.tail                            = 0;
cfg.clustertail                     = 0;
cfg.alpha                           = 0.025;
cfg.numrandomization                = 1000;
cfg.minnbchan                       = 3;
cfg.neighbours                      = neighbours;
cfg.ivar                            = 1;

for nbehav = 1:size(allbehav,2)
    for nband = 1:size(alldata,2)
        
        cfg.design(1,1:nbsuj)       = [allbehav(:,nbehav)];
        stat{nbehav,nband}       	= ft_timelockstatistics(cfg, alldata{:,nband,nbehav});
        [min_p(nbehav,nband),p_val{nbehav,nband}]	= h_pValSort(stat{nbehav,nband});
        
    end
end

%%

plimit                              = 0.05;
nrow                                = 2;
ncol                                = 2;
i                                   = 0;

for nbehav = 1:size(stat,1)
    for nband = 1:size(stat,2)
        
        if min_p(nbehav,nband) < plimit
            
            nw_data                 = squeeze(alldata(:,nband,nbehav));
            nw_stat                 = stat{nbehav,nband};
            nw_stat.mask            = nw_stat.prob < plimit;
            
            statplot                = [];
            statplot.avg            = nw_stat.mask .* nw_stat.rho;
            statplot.label          = nw_stat.label;
            statplot.dimord         = nw_stat.dimord;
            statplot.time           = nw_stat.time;
            
            find_sig_time           = mean(statplot.avg,1);
            find_sig_time           = find(find_sig_time ~= 0);
            list_time               = [min(statplot.time(find_sig_time)) max(statplot.time(find_sig_time))];
            
            cfg                     = [];
            cfg.layout              = 'neuromag306cmb_helmet.mat';
            cfg.xlim                = list_time;
            cfg.zlim                = [-0.2 0.2];
            cfg.colormap            = brewermap(256,'*RdBu');
            cfg.marker              = 'off';
            cfg.comment             = 'no';
            cfg.colorbar            = 'no';
            
            i = i + 1;
            cfg.figure              = subplot(nrow,ncol,i);
            
            ft_topoplotER(cfg,statplot);
            title({[list_behav{nbehav} ' with ' list_band{nband}], ...
                ['p = ' num2str(round(min_p(nbehav,nband),3))]});
            
            set(gca,'FontSize',16,'FontName', 'Calibri','FontWeight','normal');
            
            find_sig_chan           = mean(statplot.avg,2);
            find_sig_chan           = find(find_sig_chan ~= 0);
            list_chan               = nw_stat.label(find_sig_chan);
            
            cfg                     = [];
            cfg.channel             = list_chan;
            cfg.time_limit          = nw_stat.time([1 end]);
            cfg.color               = [0 0 0];
            cfg.lineshape           = '-k';
            cfg.linewidth           = 10;
            
            test_band             	= list_band{nband};
            %             cfg.z_limit             = [-3 3];

            i = i + 1;
            subplot(nrow,ncol,i)
            h_plotSingleERFstat_selectChannel_nobox(cfg,nw_stat,nw_data);
            
            hline(0,'-k');
            vline(0,'-k');
            set(gca,'FontSize',16,'FontName', 'Calibri','FontWeight','normal');
            
        end
    end
end