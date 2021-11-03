clear;

suj_list                            = [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    fname_in                        = ['~/Dropbox/project_me/data/nback/peak/sub' num2str(suj_list(nsuj)) '.alphabeta.peak.package.0back.mat'];
    fprintf('loading %s\n',fname_in);
    load(fname_in);
    
    allalphapeaks(nsuj,1)           = apeak;
    allbetapeaks(nsuj,1)            = bpeak;
    
    allchan{nsuj}                   = max_chan;
    
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
    
    dir_data                        = '~/Dropbox/project_me/data/nback/singletrial/';
    fname_in                        = [dir_data 'sub' num2str(suj_list(nsuj)) '.singletrial.fft.mat'];
    fprintf('loading %s\n',fname_in);
    load(fname_in)
    
    flg_trials{1}                	= find(trialinfo(:,2) == 2);
    flg_trials{2}                 	= find(trialinfo(:,2) == 2 & rem(trialinfo(:,5),2) ~=0);
    
    list_behav                      = {'all trials' 'correct trials'};
    
    ext_band                        = 'beta';
    
    switch ext_band
        case 'alpha'
            f_focus                 = allalphapeaks(nsuj);
            f_width                 = 1;
        case 'beta'
            f_focus                 = allbetapeaks(nsuj);
            f_width                 = 2;
    end
    
    f1                              = nearest(freq_comb.freq,f_focus-f_width);
    f2                              = nearest(freq_comb.freq,f_focus+f_width);
    
    find_chan                       = [];
    for nchan = 1:length(allchan{nsuj})
        find_chan                   = [find_chan; find(strcmp(freq_comb.label,allchan{nsuj}{nchan}))];
    end
    
    for nbehav = [1 2]
        
        % select trials
        pow                         = nanmean(nanmean(nanmean(squeeze(freq_comb.powspctrm(flg_trials{nbehav},find_chan,f1:f2)))));
        allbehav(nsuj,nbehav)       = pow; clear pow;
        
        list_stim                   = [2 3 4 5 7 8 9];
        [auc,time_axis]             = h_auc(sujname,list_stim,flg_trials{nbehav});
        
        avg                         = [];
        avg.time                    = time_axis;
        avg.label                   = {'decoding stim'};
        avg.dimord                  = 'chan_time';
        avg.avg                     = auc; clear auc;
        
        alldata{nsuj,nbehav}        = avg; clear avg;
        
    end
end

keep all* list_*

%%

nbsuj                          	= size(alldata,1);
[~,neighbours]                	= h_create_design_neighbours(nbsuj,alldata{1,1},'gfp','t');

cfg                            	= [];
cfg.latency                    	= [-0.1 1];
cfg.method                   	= 'montecarlo';
cfg.statistic                	= 'ft_statfun_correlationT';
cfg.type                      	= 'Spearman';
cfg.clusterstatistics         	= 'maxsum';
cfg.correctm                   	= 'cluster';
cfg.clusteralpha              	= 0.05;
cfg.tail                      	= 0;
cfg.clustertail                	= 0;
cfg.alpha                     	= 0.025;
cfg.numrandomization         	= 1000;
cfg.neighbours                	= neighbours;
cfg.ivar                      	= 1;

for nbehav = 1:size(allbehav,2)
    
    cfg.design(1,1:nbsuj)      	= [allbehav(:,nbehav)];
    stat{nbehav}             	= ft_timelockstatistics(cfg, alldata{:,nbehav});
    [min_p(nbehav),p_val{nbehav}]	= h_pValSort(stat{nbehav});
    
end

%%

plimit                        	= 0.05;
nrow                         	= 1;
ncol                         	= 1;
i                             	= 0;

for nbehav = 1:length(stat)
    
    if min_p(nbehav) < plimit
        
        nw_data                 = squeeze(alldata(:,nbehav));
        nw_stat                 = stat{nbehav};
        nw_stat.mask            = nw_stat.prob < plimit;
        
        cfg                     = [];
        cfg.channel             = 1;
        cfg.time_limit          = nw_stat.time([1 end]);
        cfg.color               = [0 0 0];
        cfg.lineshape           = '-b';
        cfg.linewidth           = 10;
        cfg.z_limit             = [0.05 0.2];
        i = i + 1;
        subplot(nrow,ncol,i)
        h_plotSingleERFstat_selectChannel_nobox(cfg,nw_stat,nw_data);
        
        title({[list_behav{nbehav} ' with occipital fft'], ...
            ['p = ' num2str(round(min_p(nbehav),3))]});
        
        hline(0.06,'-k');
        vline(0,'-k');
        
        
        set(gca,'FontSize',16,'FontName', 'Calibri','FontWeight','normal');
        
    end
end
