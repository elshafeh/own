clear;clc;

suj_list                            = [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    fname_in                        = ['~/Dropbox/project_me/data/nback/peak/sub' num2str(suj_list(nsuj)) '.alphabeta.peak.package.0back.mat'];
    fprintf('loading %s\n',fname_in);
    load(fname_in);
    
    allalphapeaks(nsuj,1)           = apeak;
    allbetapeaks(nsuj,1)            = bpeak;
    
end

mean_beta_peak                      = round(nanmedian(allbetapeaks));
allbetapeaks(isnan(allbetapeaks))               = mean_beta_peak;

keep suj_list all*

%%

for nsuj = 1:length(suj_list)
    
    dir_data                        = '~/Dropbox/project_me/data/nback/singletrial/';

    fname_in                        = [dir_data 'sub' num2str(suj_list(nsuj)) '.singletrial.trialinfo.mat'];
    fprintf('loading %s\n',fname_in);
    load(fname_in);
        
    fname_in                        = [dir_data 'sub' num2str(suj_list(nsuj)) '.singletrial.erfComb.mat'];
    fprintf('loading %s\n',fname_in);
    load(fname_in)
    
    ext_stim                        = 'first';
    ext_behav                       = 'rt'; % accuracy rt 
    
    if strcmp(ext_stim,'target')
        
        flg_trials                  = find(trialinfo(:,2) == 2);
        
    elseif strcmp(ext_stim,'first')
        
        % this is made to put the target RT/responses for the first stimuli
        trialinfo                  	= h_nback_trialinfo_transform(trialinfo);
        % leads to less trials but makes correlations possible
        avg_comb.trial           	= avg_comb.trial(trialinfo(:,6),:,:,:);
        
        flg_trials                  = find(trialinfo(:,2) == 1);
        
    end
    
    pow                             = avg_comb.trial;
    rho_carrier                     = [];
    
    disp('computing correlation');
    
    for ntime = 1:length(avg_comb.time)
        
        data                        = squeeze(pow(flg_trials,:,ntime));
        
        if strcmp(ext_behav,'accuracy')
            behav                   = trialinfo(flg_trials,4);
            behav(behav == 1 | behav == 3)  = 1;
            behav(behav == 2 | behav == 4)  = 0;
            
        elseif strcmp(ext_behav,'rt')
            behav                   = trialinfo(flg_trials,5)/1000;
        end
        
        [rho,p]                     = corr(data,behav , 'type', 'Spearman');
        rho                         = .5.*log((1+rho)./(1-rho));
        
        rho_carrier(:,ntime)        = rho; clear rho;
        
    end
    
    avg                             = [];
    avg.time                        = avg_comb.time;
    avg.label                       = avg_comb.label;
    avg.dimord                      = 'chan_time';
    avg.avg                         = rho_carrier; clear rho_carrier;
    
    alldata{nsuj,1}                 = avg;
    
    avg.avg(:)                      = 0;
    alldata{nsuj,2}                 = avg; clear avg;
    
end

keep alldata ext_*

%%

nbsuj                               = size(alldata,1);
[design,neighbours]                 = h_create_design_neighbours(nbsuj,alldata{1,1},'elekta','t');

cfg                                 = [];
cfg.latency                         = [0 0.5];
cfg.statistic                       = 'ft_statfun_depsamplesT';
cfg.method                          = 'montecarlo';
cfg.correctm                        = 'cluster';
cfg.clusteralpha                    = 0.05;
cfg.clusterstatistic                = 'maxsum';
cfg.minnbchan                       = 3; % important %
cfg.tail                            = 0;
cfg.clustertail                     = 0;
cfg.alpha                           = 0.025;
cfg.numrandomization                = 1000;
cfg.uvar                            = 1;
cfg.ivar                            = 2;
cfg.neighbours                      = neighbours;
cfg.design                          = design;
stat                                = ft_timelockstatistics(cfg,alldata{:,1},alldata{:,2});
[min_p,p_val]                       = h_pValSort(stat);clc;

%%

plimit                              = 0.05;
font_size                           = 16;
nrow                                = 2;
ncol                                = 2;
i                                   = 0;

if min_p < plimit
    
    for sig = [-1 1]
        
        nw_data                  	= alldata;
        nw_stat                  	= stat;
        
        if sig == -1
            nw_stat.mask            = (nw_stat.prob < plimit & nw_stat.stat < 0);
        elseif sig == 1
            nw_stat.mask            = (nw_stat.prob < plimit & nw_stat.stat > 0);
        end
        
        statplot                   	= [];
        statplot.avg             	= nw_stat.mask .* nw_stat.stat;
        statplot.label           	= nw_stat.label;
        statplot.dimord           	= nw_stat.dimord;
        statplot.time             	= nw_stat.time;
        
        find_sig_time            	= mean(statplot.avg,1);
        find_sig_time             	= find(find_sig_time ~= 0);
        list_time                 	= [min(statplot.time(find_sig_time)) max(statplot.time(find_sig_time))];
        
        cfg                      	= [];
        cfg.layout                 	= 'neuromag306cmb_helmet.mat'; %'neuromag306cmb.lay'; %
        cfg.xlim                   	= list_time;
        cfg.zlim                   	= [-2 2];
        cfg.colormap              	= brewermap(256,'*RdBu');
        cfg.marker                	= 'off';
        cfg.comment               	= 'no';
        cfg.colorbar               	= 'yes';
        cfg.colorbartext           	= 't-values';
        i = i + 1;
        cfg.figure                	= subplot(nrow,ncol,i);
        
        ft_topoplotER(cfg,statplot);
        title({[ext_stim ' with ' ext_behav],['p = ' num2str(round(min_p,3))]});
        
        set(gca,'FontSize',font_size,'FontName', 'Calibri','FontWeight','normal');
        
        find_sig_chan              	= mean(statplot.avg(:,find_sig_time),2);
        find_sig_chan             	= find(find_sig_chan ~= 0);
        list_chan                	= nw_stat.label(find_sig_chan);
        
        cfg                       	= [];
        cfg.channel              	= list_chan;
        cfg.time_limit            	= [-0.1 0.6]; % nw_stat.time([1 end]);
        cfg.color                 	= {'-k' '-r'};
        
        cfg.z_limit               	= [-0.1 0.1];
        cfg.linewidth             	= 5;
        cfg.lineshape             	= '-r';
        
        i = i + 1;
        subplot(nrow,ncol,i)
        h_plotSingleERFstat_selectChannel_nobox(cfg,nw_stat,nw_data);
        
        hline(0,'-k');
        vline(0,'-k');
        
        set(gca,'FontSize',16,'FontName', 'Calibri','FontWeight','normal');
        
    end
end