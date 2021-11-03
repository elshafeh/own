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
    
    for ncond = 1:length(list_cond)
        
        dir_data                    = '~/Dropbox/project_me/data/nback/corr/fft/';
        fname_in                    = [dir_data 'sub' num2str(suj_list(nsuj)) '.allback.allbehav.' list_cond{ncond} '.fft.mat'];
        
        fprintf('loading %s\n',fname_in);
        load(fname_in);
        
        pow                         = freq_comb.powspctrm;
        pow                         = pow ./ nanmean(pow,1);
        
        find_chan               	= [];
        for nchan = 1:length(allchan{nsuj})
            find_chan           	= [find_chan; find(strcmp(freq_comb.label,allchan{nsuj}{nchan}))];
        end
        
        avg                         = [];
        avg.label                   = {'fft avg'};
        avg.time                    = freq_comb.freq;
        avg.avg                     = mean(freq_comb.powspctrm(find_chan,:),1);
        avg.dimord                  = 'chan_time';
        
        alldata{nsuj,ncond}         = avg; clear avg freq_comb;
        
    end
end

keep all* list*

%%

nbsuj                               = size(alldata,1);
[~,neighbours]                      = h_create_design_neighbours(nbsuj,alldata{1,1},'fgp','t');

cfg                                 = [];
cfg.method                          = 'montecarlo';
cfg.latency                         = [1 30];
cfg.statistic                       = 'ft_statfun_correlationT';
cfg.type                            = 'Pearson';
cfg.clusterstatistics               = 'maxsum';
cfg.correctm                        = 'cluster';
cfg.clusteralpha                    = 0.05;
cfg.tail                            = 0;
cfg.clustertail                     = 0;
cfg.alpha                           = 0.025;
cfg.numrandomization                = 1000;
cfg.ivar                            = 1;

for nbehav = 1:size(allbehav,2)
    for ncond = 1:size(alldata,2)
        
        cfg.design(1,1:nbsuj)       = [allbehav(:,nbehav)];
        stat{nbehav,ncond}       	= ft_timelockstatistics(cfg, alldata{:,ncond});
        [min_p(nbehav,ncond),p_val{nbehav,ncond}]	= h_pValSort(stat{nbehav,ncond});
        
    end
end

%%

plimit                              = 0.15;
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
            
            cfg                     = [];
            cfg.channel             = 1;
            cfg.time_limit          = nw_stat.time([1 end]);
            cfg.color               = [0 0 0];
            cfg.lineshape           = '-x';
            cfg.linewidth           = 10;
            cfg.z_limit             = [0 1e-23];
            i = i + 1;
            subplot(nrow,ncol,i)
            h_plotSingleERFstat_selectChannel_nobox(cfg,nw_stat,nw_data);
            
            title({[list_behav{nbehav} ' with ' list_cond{ncond} ' fft'], ...
                ['p = ' num2str(round(min_p(nbehav,ncond),3))]});
            
            hline(0,'-k');
            vline(0,'-k');
            set(gca,'FontSize',16,'FontName', 'Calibri','FontWeight','normal');
            
        end
    end
end