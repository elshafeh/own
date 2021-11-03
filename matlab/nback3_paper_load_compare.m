clear;clc;

suj_list                                    = [1:33 35:36 38:44 46:51];

nobeta                                      = [];

for nsuj = 1:length(suj_list)
        
    dir_data                                = '~/Dropbox/project_me/data/nback/peak/';
    ext_peak                            	= 'alphabeta.peak.package.0back.equalhemi';
    fname_in                            	= [dir_data 'sub' num2str(suj_list(nsuj)) '.' ext_peak '.mat'];
    fprintf('loading %s\n',fname_in);
    load(fname_in);
    
    allalphapeaks(nsuj,1)                	= apeak;
    allbetapeaks(nsuj,1)                 	= bpeak(1);
    
    nobeta                                  = [nobeta;orig_nan];
    
end

keep suj_list all*

%%

for nsuj = 1:length(suj_list)
    
    for nback = 1:2
        
        ext_stim                        	= 'allstim'; % first target allstim norep 
        baseline_correct                    = 'center'; % none single average center within
        baseline_period                 	= [-0.4 -0.2];
        
        dir_data                         	= '~/Dropbox/project_me/data/nback/tf/behav2tf/';
        file_name_1                      	= [dir_data 'sub' num2str(suj_list(nsuj)) '.session*.' num2str(nback) 'back.' ext_stim '.correct.adaptive.mtm.mat'];
        file_list                         	= [dir(file_name_1)]; 
        
        pow                               	= [];
        
        for nfile = 1:length(file_list)
            
            fname_in                      	= [file_list(nfile).folder filesep file_list(nfile).name];
            fprintf('loading %s\n',fname_in);
            load(fname_in);
            
            if strcmp(baseline_correct,'single')
                disp(['applying ' baseline_correct ' baseline correction']);
                % - % baseline correction
                t1                       	= nearest(freq_comb.time,baseline_period(1));
                t2                       	= nearest(freq_comb.time,baseline_period(2));
                bsl                      	= nanmean(freq_comb.powspctrm(:,:,t1:t2),3);
                freq_comb.powspctrm      	= (freq_comb.powspctrm - bsl) ./ bsl ; clear bsl t1 t2;
            end
            
            pow(nfile,:,:,:)             	= freq_comb.powspctrm;
            
        end
        
        freq_comb.powspctrm             	= squeeze(mean(pow,1)); clear pow;
        
        if strcmp(baseline_correct,'average')
            disp(['applying ' baseline_correct ' baseline correction']);
            % - % baseline correction
            t1                            	= nearest(freq_comb.time,baseline_period(1));
            t2                          	= nearest(freq_comb.time,baseline_period(2));
            bsl                          	= nanmean(freq_comb.powspctrm(:,:,t1:t2),3);
            freq_comb.powspctrm         	= (freq_comb.powspctrm - bsl) ./ bsl ; clear bsl t1 t2;
        end
        
        list_band                           = {'alpha' 'beta'}; % 'high-beta'
        
        for nband = 1:length(list_band)
            
            test_band                       = list_band{nband};
            
            switch test_band
                case 'alpha'
                    f_focus              	= allalphapeaks(nsuj);
                    f_width              	= 1;
                case 'beta'
                    f_focus               	= allbetapeaks(nsuj);
                    f_width               	= 2;
                case 'high-beta'
                    f_focus              	= allhighbetapeaks(nsuj);
                    f_width               	= 2;
            end
            
            f1                          	= nearest(freq_comb.freq,f_focus-f_width);
            f2                           	= nearest(freq_comb.freq,f_focus+f_width);
            pow                          	= squeeze(nanmean(freq_comb.powspctrm(:,f1:f2,:),2));
            
            avg                          	= [];
            avg.time                    	= freq_comb.time;
            avg.label                    	= freq_comb.label;
            avg.dimord                    	= 'chan_time';
            avg.avg                      	= pow;
            
            if strcmp(baseline_correct,'center')
                
                disp(['applying ' baseline_correct ' baseline correction']);
                % - % baseline correction
                t1                           	= nearest(freq_comb.time,baseline_period(1));
                t2                           	= nearest(freq_comb.time,baseline_period(2));
                bsl                            	= nanmean(avg.avg(:,t1:t2),2);
                avg.avg                       	= (avg.avg  - bsl) ./ bsl ; clear bsl t1 t2;
            end
            
            alldata{nsuj,nband,nback}           = avg; clear avg pow f1 f2 f_*;
            
        end
    end
end

keep alldata list_band ext_stim baseline_correct

%%

nbsuj                                       	= size(alldata,1);
[design,neighbours]                             = h_create_design_neighbours(nbsuj,alldata{1,1},'elekta','t');

for nband = 1:size(alldata,2)
    
    cfg                                         = [];
    cfg.latency                                 = [-0.1 2];
    
    cfg.statistic                               = 'ft_statfun_depsamplesT';
    cfg.method                                  = 'montecarlo';
    cfg.correctm                                = 'cluster';
    cfg.clusteralpha                            = 0.05;
    cfg.clusterstatistic                        = 'maxsum';
    cfg.minnbchan                               = 3; % important %
    cfg.tail                                    = 0;
    cfg.clustertail                             = 0;
    cfg.alpha                                   = 0.025;
    cfg.numrandomization                        = 1000;
    cfg.uvar                                    = 1;
    cfg.ivar                                    = 2;
    cfg.neighbours                              = neighbours;
    cfg.design                                  = design;
    stat{nband}                               	= ft_timelockstatistics(cfg,alldata{:,nband,1},alldata{:,nband,2});
    [min_p(nband),p_val{nband}]               	= h_pValSort(stat{nband});clc;
    
end

%%

close all;

plimit                                          = 0.025;
font_size                                       = 16;
nrow                                            = 2;
ncol                                            = 2;
i                                               = 0;

list_z                                          = [-0.3 0.3; -0.3 0.3]; % [-0.35 0.35; -0.35 0.35];

for nband = 1:length(stat)
    if min_p(nband) < plimit
        
        test_band                               = list_band{nband};
        
        nw_data                                 = squeeze(alldata(:,nband,:));
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
        cfg.zlim                                = [-3 3];
        cfg.colormap                            = brewermap(256,'*PuOr');
        cfg.marker                              = 'off';
        cfg.comment                             = 'no';
        cfg.colorbar                            = 'yes';
        cfg.colorbartext                        = 't-values';
        i = i + 1;
        cfg.figure                              = subplot(nrow,ncol,i);
        
        ft_topoplotER(cfg,statplot);
        title({['1-Back vs 2-Back ' test_band ' ' ext_stim],['p = ' num2str(round(min_p(nband),3))]});
        
        set(gca,'FontSize',font_size,'FontName', 'Calibri','FontWeight','normal');
        
        find_sig_chan                           = mean(statplot.avg(:,find_sig_time),2);
        find_sig_chan                           = find(find_sig_chan ~= 0);
        list_chan                               = nw_stat.label(find_sig_chan);
        
        cfg                                     = [];
        cfg.channel                             = list_chan;
        cfg.time_limit                          = nw_stat.time([1 end]); % [-0.1 2]; % 
        cfg.color                               = [83 51 137; 197 94 32]; % [58 161 122; 47 123 182];
        cfg.color                               = cfg.color ./ 256;
        
        cfg.z_limit                             = list_z(nband,:); % [0 1.5e-23]; %
        
        cfg.linewidth                           = 5;
        cfg.lineshape                           = '-r';
        
        i = i + 1;
        subplot(nrow,ncol,i)
        h_plotSingleERFstat_selectChannel_nobox(cfg,nw_stat,nw_data);
        
        legend({'1-Back' '' '2-Back' ''},'Location','southeast');
        
        hline(0,'-k');
        vline(0,'-k');
        
        %         vline(0.5,'--k','Mean RT');
        
        set(gca,'FontSize',16,'FontName', 'Calibri','FontWeight','normal');
        
        mask_mean                   = mean(nw_stat.mask,1);
        mask_mean(mask_mean ~= 0)   = 1;
        sig_time                    = mask_mean .* nw_stat.time
        
    end
end