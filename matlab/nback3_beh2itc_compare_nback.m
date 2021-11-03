clear;clc;

suj_list                      	= [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    dir_data                  	= '~/Dropbox/project_me/data/nback/peak/';
    
    fname_in                	= [dir_data 'sub' num2str(suj_list(nsuj)) '.alphabeta.peak.package.0back.equalhemi.mat'];
    fprintf('loading %s\n',fname_in);
    load(fname_in);
    
    allalphapeaks(nsuj,1)     	= apeak;
    allbetapeaks(nsuj,1)      	= bpeak;
    
end

for nsuj = 1:length(suj_list)
    
    list_cond                   = {'1back' '2back.sub'}; % {'1back' '2back.sub'}; %
    list_band                 	= {'alpha' 'beta'};
    
    for ncond = [1 2]
        
        % for target and allstim effect 2back > 1back
        % only for alpha
        
        list_stim             	= 'allstim.allbehav';
        
        dir_data              	= '~/Dropbox/project_me/data/nback/tf/itc/';
        flist                   = [dir_data 'sub' num2str(suj_list(nsuj)) '.' list_cond{ncond} '.' list_stim];
        flist               	= [flist '.itc.withevoked.mat'];
        flist                   = dir(flist);
        
        itc                     = [];
        
        for nfile = 1:length(flist)
            
            fname_in            = [flist(nfile).folder filesep flist(nfile).name];
            fprintf('loading %s\n',fname_in);
            load(fname_in);
            
            itc(nfile,:,:,:)    = phase_lock.powspctrm;
            
        end
        
        itc                     = squeeze(nanmean(itc,1));
        
        for nband = [1 2]
            
            test_band           = list_band{nband};
            
            switch test_band
                case 'alpha'
                    f_focus     = allalphapeaks(nsuj);
                    f_width     = 1;
                case 'beta'
                    f_focus     = allbetapeaks(nsuj);
                    f_width     = 2;
            end
            
            f1                  = nearest(phase_lock.freq,f_focus-f_width);
            f2                  = nearest(phase_lock.freq,f_focus+f_width);
            itc_select         	= squeeze(nanmean(itc(:,f1:f2,:),2));
            
            % baseline correct in time
            t1                  = nearest(phase_lock.time,-1);
            t2                  = nearest(phase_lock.time,2);
            bsl              	= squeeze(nanmean(squeeze(nanmean(itc(:,f1:f2,t1:t2),3)),2));
            
            avg                 = [];
            avg.time            = phase_lock.time;
            avg.label           = phase_lock.label;
            avg.dimord          = 'chan_time';
            avg.avg             = itc_select; %itc_select ./ bsl; % 
            
            alldata{nsuj,nband,ncond} 	= avg; clear avg;
            
        end
        
        
        
    end
    
end

%%

keep alldata list_*

nbsuj                         	= size(alldata,1);
[design,neighbours]            	= h_create_design_neighbours(nbsuj,alldata{1,1},'elekta','t');

for nband = 1:size(alldata,2)
    
    cfg                        	= [];
    cfg.latency                	= [-1 2];
    cfg.statistic              	= 'ft_statfun_depsamplesT';
    cfg.method                	= 'montecarlo';
    cfg.correctm             	= 'cluster';
    cfg.clusteralpha          	= 0.05;
    cfg.clusterstatistic      	= 'maxsum';
    cfg.minnbchan             	= 3; % important %
    cfg.tail                  	= 0;
    cfg.clustertail           	= 0;
    cfg.alpha                 	= 0.025;
    cfg.numrandomization      	= 1000;
    cfg.uvar                  	= 1;
    cfg.ivar                  	= 2;
    cfg.neighbours            	= neighbours;
    cfg.design                 	= design;
    stat{nband}               	= ft_timelockstatistics(cfg,alldata{:,nband,1},alldata{:,nband,2});
    [min_p(nband),p_val{nband}]	= h_pValSort(stat{nband});clc;
    
end

close all;

%%

plimit                        	= 0.1;

close all;

nrow                         	= 2;
ncol                         	= 2;
i                             	= 0;

for nband = 1:length(stat)
    
    if min_p(nband) < plimit
        
        
        nw_data                	= squeeze(alldata(:,nband,:));
        nw_stat               	= stat{nband};
        
        nw_stat.mask            = nw_stat.prob < plimit;
        
        statplot              	= [];
        statplot.avg          	= nw_stat.mask .* nw_stat.stat;
        statplot.label       	= nw_stat.label;
        statplot.dimord      	= nw_stat.dimord;
        statplot.time        	= nw_stat.time;
        
        find_sig_time        	= mean(statplot.avg,1);
        find_sig_time         	= find(find_sig_time ~= 0);
        list_time             	= [min(statplot.time(find_sig_time)) max(statplot.time(find_sig_time))];
        
        cfg                    	= [];
        cfg.layout           	= 'neuromag306cmb.lay';
        cfg.xlim             	= list_time;
        cfg.zlim               	= [-3 3];
        cfg.colormap           	= brewermap(256,'*PuOr');
        cfg.marker            	= 'off';
        cfg.comment           	= 'no';
        cfg.colorbar           	= 'yes';
        
        i = i + 1;
        cfg.figure            	= subplot(nrow,ncol,i);
        ft_topoplotER(cfg,statplot);
        title({[list_band{nband}],['p = ' num2str(round(min_p(nband),3))]});
        
        set(gca,'FontSize',14,'FontName', 'Calibri','FontWeight','normal');
        
        find_sig_chan          	= mean(statplot.avg,2);
        find_sig_chan         	= find(find_sig_chan ~= 0);
        list_chan              	= nw_stat.label(find_sig_chan);
        
        cfg                   	= [];
        cfg.channel           	= list_chan;
        cfg.time_limit       	= nw_stat.time([1 end]);
        cfg.color            	= [83 51 137; 197 94 32]; % [58 161 122; 47 123 182];
        cfg.color             	= cfg.color ./ 256;
        
        cfg.lineshape          	= '-x';
        
        test_band             	= list_band{nband};
        
        fix_z                   = 0.1;
        cfg.z_limit          	= [0.0 0.4];
        
        
        cfg.linewidth          	= 10;
        i = i + 1;
        subplot(nrow,ncol,i)
        h_plotSingleERFstat_selectChannel_nobox(cfg,nw_stat,nw_data);
        
        legend({list_cond{1} '' list_cond{2} ''});
        
        xlim(statplot.time([1 end]));
        
        hline(0,'-k');
        hline(1,'-k');
        
        vline([0 0.5],'-k');
        
        set(gca,'FontSize',16,'FontName', 'Calibri','FontWeight','normal');
        
    end
end