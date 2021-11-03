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
    
    dir_data                        = '~/Dropbox/project_me/data/nback/singletrial/';
    fname_in                        = [dir_data 'sub' num2str(suj_list(nsuj)) '.singletrial.fft.mat'];
    fprintf('loading %s\n',fname_in);
    load(fname_in)
    
    flg_trials{1}                	= find(trialinfo(:,2) == 2);
    flg_trials{2}                 	= find(trialinfo(:,2) == 2 & rem(trialinfo(:,5),2) ~=0);
    
    list_band                       = {'alpha' 'beta'};
    list_behav                      = {'all trials' 'correct trials'};
    
    for nbehav = [1 2]
        
        % select trials
        pow                     = squeeze(freq_comb.powspctrm(flg_trials{nbehav},:,:));
        %             % normalize
        %             %             pow                   	= pow ./ mean(pow,1);
        
        avg                   	= [];
        avg.time            	= freq_comb.freq;
        avg.label            	= freq_comb.label;
        avg.dimord          	= 'chan_time';
        avg.avg              	= squeeze(mean(pow,1)); clear pow;
        
        alldata{nsuj,nbehav}    = avg; clear avg;
        
        
        list_stim              	= [2 3 4 5 7 8 9];
        
        [auc,time_axis]       	= h_auc(sujname,list_stim,flg_trials{nbehav});
        t1                   	= nearest(time_axis,0.2);
        t2                   	= nearest(time_axis,0.4);
        
        allbehav(nsuj,nbehav) 	= mean(auc(:,t1:t2));
        
    end
    
    
end

keep all* list_*

%%

nbsuj                               = size(alldata,1);
[~,neighbours]                      = h_create_design_neighbours(nbsuj,alldata{1,1},'elekta','t');

cfg                                 = [];
cfg.latency                         = [5 35];
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
    
    cfg.design(1,1:nbsuj)           = [allbehav(:,nbehav)];
    stat{nbehav}                    = ft_timelockstatistics(cfg, alldata{:,nbehav});
    [min_p(nbehav),p_val{nbehav}]	= h_pValSort(stat{nbehav});
    
end

%%

plimit                              = 0.05;
nrow                                = 2;
ncol                                = 2;
i                                   = 0;

for nbehav = 1:size(stat,1)
    
    if min_p(nbehav) < plimit
        
        nw_data                 = squeeze(alldata(:,nbehav));
        nw_stat                 = stat{nbehav};
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
        title({[list_behav{nbehav}], ...
            ['p = ' num2str(round(min_p(nbehav),3))]});
        
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
        %             cfg.z_limit             = [-3 3];
        
        i = i + 1;
        subplot(nrow,ncol,i)
        h_plotSingleERFstat_selectChannel_nobox(cfg,nw_stat,nw_data);
        
        hline(0,'-k');
        vline(0,'-k');
        set(gca,'FontSize',16,'FontName', 'Calibri','FontWeight','normal');
        
    end
end