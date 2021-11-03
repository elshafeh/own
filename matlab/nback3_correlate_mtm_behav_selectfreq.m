clear;clc;

allbehav                            = [];

for nsuj = [1:33 35:36 38:44 46:51]
    
    dir_data                        = '~/Dropbox/project_me/data/nback/singletrial/';
    fname_in                        = [ dir_data 'sub' num2str(nsuj) '.singletrial.trialinfo.mat'];
    fprintf('loading %s\n',fname_in);
    load(fname_in)
    
    correct_trials                  = find(rem(trialinfo(:,4),2) ~= 0);
    perc_correct                    = length(correct_trials) ./ length(trialinfo);
    
    correct_trials_with_rt          = find(rem(trialinfo(:,4),2) ~= 0 & trialinfo(:,5) ~= 0);
    rt_vector                       = trialinfo(correct_trials_with_rt,5) ./ 1000;
    rt_vector                       = rt_vector/mean(rt_vector);
    mean_rt                         = mean(rt_vector);
    
    allbehav                        = [allbehav;perc_correct mean_rt];
    
end

keep allbehav

suj_list                            = [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
        
    fname_in                    	= ['~/Dropbox/project_me/data/nback/peak/sub' num2str(suj_list(nsuj)) '.alphabeta.peak.package.0back.mat'];
    fprintf('loading %s\n',fname_in);
    load(fname_in);
    
    allalphapeaks(nsuj,1)        	= apeak;
    allbetapeaks(nsuj,1)            = bpeak;
    
end

mean_beta_peak                      = round(nanmedian(allbetapeaks));
allbetapeaks(isnan(allbetapeaks))   = mean_beta_peak;

keep all* suj_list

for nsuj = 1:length(suj_list)
    
    ext_stim                        = 'target';
    baseline_correct                = 'freq'; % zero time freq
    
    freq_bounds                     = [1 40];
    time_bounds                     = [-1 1];
    
    % load in 0back data for baseline correction
    dir_data                        = '~/Dropbox/project_me/data/nback/0back/mtm/';
    fname_in                        = [dir_data 'sub' num2str(suj_list(nsuj)) '.0back.avgtrial.mtm.mat'];
    fprintf('loading %s\n',fname_in);
    load(fname_in);
    % restrict frequency
    freq_comb                       = h_selectfreq(freq_comb,freq_bounds,time_bounds);
    
    % select baseline period
    t1                              = nearest(freq_comb.time,-0.4);
    t2                              = nearest(freq_comb.time,-0.2);
    zero_bsl                        = nanmean(freq_comb.powspctrm(:,:,t1:t2),3); clear freq_comb;
    
    % load in data of interest
    dir_data                        = '~/Dropbox/project_me/data/nback/corr/mtm/';
    fname_in                        = [dir_data 'sub' num2str(suj_list(nsuj)) '.allback.allbehav.' ext_stim '.mtm.mat'];
    fprintf('loading %s\n',fname_in);
    load(fname_in);
    % restrict frequency
    freq_comb                       = h_selectfreq(freq_comb,freq_bounds,time_bounds);
    
    if strcmp(baseline_correct,'freq')
        % normalize per frequency
        freq_comb.powspctrm       	= freq_comb.powspctrm ./ nanmean(freq_comb.powspctrm,2);
    elseif strcmp(baseline_correct,'time')
        % normalize per time
        freq_comb.powspctrm       	= freq_comb.powspctrm ./ nanmean(freq_comb.powspctrm,3);
    elseif strcmp(baseline_correct,'zero')
        freq_comb.powspctrm        	= freq_comb.powspctrm ./ zero_bsl;
    end
    
    list_band                       = {'alpha' 'beta'};
    
    for nband = 1:length(list_band)
        
        test_band                   = list_band{nband};
        
        switch test_band
            case 'alpha'
                f_focus             = allalphapeaks(nsuj);
                f_width             = 1;
            case 'beta'
                f_focus             = allbetapeaks(nsuj);
                f_width             = 2;
        end
        
        f1                          = nearest(freq_comb.freq,round(f_focus-f_width));
        f2                          = nearest(freq_comb.freq,round(f_focus+f_width));
        
        pow                         = squeeze(nanmean(freq_comb.powspctrm(:,f1:f2,:),2));
        
        avg                         = [];
        avg.time                    = freq_comb.time;
        avg.label                   = freq_comb.label;
        avg.dimord                  = 'chan_time';
        avg.avg                     = pow;
        
        alldata{nsuj,nband}         = avg; clear avg;
        
    end
    
    clear freq_comb
    
end

%%

keep alldata allbehav list_* ext_*

nbsuj                               = size(alldata,1);
[~,neighbours]                      = h_create_design_neighbours(nbsuj,alldata{1,1},'elekta','t');

cfg                                 = [];
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
cfg.minnbchan                       = 2;
cfg.neighbours                      = neighbours;
cfg.ivar                            = 1;

for nbehav = 1:size(allbehav,2)
    for nband = 1:size(alldata,2)
        
        cfg.design(1,1:nbsuj)       = [allbehav(:,nbehav)];
        stat{nbehav,nband}       	= ft_timelockstatistics(cfg, alldata{:,nband});
        [min_p(nbehav,nband),p_val{nbehav,nband}]	= h_pValSort(stat{nbehav,nband});
        
    end
end

%%

plimit                              = 0.15;
nrow                                = 2;
ncol                                = 2;
i                                   = 0;

list_behav                          = {'accuracy' 'reaction time'};

for nbehav = 1:size(stat,1)
    for nband = 1:size(stat,2)
        
        if min_p(nbehav,nband) < plimit
            
            nw_data                 = squeeze(alldata(:,nband));
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
            title({[ext_stim],[list_behav{nbehav} ' with ' list_band{nband}], ...
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
            cfg.z_limit             = [-3 3];

            i = i + 1;
            subplot(nrow,ncol,i)
            h_plotSingleERFstat_selectChannel_nobox(cfg,nw_stat,nw_data);
            
            hline(0,'-k');
            vline(0,'-k');
            set(gca,'FontSize',16,'FontName', 'Calibri','FontWeight','normal');
            
        end
    end
end