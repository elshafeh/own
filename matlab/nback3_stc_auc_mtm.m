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

keep suj_list all* list*

for nsuj = 1:length(suj_list)
    
    dir_data                        = '~/Dropbox/project_me/data/nback/singletrial/';
    
    sujname                         = ['sub' num2str(suj_list(nsuj))];
    fname_in                        = [dir_data sujname '.singletrial.trialinfo.mat'];
    fprintf('loading %s\n',fname_in);
    load(fname_in);
    
    fname_in                        = [dir_data sujname '.singletrial.mtm.mat'];
    fprintf('loading %s\n',fname_in);
    load(fname_in)
    
    ext_stim                        = 'target';
    
    switch ext_stim
        case 'all'
            flg_trials              = 1:length(trialinfo);
        case 'target'
            flg_trials              = find(trialinfo(:,2) == 2);
    end
    
    list_stim                       = [1 2 3 4 5 6 7 8 9 10]; %[2 3 4 5 7 8 9]; %
    [data]                          = h_auc_diff_generate_avg(sujname,list_stim,flg_trials,[0.1 0.3]);
    
    list_band                       = {'alpha' 'beta'};
    
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
        
        %         select trials
        pow                     = squeeze(nanmean(freq_comb.powspctrm(flg_trials,:,f1:f2,:),3));
        %         normalize
        pow                             = pow ./ mean(pow,1);

        rho_sub                 = [];
        
        for nchan = 1:length(freq_comb.label)
            [rho,p]           	= corr(data,squeeze(pow(:,nchan,:)), 'type', 'Pearson');
            rho               	= .5.*log((1+rho)./(1-rho));
            rho_sub          	= [rho_sub; rho]; clear rho
        end
        
        avg                 	= [];
        avg.time            	= freq_comb.time;
        avg.label            	= freq_comb.label;
        avg.dimord           	= 'chan_time';
        avg.avg              	= rho_sub;
        
        alldata{nsuj,nband,1} 	= avg;
        
        avg.avg(:)          	= 0;
        alldata{nsuj,nband,2} 	= avg; clear avg rho pow
        
    end
end

keep alldata list_band ext_stim

%%

nbsuj                         	= size(alldata,1);
[design,neighbours]          	= h_create_design_neighbours(nbsuj,alldata{1,1},'elekta','t');

cfg                            	= [];
cfg.latency                    	= [-1 0.6];
cfg.statistic                 	= 'ft_statfun_depsamplesT';
cfg.method                     	= 'montecarlo';
cfg.correctm                  	= 'cluster';
cfg.clusteralpha             	= 0.05;
cfg.clusterstatistic         	= 'maxsum';
cfg.minnbchan                	= 3; % important %
cfg.tail                    	= 0;
cfg.clustertail              	= 0;
cfg.alpha                    	= 0.025;
cfg.numrandomization        	= 1000;
cfg.uvar                     	= 1;
cfg.ivar                    	= 2;
cfg.neighbours               	= neighbours;
cfg.design                   	= design;

for nband = [1 2]
    
    stat{nband}                	= ft_timelockstatistics(cfg,alldata{:,nband,1},alldata{:,nband,2});
    [min_p(nband),p_val{nband}]	= h_pValSort(stat{nband});clc;
    
end

%%

plimit                        	= 0.05;
nrow                          	= 2;
ncol                        	= 2;
i                            	= 0;

for nband = 1:length(stat)
    
    if min_p(nband) < plimit
        
        nw_data                 = squeeze(alldata(:,nband));
        nw_stat                 = stat{nband};
        nw_stat.mask            = nw_stat.prob < plimit;
        
        statplot                = [];
        statplot.avg            = nw_stat.mask .* nw_stat.stat;
        statplot.label          = nw_stat.label;
        statplot.dimord         = nw_stat.dimord;
        statplot.time           = nw_stat.time;
        
        find_sig_time           = mean(statplot.avg,1);
        find_sig_time           = find(find_sig_time ~= 0);
        list_time               = [min(statplot.time(find_sig_time)) max(statplot.time(find_sig_time))];
        
        cfg                     = [];
        cfg.layout              = 'neuromag306cmb_helmet.mat';
        cfg.xlim                = list_time;
        cfg.zlim                = [-3 3];
        cfg.colormap            = brewermap(256,'*RdBu');
        cfg.marker              = 'off';
        cfg.comment             = 'no';
        cfg.colorbar            = 'no';
        
        i = i + 1;
        cfg.figure              = subplot(nrow,ncol,i);
        
        ft_topoplotER(cfg,statplot);
        title({['p = ' num2str(round(min_p(nband),3))]});
        
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
        cfg.z_limit             = [-0.1 0.3];
        
        i = i + 1;
        subplot(nrow,ncol,i)
        h_plotSingleERFstat_selectChannel_nobox(cfg,nw_stat,nw_data);
        
        hline(0,'-k');
        vline(0,'-k');
        set(gca,'FontSize',16,'FontName', 'Calibri','FontWeight','normal');
        
    end
end