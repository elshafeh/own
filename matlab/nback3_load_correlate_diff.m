clear;clc;

suj_list                                    = [1:33 35:36 38:44 46:51];
suj_list(suj_list == 19)                    = [];
suj_list(suj_list == 38)                    = [];

for nsuj = 1:length(suj_list)
        
    dir_data                                = '~/Dropbox/project_me/data/nback/peak/';
    ext_peak                            	= 'alphabeta.peak.package.0back.fixed';
    fname_in                            	= [dir_data 'sub' num2str(suj_list(nsuj)) '.' ext_peak '.mat'];
    fprintf('loading %s\n',fname_in);
    load(fname_in);
    
    allalphapeaks(nsuj,1)                	= apeak;
    allbetapeaks(nsuj,1)                 	= bpeak(1);
    
    
end

mean_beta_peak                            	= round(nanmedian(allbetapeaks));
allbetapeaks(isnan(allbetapeaks))         	= mean_beta_peak;

mean_beta_peak                              = round(nanmedian(allbetapeaks));
allbetapeaks(isnan(allbetapeaks))          	= mean_beta_peak;

keep suj_list all*

for nsuj = 1:length(suj_list)
    
    dir_data_in              	= '~/Dropbox/project_me/data/nback/behav_h/';
    fname                     	= [dir_data_in 'sub' num2str(suj_list(nsuj)) '.behav.mat'];
    fprintf('loading %s\n',fname)
    load(fname);
    
    data_behav                  = data_behav(data_behav(:,5) == 0 & data_behav(:,1) ~= 4,[1 6 7]);
    sub_rt                      = [];
    
    for nback = [5 6]
        
        data_sub              	= data_behav(data_behav(:,1) == nback,:);
        sub_rt(nback-4)         = median(data_sub(data_sub(:,3) > 0 & rem(data_sub(:,2),2) ~= 0,3)) / 1000;
        clear data_sub
        
    end
    
    allbehav(nsuj,1)            = sub_rt(2) - sub_rt(1);
    
end

keep suj_list all*

for nsuj = 1:length(suj_list)
    
    for nback = 1:2
        
        difference_type         = 'difference';
        ext_stim              	= 'norep'; % first target allstim norep 
        baseline_correct       	= 'average'; % none single average center within
        baseline_period       	= [-0.4 -0.2];
        
        dir_data              	= '~/Dropbox/project_me/data/nback/tf/behav2tf/';
        
        % sub51.session2.2back.allstim.correct.adaptive.mtm
        
        file_name_1            	= [dir_data 'sub' num2str(suj_list(nsuj)) '.' num2str(nback) 'back.' ext_stim '.correct.adaptive.mtm.mat'];        
        file_list            	= [dir(file_name_1)]; 
        
        pow                  	= [];
        
        for nfile = 1:length(file_list)
            
            fname_in         	= [file_list(nfile).folder filesep file_list(nfile).name];
            fprintf('loading %s\n',fname_in);
            load(fname_in);
            
            % - % baseline correction
            if strcmp(baseline_correct,'single')
                t1          	= nearest(freq_comb.time,baseline_period(1));
                t2           	= nearest(freq_comb.time,baseline_period(2));
                bsl         	= nanmean(freq_comb.powspctrm(:,:,t1:t2),3);
                freq_comb.powspctrm          	= (freq_comb.powspctrm - bsl) ./ bsl ; clear bsl t1 t2;
            end
            
            pow(nfile,:,:,:) 	= freq_comb.powspctrm;
        end
        
        freq_comb.powspctrm   	= squeeze(mean(pow,1)); clear pow;
        
        % - % baseline correction
        if strcmp(baseline_correct,'average')
            t1              	= nearest(freq_comb.time,baseline_period(1));
            t2               	= nearest(freq_comb.time,baseline_period(2));
            bsl               	= nanmean(freq_comb.powspctrm(:,:,t1:t2),3);
            freq_comb.powspctrm	= (freq_comb.powspctrm - bsl) ./ bsl ; clear bsl t1 t2;
        end
        
        list_band            	= {'alpha' 'beta'};
        
        for nband = 1:length(list_band)
            
            test_band        	= list_band{nband};
            
            switch test_band
                case 'alpha'
                    f_focus  	= allalphapeaks(nsuj);
                    f_width 	= 1;
                case 'beta'
                    f_focus   	= allbetapeaks(nsuj);
                    f_width   	= 2;
            end
            
            % - % average across band of interest
            f1              	= find(round(freq_comb.freq) == round(f_focus-f_width));
            f2                	= find(round(freq_comb.freq) == round(f_focus+f_width));
            pow                 = squeeze(nanmean(freq_comb.powspctrm(:,f1:f2,:),2));
            
            avg              	= [];
            avg.time         	= freq_comb.time;
            avg.label         	= freq_comb.label;
            avg.dimord         	= 'chan_time';
            avg.avg          	= pow;
            
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

keep suj_list all* list*

%%

nbsuj                               = size(alldata,1);
[~,neighbours]                      = h_create_design_neighbours(nbsuj,alldata{1,1},'elekta','t');

cfg                                 = [];
cfg.method                          = 'montecarlo';
cfg.latency                         = [-0.1 2];
cfg.statistic                       = 'ft_statfun_correlationT';
cfg.type                            = 'Spearman';
cfg.clusterstatistics               = 'maxsum';
cfg.correctm                        = 'cluster';
cfg.clusteralpha                    = 0.05;
cfg.tail                            = 0;
cfg.clustertail                     = 0;
cfg.alpha                           = 0.025;
cfg.numrandomization                = 1000;
cfg.minnbchan                       = 2;
cfg.neighbours                      = neighbours;
cfg.ivar                            = 1;

for nbehav = 1:size(allbehav,2)
    for nband = 1:size(alldata,2)
        
        cfg.design(1,1:nbsuj)       = [allbehav(:,nbehav)];
        stat{nbehav,nband}       	= ft_timelockstatistics(cfg, alldata{:,nband});
        [min_p(nbehav,nband),p_val{nbehav,nband}]	= h_pValSort(stat{nbehav,nband});
        
    end
end

%%

plimit                              = 0.4;
nrow                                = 3;
ncol                                = 2;
i                                   = 0;

list_behav                          = {'rt'};

for nbehav = 1:size(stat,1)
    for nband = 1:size(stat,2)
        
        if min_p(nbehav,nband) < plimit
            
            nw_data                 = squeeze(alldata(:,nband));
            nw_stat                 = stat{nbehav,nband};
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
            cfg.layout              = 'neuromag306cmb.lay';
            cfg.xlim                = list_time;
            cfg.zlim                = [-0.2 0.2];
            cfg.colormap            = brewermap(256,'*RdBu');
            cfg.marker              = 'off';
            cfg.comment             = 'no';
            cfg.colorbar            = 'no';
            
            i = i + 1;
            cfg.figure              =	subplot(nrow,ncol,i);
            
            ft_topoplotER(cfg,statplot);
            title({['RT load with ' list_band{nband}], ...
                ['p = ' num2str(round(min_p(nbehav,nband),3))]});
            
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
            
%             if strcmp(test_band,'alpha')
%                 cfg.z_limit       	= [0 2e-23];
%             elseif strcmp(test_band,'beta')
%                 cfg.z_limit       	= [-0.1e-23 0.2e-23];
%             end
            
            i = i + 1;
            subplot(nrow,ncol,i)
            h_plotSingleERFstat_selectChannel_nobox(cfg,nw_stat,nw_data);
            
            hline(0,'-k');
            vline(0,'-k');
            set(gca,'FontSize',16,'FontName', 'Calibri','FontWeight','normal');
            
        end
    end
end