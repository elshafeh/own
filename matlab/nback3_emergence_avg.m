clear;clc;

suj_list                        = [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    fname_in                 	= ['~/Dropbox/project_me/data/nback/peak/sub' num2str(suj_list(nsuj)) '.alphabeta.peak.package.0back.mat'];
    fprintf('loading %s\n',fname_in);
    load(fname_in);
    
    allalphapeaks(nsuj,1)      	= apeak;
    allbetapeaks(nsuj,1)      	= bpeak;
    
end

mean_beta_peak               	= round(nanmedian(allbetapeaks));
allbetapeaks(isnan(allbetapeaks))   = mean_beta_peak;

keep all* suj_list

%%

for nsuj = 1:length(suj_list)
    
    % load in 0back data for baseline correction
    dir_data                    = '~/Dropbox/project_me/data/nback/0back/mtm/';
    fname_in                    = [dir_data 'sub' num2str(suj_list(nsuj)) '.0back.avgtrial.mtm.mat'];
    fprintf('loading %s\n',fname_in);
    load(fname_in);
    
    % baseline correction
    t1                          = nearest(freq_comb.time,-0.4);
    t2                          = nearest(freq_comb.time,-0.2);
    bsl                         = nanmean(freq_comb.powspctrm(:,:,t1:t2),3);
    
    bsl                         = repmat(bsl,[1 1 length(freq_comb.time)]);
    
    tf_activation           	= freq_comb;
    tf_baseline              	= freq_comb; clear freq_comb;
    tf_baseline.powspctrm       = bsl; clear bsl;
    
    list_band                 	= {'broadband'}; %alpha beta alphawide betawide
    
    for nband = 1:length(list_band)
        
        test_band           	= list_band{nband};
        
        switch test_band
            case 'alpha'
                f_focus       	= allalphapeaks(nsuj);
                f_width       	= 1;
            case 'beta'
                f_focus       	= allbetapeaks(nsuj);
                f_width       	= 2;
            case 'alphawide'
                f_focus         = 11;
                f_width         = 4;
            case 'betawide'
                f_focus         = 23;
                f_width         = 7;
            case 'broadband'
                f_focus         = 19;
                f_width         = 11;                
        end
        
        f1                    	= nearest(tf_activation.freq,round(f_focus-f_width));
        f2                   	= nearest(tf_activation.freq,round(f_focus+f_width));
        
        avg                   	= [];
        avg.time               	= tf_activation.time;
        avg.label            	= tf_activation.label;
        avg.dimord             	= 'chan_time';
        
        pow                 	= squeeze(nanmean(tf_activation.powspctrm(:,f1:f2,:),2));
        avg.avg                 = pow; clear pow;
        alldata{nsuj,nband,1} 	= avg;
        
        pow                 	= squeeze(nanmean(tf_baseline.powspctrm(:,f1:f2,:),2));
        avg.avg                 = pow; clear pow;
        alldata{nsuj,nband,2} 	= avg;
        
        
    end
end

keep alldata list_band

%%

nbsuj                                   	= size(alldata,1);
[design,neighbours]                     	= h_create_design_neighbours(nbsuj,alldata{1,1},'elekta','t');

for nband = 1:size(alldata,2)
    
    cfg                                   	= [];
    cfg.latency                          	= [-0.2 2];
    
    cfg.statistic                         	= 'ft_statfun_depsamplesT';
    cfg.method                           	= 'montecarlo';
    cfg.correctm                          	= 'cluster';
    cfg.clusteralpha                      	= 0.05;
    cfg.clusterstatistic                  	= 'maxsum';
    cfg.minnbchan                        	= 4; % important %
    cfg.tail                              	= 0;
    cfg.clustertail                       	= 0;
    cfg.alpha                             	= 0.025;
    cfg.numrandomization                  	= 1000;
    cfg.uvar                             	= 1;
    cfg.ivar                             	= 2;
    cfg.neighbours                       	= neighbours;
    cfg.design                              = design;
    stat{nband}                           	= ft_timelockstatistics(cfg,alldata{:,nband,1},alldata{:,nband,2});
    [min_p(nband),p_val{nband}]            	= h_pValSort(stat{nband});clc;
    
end

%%

plimit                                    	= 0.05;
font_size                                	= 16;
nrow                                      	= 2;
ncol                                      	= 4;
i                                        	= 0;

for nband = 1:length(stat)
    if min_p(nband) < plimit
        
        test_band                         	= list_band{nband};
        
        nw_data                            	= squeeze(alldata(:,nband,:));
        nw_stat                          	= stat{nband};
        nw_stat.mask                        = nw_stat.prob < plimit;
        
        %         if nsign == -1
        %             nw_stat.mask                	= (nw_stat.prob < plimit & nw_stat.stat < 0);
        %         elseif nsign == 1
        %             nw_stat.mask                   	= (nw_stat.prob < plimit & nw_stat.stat > 0);
        %         end
        
        statplot                         	= [];
        statplot.avg                     	= nw_stat.mask .* nw_stat.stat;
        statplot.label                   	= nw_stat.label;
        statplot.dimord                   	= nw_stat.dimord;
        statplot.time                     	= nw_stat.time;
        
        find_sig_time                      	= mean(statplot.avg,1);
        find_sig_time                     	= find(find_sig_time ~= 0);
        list_time                        	= [min(statplot.time(find_sig_time)) max(statplot.time(find_sig_time))];
        
        cfg                              	= [];
        cfg.layout                       	= 'neuromag306cmb_helmet.mat'; %'neuromag306cmb.lay'; %
        cfg.xlim                          	= list_time;
        cfg.zlim                          	= [-3 3];
        cfg.colormap                      	= brewermap(256,'*RdBu');
        cfg.marker                       	= 'off';
        cfg.comment                       	= 'no';
        cfg.colorbar                     	= 'yes';
        cfg.colorbartext                  	= 't-values';
        i = i + 1;
        cfg.figure                        	= subplot(nrow,ncol,i);
        
        ft_topoplotER(cfg,statplot);
        title({['Act vs Bsl ' test_band],['p = ' num2str(round(min_p(nband),3))]});
        
        set(gca,'FontSize',font_size,'FontName', 'Calibri','FontWeight','normal');
        
        find_sig_chan                     	= mean(statplot.avg(:,find_sig_time),2);
        find_sig_chan                     	= find(find_sig_chan ~= 0);
        list_chan                         	= nw_stat.label(find_sig_chan);
        
        cfg                               	= [];
        cfg.channel                      	= list_chan;
        cfg.time_limit                      = nw_stat.time([1 end]); %[-0.1 1]; %
        cfg.color                        	= [58 161 122; 47 123 182];
        cfg.z_limit                         = [0 2e-23];
        cfg.color                        	= {'-b' '-r'};
        
        cfg.linewidth                    	= 5;
        cfg.lineshape                     	= '-r';
        
        i = i + 1;
        subplot(nrow,ncol,i)
        h_plotSingleERFstat_selectChannel_nobox(cfg,nw_stat,nw_data);
        
        legend({'act' '' 'bsl' ''});
        
        hline(0,'-k');
        vline(0,'-k');
        
        vline(0.5,'--k','Mean RT');
        
        set(gca,'FontSize',16,'FontName', 'Calibri','FontWeight','normal');
        
    end
end