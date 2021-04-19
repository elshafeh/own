clear;clc;

suj_list                                        = [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
        
    fname_in                                    = ['~/Dropbox/project_me/data/nback/peak/sub' num2str(suj_list(nsuj)) '.alphabeta.peak.package.0back.mat'];
    fprintf('loading %s\n',fname_in);
    load(fname_in);
    
    allalphapeaks(nsuj,1)                       = apeak;
    allbetapeaks(nsuj,1)                        = bpeak;
    
end

mean_beta_peak                                  = round(nanmedian(allbetapeaks));
allbetapeaks(isnan(allbetapeaks))               = mean_beta_peak;

keep suj_list all*

%%

for nsuj = 1:length(suj_list)
    
    for nback = 1:2
        
        ext_stim                                = 'target';
        baseline_correct                        = 'none'; % none single average center
        baseline_period                         = [-0.4 -0.2];
        
        difference_type                         = 'difference' ; % difference relative
        
        dir_data                                = '~/Dropbox/project_me/data/nback/tf/behav2tf/';
        file_list                               = dir([dir_data 'sub' num2str(suj_list(nsuj)) '.' num2str(nback) 'back.' ext_stim '.correct.mtm.mat']);
        pow                                     = [];
        
        for nfile = 1:length(file_list)
            fname_in                            = [file_list(nfile).folder filesep file_list(nfile).name];
            fprintf('loading %s\n',fname_in);
            load(fname_in);
            
            if strcmp(baseline_correct,'single')
                % - % baseline correction
                t1                           	= nearest(freq_comb.time,baseline_period(1));
                t2                           	= nearest(freq_comb.time,baseline_period(2));
                bsl                           	= nanmean(freq_comb.powspctrm(:,:,t1:t2),3);
                freq_comb.powspctrm          	= (freq_comb.powspctrm - bsl) ./ bsl ; clear bsl t1 t2;
            end
            
            pow(nfile,:,:,:)                    = freq_comb.powspctrm;
        end
        
        freq_comb.powspctrm                     = squeeze(mean(pow,1)); clear pow;
        
        if strcmp(baseline_correct,'average')
            % - % baseline correction
            t1                                  = nearest(freq_comb.time,baseline_period(1));
            t2                                  = nearest(freq_comb.time,baseline_period(2));
            bsl                               	= nanmean(freq_comb.powspctrm(:,:,t1:t2),3);
            freq_comb.powspctrm               	= (freq_comb.powspctrm - bsl) ./ bsl ; clear bsl t1 t2;
        end
        
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
            
            % - % average across band of interest
            f1                                  = find(round(freq_comb.freq) == round(f_focus-f_width));
            f2                                  = find(round(freq_comb.freq) == round(f_focus+f_width));
            pow                                 = squeeze(nanmean(freq_comb.powspctrm(:,f1:f2,:),2));
            
            avg                                 = [];
            avg.time                            = freq_comb.time;
            avg.label                           = freq_comb.label;
            avg.dimord                          = 'chan_time';
            avg.avg                             = pow;
            
            if strcmp(baseline_correct,'center')
                % - % baseline correction
                t1                           	= nearest(freq_comb.time,baseline_period(1));
                t2                           	= nearest(freq_comb.time,baseline_period(2));
                bsl                            	= nanmean(avg.avg(:,t1:t2),2);
                avg.avg                       	= (avg.avg  - bsl) ./ bsl ; clear bsl t1 t2;
            end
            
            tmp{nband,nback}                    = avg; clear avg pow f1 f2 f_*;
            
        end
    end
    
    for nband = 1:size(tmp,1)
        
        alldata{nsuj,nband}                     = tmp{nband,1};
        
        switch difference_type
            case 'difference'
                alldata{nsuj,nband}.avg       	= tmp{nband,1}.avg - tmp{nband,2}.avg;
            case 'relative'
                alldata{nsuj,nband}.avg      	= (tmp{nband,1}.avg - tmp{nband,2}.avg) ./ tmp{nband,2}.avg;
            otherwise
                error('pick a difference technique');
        end
        
    end
    
    clear tmp
    
end

keep alldata list_band ext_stim baseline_correct

%%

nbsuj                                           = size(alldata,1);
[design,neighbours]                             = h_create_design_neighbours(nbsuj,alldata{1,1},'elekta','t');

cfg                                             = [];
cfg.latency                                     = [-0.2 1];
cfg.statistic                                   = 'ft_statfun_depsamplesT';
cfg.method                                      = 'montecarlo';
cfg.correctm                                    = 'cluster';
cfg.clusteralpha                                = 0.05;
cfg.clusterstatistic                            = 'maxsum';
cfg.minnbchan                                   = 3; % important %
cfg.tail                                        = 0;
cfg.clustertail                                 = 0;
cfg.alpha                                       = 0.025;
cfg.numrandomization                            = 1000;
cfg.uvar                                        = 1;
cfg.ivar                                        = 2;
cfg.neighbours                                  = neighbours;
cfg.design                                      = design;
stat{1}                                         = ft_timelockstatistics(cfg,alldata{:,1},alldata{:,2});
[min_p(1),p_val{1}]                             = h_pValSort(stat{1});clc;

%%

close all;

plimit                                          = 0.2;
nrow                                            = 2;
ncol                                            = 2;
i                                               = 0;

for nband = 1:length(stat)
    if min_p(nband) < plimit
        
        test_band                               = list_band{nband};
        
        nw_data                                 = alldata;
        nw_stat                                 = stat{nband};
        nw_stat.mask                            = nw_stat.prob < plimit;
        
        statplot                                = [];
        statplot.avg                            = nw_stat.mask .* nw_stat.stat;
        statplot.label                          = nw_stat.label;
        statplot.dimord                         = nw_stat.dimord;
        statplot.time                           = nw_stat.time;
            
        
        find_sig_time                           = mean(statplot.avg,1);
        find_sig_time                           = find(find_sig_time ~= 0);
        list_time                               = [min(statplot.time(find_sig_time)) max(statplot.time(find_sig_time))];
        
        cfg                                     = [];
        cfg.layout                              = 'neuromag306cmb.lay';
        cfg.xlim                                = list_time;
        cfg.zlim                                = [-2 2];
        cfg.colormap                            = brewermap(256,'*RdBu');
        cfg.marker                              = 'off';
        cfg.comment                             = 'no';
        cfg.colorbar                            = 'no';
        
        i = i + 1;
        subplot(nrow,ncol,i)
        ft_topoplotER(cfg,statplot);
        title({['alpha vs beta ' ext_stim],['p = ' num2str(round(min_p(nband),3))]});
        
        set(gca,'FontSize',14,'FontName', 'Calibri','FontWeight','normal');
        
        find_sig_chan                           = mean(statplot.avg,2);
        find_sig_chan                           = find(find_sig_chan ~= 0);
        list_chan                               = nw_stat.label(find_sig_chan);
        
        cfg                                     = [];
        cfg.channel                             = list_chan;
        cfg.time_limit                          = nw_stat.time([1 end]);
        cfg.color                               = [109 179 177; 111 71 142];
        cfg.color                               = cfg.color ./ 256;
        
        if strcmp(baseline_correct,'none')
            if strcmp(test_band,'alpha')
                cfg.z_limit                 	= [0 1e-23];
            elseif strcmp(test_band,'beta')
                cfg.z_limit                  	= [0 0.5e-23];
            end
        else
            cfg.z_limit                       	= [-0.5 0.5];
        end
        
        cfg.linewidth                           = 5;
        cfg.lineshape                           = '-r';
        
        i = i + 1;
        subplot(nrow,ncol,i)
        h_plotSingleERFstat_selectChannel_nobox(cfg,nw_stat,nw_data);
        
        legend({'alpha' '' 'beta' ''});
        
        xlim(statplot.time([1 end]));
        hline(0,'-k');
        vline(0,'-k');
        %         xticks([0 0.1 0.2 0.3 0.4 0.5]);
        set(gca,'FontSize',16,'FontName', 'Calibri','FontWeight','normal');
        
    end
end