clear;clc;

suj_list                                    = [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    fname_in                                = ['~/Dropbox/project_me/data/nback/peak/sub' num2str(suj_list(nsuj)) '.alphabeta.peak.package.0back.mat'];
    fprintf('loading %s\n',fname_in);
    load(fname_in);
    
    allalphapeaks(nsuj,1)                   = apeak;
    allbetapeaks(nsuj,1)                    = bpeak;
    
end

mean_beta_peak                              = round(nanmedian(allbetapeaks));
allbetapeaks(isnan(allbetapeaks))          	= mean_beta_peak;

keep suj_list all*

for nsuj = 1:length(suj_list)
    
    dir_data                                = '~/Dropbox/project_me/data/nback/singletrial/';
    fname_in                                = [dir_data 'sub' num2str(suj_list(nsuj)) '.singletrial.fft.mat'];
    
    fprintf('loading %s\n',fname_in);
    load(fname_in)
    
    fname_in                                = [dir_data 'sub' num2str(suj_list(nsuj)) '.singletrial.trialinfo.mat'];
    
    fprintf('loading %s\n',fname_in);
    load(fname_in);
    
    
    
    ext_behav                               = 'rt';
    ext_correlation                         = 'Pearson';
    
    list_band                               = {'alpha' 'beta'};
    
    for nband = 1:length(list_band)
        
        test_band                           = list_band{nband};
        
        switch test_band
            case 'alpha'
                f_focus                     = allalphapeaks(nsuj);
                f_width                     = 1;
            case 'beta'
                f_focus                     = allbetapeaks(nsuj);
                f_width                     = 2;
        end
        
        f1                                  = nearest(freq_comb.freq,f_focus-f_width);
        f2                                  = nearest(freq_comb.freq,f_focus+f_width);
        pow                                 = nanmean(squeeze(freq_comb.powspctrm(:,:,f1:f2)),3);
        
        if strcmp(ext_stim,'target')
            if strcmp(ext_behav,'rt')
                flg_trials   	= find(trialinfo(:,2) == 2 & trialinfo(:,4) ~= 0 & rem(trialinfo(:,5),2) ~=0);
            elseif strcmp(ext_behav,'accuracy')
                flg_trials   	= find(trialinfo(:,2) == 2);
            end
        end
        
        % extract power
        pow                                 = pow(flg_trials,:);
        % normalize
        pow                                 = pow ./ nanmean(pow);
        
        
        if strcmp(ext_behav,'accuracy')
            
            behav                           = trialinfo(flg_trials,4);
            behav(behav == 1 | behav == 3)  = 1;
            behav(behav == 2 | behav == 4)  = 0;
            
        elseif strcmp(ext_behav,'rt')
            
            behav                           = trialinfo(flg_trials,5) / 1000;
            behav                           = behav ./ mean(behav);
            
        end
        
        [rho,p]                             = corr(pow,behav , 'type', ext_correlation);
        rho                                 = .5.*log((1+rho)./(1-rho));
        
        avg                                 = [];
        avg.time                            = 10;
        avg.label                           = freq_comb.label;
        avg.dimord                          = 'chan_time';
        avg.avg                             = rho;
        
        alldata{nsuj,nband,1}               = avg;
        
        avg.avg(:)                          = 0;
        alldata{nsuj,nband,2}               = avg; clear avg rho
        
    end
end

keep alldata list_band ext_*

%%

nbsuj                                       = size(alldata,1);
[design,neighbours]                         = h_create_design_neighbours(nbsuj,alldata{1,1},'elekta','t');

for nband = 1:size(alldata,2)
    
    cfg                                   	= [];
    cfg.statistic                          	= 'ft_statfun_depsamplesT';
    cfg.method                             	= 'montecarlo';
    cfg.correctm                         	= 'cluster';
    cfg.clusteralpha                     	= 0.05;
    cfg.clusterstatistic                  	= 'maxsum';
    cfg.minnbchan                          	= 2; % important %
    cfg.tail                              	= 0;
    cfg.clustertail                       	= 0;
    cfg.alpha                            	= 0.025;
    cfg.numrandomization                	= 1000;
    cfg.uvar                             	= 1;
    cfg.ivar                              	= 2;
    cfg.neighbours                         	= neighbours;
    cfg.design                           	= design;
    stat{nband}                           	= ft_timelockstatistics(cfg,alldata{:,nband,1},alldata{:,nband,2});
    [min_p(nband),p_val{nband}]         	= h_pValSort(stat{nband});clc;
    
end

%%

plimit                                    	= 0.5;
font_size                               	= 16;
nrow                                     	= 2;
ncol                                     	= 2;
i                                         	= 0;

for nband = 1:length(stat)
    if min_p(nband) < plimit
        
        nw_data                          	= squeeze(alldata(:,nband,:));
        nw_stat                            	= stat{nband};
        nw_stat.mask                      	= nw_stat.prob < plimit;
        
        statplot                          	= [];
        statplot.avg                       	= nw_stat.mask .* nw_stat.stat;
        statplot.label                    	= nw_stat.label;
        statplot.dimord                    	= nw_stat.dimord;
        statplot.time                       = nw_stat.time;
        
        find_sig_time                     	= mean(statplot.avg,1);
        find_sig_time                     	= find(find_sig_time ~= 0);
        list_time                         	= [min(statplot.time(find_sig_time)) max(statplot.time(find_sig_time))];
        
        cfg                                	= [];
        cfg.layout                        	= 'neuromag306cmb_helmet.mat'; %'neuromag306cmb.lay'; %
        cfg.xlim                          	= list_time;
        cfg.zlim                          	= [-2 2];
        cfg.colormap                     	= brewermap(256,'*RdBu');
        cfg.marker                       	= 'off';
        cfg.comment                       	= 'no';
        cfg.colorbar                     	= 'yes';
        cfg.colorbartext                  	= 't-values';
        i = i + 1;
        cfg.figure                       	= subplot(nrow,ncol,i);
        
        ft_topoplotER(cfg,statplot);
        title({[list_band{nband} ' : '  ext_stim ' with ' ext_behav],['p = ' num2str(round(min_p(nband),3))]});
        
        set(gca,'FontSize',font_size,'FontName', 'Calibri','FontWeight','normal');
        
        
    end
end