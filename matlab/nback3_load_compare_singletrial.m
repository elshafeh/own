clear;clc;

suj_list                    = [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
        
    fname_in              	= ['~/Dropbox/project_me/data/nback/peak/sub' num2str(suj_list(nsuj)) '.alphabeta.peak.package.0back.mat'];
    fprintf('loading %s\n',fname_in);
    load(fname_in);
    
    allalphapeaks(nsuj,1) 	= apeak;
    allbetapeaks(nsuj,1) 	= bpeak;
    
end

mean_beta_peak          	= round(nanmedian(allbetapeaks));
allbetapeaks(isnan(allbetapeaks))               = mean_beta_peak;

keep suj_list all*

for nsuj = 1:length(suj_list)
    
    dir_data                = '~/Dropbox/project_me/data/nback/singletrial/';
    fname_in                = [dir_data 'sub' num2str(suj_list(nsuj)) '.singletrial.mtm.mat'];
    fprintf('loading %s\n',fname_in);
    load(fname_in);
    
    fname_in                = [dir_data 'sub' num2str(suj_list(nsuj)) '.singletrial.trialinfo.mat'];
    fprintf('loading %s\n',fname_in);
    load(fname_in);
    
    for nback = 1:2
        
        pow                 = [];
        

        baseline_correct  	= 'average';
        baseline_period  	= [-0.4 -0.2];
        
        ext_stim            = 'allstim'; % nontarget target allstim
        
        if strcmp(ext_stim,'nontarget')
            find_stim     	= find(trialinfo(:,2) ~= 2); % focus non-target/target
        elseif strcmp(ext_stim,'target')
            find_stim     	= find(trialinfo(:,2) == 2); 
          elseif strcmp(ext_stim,'allstim')  
              find_stim   	= find(trialinfo(:,2) < 10);
        end
        
        find_resp           = find(rem(trialinfo(:,4),2) ~= 0); % focus on correct/incorrect
        find_back           = find(trialinfo(:,1) == nback+4); % focus on nback
        
        find_trials       	= intersect(intersect(find_stim,find_resp),find_back);
        
        pow                 = squeeze(mean(freq_comb.powspctrm(find_trials,:,:,:),1));
        
        % - % baseline correction
        if strcmp(baseline_correct,'average')
            
            disp(['applying ' baseline_correct ' baseline correction']);
            
            t1            	= nearest(freq_comb.time,baseline_period(1));
            t2           	= nearest(freq_comb.time,baseline_period(2));
            
            bsl          	= nanmean(pow(:,:,t1:t2),3);
            pow             = (pow - bsl) ./ bsl ; clear bsl t1 t2;
            
        end
        
        list_band        	= {'alpha' 'beta'};
        
        for nband = 1:length(list_band)
            
            test_band    	= list_band{nband};
            
            switch test_band
                case 'alpha'
                    f_focus	= allalphapeaks(nsuj);
                    f_width	= 1;
                case 'beta'
                    f_focus	= allbetapeaks(nsuj);
                    f_width	= 2;
            end
            
            f1            	= nearest(freq_comb.freq,f_focus-f_width);
            f2            	= nearest(freq_comb.freq,f_focus+f_width);
            band_pow      	= squeeze(nanmean(pow(:,f1:f2,:),2));
            
            avg            	= [];
            avg.time        = freq_comb.time;
            avg.label     	= freq_comb.label;
            avg.dimord    	= 'chan_time';
            avg.avg     	= band_pow;
            
            alldata{nsuj,nband,nback}	= avg; clear avg band_pow f1 f2 f_*;
            
        end
    end
end

keep alldata list_band ext_stim baseline_correct

%%

nbsuj                       = size(alldata,1);
[design,neighbours]       	= h_create_design_neighbours(nbsuj,alldata{1,1},'elekta','t');

for nband = 1:size(alldata,2)
    
    cfg                 	= [];
    cfg.latency          	= [-0.1 0.6];
    
    cfg.statistic         	= 'ft_statfun_depsamplesT';
    cfg.method            	= 'montecarlo';
    cfg.correctm         	= 'cluster';
    cfg.clusteralpha     	= 0.05;
    cfg.clusterstatistic  	= 'maxsum';
    cfg.minnbchan         	= 3; % important %
    cfg.tail             	= 0;
    cfg.clustertail       	= 0;
    cfg.alpha              	= 0.025;
    cfg.numrandomization  	= 1000;
    cfg.uvar             	= 1;
    cfg.ivar              	= 2;
    cfg.neighbours       	= neighbours;
    cfg.design          	= design;
    stat{nband}          	= ft_timelockstatistics(cfg,alldata{:,nband,1},alldata{:,nband,2});
    [min_p(nband),p_val{nband}]               	= h_pValSort(stat{nband});clc;
    
end

%%

close all;

plimit                  	= 0.05;
font_size                	= 16;
nrow                     	= 2;
ncol                     	= 2;
i                        	= 0;

for nband = 1:length(stat)
    if min_p(nband) < plimit
        
        test_band       	= list_band{nband};
        
        nw_data             = squeeze(alldata(:,nband,:));
        nw_stat         	= stat{nband};
        nw_stat.mask    	= nw_stat.prob < plimit;
        
        statplot         	= [];
        statplot.avg     	= nw_stat.mask .* nw_stat.stat;
        statplot.label   	= nw_stat.label;
        statplot.dimord  	= nw_stat.dimord;
        statplot.time     	= nw_stat.time;
        
        find_sig_time    	= mean(statplot.avg,1);
        find_sig_time    	= find(find_sig_time ~= 0);
        list_time        	= [min(statplot.time(find_sig_time)) max(statplot.time(find_sig_time))];
        
        cfg             	= [];
        cfg.layout       	= 'neuromag306cmb_helmet.mat'; %'neuromag306cmb.lay'; %
        cfg.xlim         	= list_time;
        cfg.zlim         	= [-3 3];
        cfg.colormap     	= brewermap(256,'*RdBu');
        cfg.marker       	= 'off';
        cfg.comment       	= 'no';
        cfg.colorbar      	= 'yes';
        cfg.colorbartext  	= 't-values';
        i = i + 1;
        cfg.figure       	= subplot(nrow,ncol,i);
        
        ft_topoplotER(cfg,statplot);
        title({['1-Back vs 2-Back ' test_band ' ' ext_stim],['p = ' num2str(round(min_p(nband),3))]});
        
        set(gca,'FontSize',font_size,'FontName', 'Calibri','FontWeight','normal');
        
        find_sig_chan    	= mean(statplot.avg(:,find_sig_time),2);
        find_sig_chan    	= find(find_sig_chan ~= 0);
        list_chan        	= nw_stat.label(find_sig_chan);
        
        cfg             	= [];
        cfg.channel       	= list_chan;
        cfg.time_limit   	= [-0.1 1]; %nw_stat.time([1 end]); % 
        cfg.color         	= [58 161 122; 47 123 182];
        
        cfg.color         	= cfg.color ./ 256;
        
        if strcmp(baseline_correct,'none')
            if strcmp(test_band,'alpha')
                cfg.z_limit                   	= [0 1e-23];
            elseif strcmp(test_band,'beta')
                cfg.z_limit                     = [0 0.5e-23];
            end
        else
            cfg.z_limit   	= [-0.5 0.5];
        end
        
        cfg.linewidth       = 5;
        cfg.lineshape    	= '-r';
        
        i = i + 1;
        subplot(nrow,ncol,i)
        h_plotSingleERFstat_selectChannel_nobox(cfg,nw_stat,nw_data);
        
        legend({'1-Back' '' '2-Back' ''});
        
        hline(0,'-k');
        vline(0,'-k');
        
        vline(0.5,'--k','Mean RT');
        
        set(gca,'FontSize',16,'FontName', 'Calibri','FontWeight','normal');
        
    end
end