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
    
    allalphapeaks(nsuj,1)         	= apeak;
    allbetapeaks(nsuj,1)        	= bpeak;
    
    allchan{nsuj,1}             	= max_chan;
    
end

mean_beta_peak                     	= round(nanmedian(allbetapeaks));
allbetapeaks(isnan(allbetapeaks))  	= mean_beta_peak;


keep all* suj_list

for nsuj = 1:length(suj_list)
    
    list_cond                       = {'first.pre' 'target.pre' 'first.post' 'target.post'}; %
    test_band                       = 'alpha';
    
    for ncond = 1:length(list_cond)
        
        dir_data                    = '~/Dropbox/project_me/data/nback/corr/fft/';
        fname_in                    = [dir_data 'sub' num2str(suj_list(nsuj)) '.allback.allbehav.' list_cond{ncond} '.fft.mat'];
        
        fprintf('loading %s\n',fname_in);
        load(fname_in);
        
        f1                          = nearest(freq_comb.freq,1);
        f2                          = nearest(freq_comb.freq,30);
        freq_comb.powspctrm         = freq_comb.powspctrm(:,f1:f2);
        freq_comb.freq              = freq_comb.freq(f1:f2);
        
        pow                         = freq_comb.powspctrm;
        pow                         = pow ./ nanmean(pow,1);
        
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
        
        avg                         = [];
        avg.label                   = freq_comb.label;
        avg.time                    = 10;
        avg.avg                     = mean(freq_comb.powspctrm(:,f1:f2),2);
        avg.dimord                  = 'chan_time';
        
        alldata{nsuj,ncond}         = avg; clear avg freq_comb;
        
    end
end

keep all* list*

%%

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
cfg.minnbchan                       = 3;
cfg.neighbours                      = neighbours;
cfg.ivar                            = 1;

for nbehav = 1:size(allbehav,2)
    for ncond = 1:size(alldata,2)
        
        cfg.design(1,1:nbsuj)       = [allbehav(:,nbehav)];
        stat{nbehav,ncond}       	= ft_timelockstatistics(cfg, alldata{:,ncond});
        [min_p(nbehav,ncond),p_val{nbehav,ncond}]	= h_pValSort(stat{nbehav,ncond});
        
    end
end

%%

plimit                              = 0.05;
nrow                                = 2;
ncol                                = 2;
i                                   = 0;

list_behav                          = {'Accuracy' 'Reaction time'};

for nbehav = 1:size(stat,1)
    for ncond = 1:size(stat,2)
        
        if min_p(nbehav,ncond) < plimit
            
            nw_data                 = squeeze(alldata(:,ncond));
            nw_stat                 = stat{nbehav,ncond};
            nw_stat.mask            = nw_stat.prob < plimit;
            
            statplot                = [];
            statplot.avg            = nw_stat.mask .* nw_stat.rho;
            statplot.label          = nw_stat.label;
            statplot.dimord         = 'chan_time';
            statplot.time           = nw_stat.time;
            
            cfg                     = [];
            cfg.layout              = 'neuromag306cmb.lay';
            cfg.zlim                = [-0.2 0.2];
            cfg.colormap            = brewermap(256,'*RdBu');
            cfg.marker              = 'off';
            cfg.comment             = 'no';
            cfg.colorbar            = 'no';
            
            i = i + 1;
            cfg.figure              = subplot(nrow,ncol,i);
            
            
            ft_topoplotER(cfg,statplot);
            title({[list_behav{nbehav} ' with ' list_cond{ncond} ' fft'], ...
                ['p = ' num2str(round(min_p(nbehav,ncond),3))]});
            
            set(gca,'FontSize',16,'FontName', 'Calibri','FontWeight','normal');
            
        end
    end
end