clear;clc;

suj_list                          	= [1:33 35:36 38:44 46:51];
ext_erf                             = 'target';

list_cond                           = {[ext_erf '.pre'] [ext_erf '.post']};% 

for nsuj = 1:length(suj_list)
    
    fname_in                    	= ['~/Dropbox/project_me/data/nback/peak/sub' num2str(suj_list(nsuj)) '.alphabeta.peak.package.0back.mat'];
    fprintf('loading %s\n',fname_in);
    load(fname_in);
    
    alphapeaks(nsuj,1)              = apeak;
    betapeaks(nsuj,1)               = bpeak;
    
    maxchannels{nsuj}               = max_chan;
    
end

mean_beta_peak                      = round(nanmedian(betapeaks));
betapeaks(isnan(betapeaks))         = mean_beta_peak;

%%

for nsuj = 1:length(suj_list)
    
    list_band                   = {'alpha' 'beta'};
    
    for ncond = 1:length(list_cond)
        
        dir_data              	= '~/Dropbox/project_me/data/nback/corr/fft/';
        fname_in             	= [dir_data 'sub' num2str(suj_list(nsuj)) '.allback.allbehav.' list_cond{ncond} '.fft.mat'];
        
        fprintf('loading %s\n',fname_in);
        load(fname_in);
        
        chan_focus              = [];
        
        for nchan = 1:length(maxchannels{nsuj})
            chan_focus          = [chan_focus; find(strcmp(maxchannels{nsuj}{nchan},freq_comb.label))];
        end
        
        clear nchan;
        
        for nband = 1:length(list_band)
            
            test_band           = list_band{nband};
            
            switch test_band
                case 'alpha'
                    f_focus   	= alphapeaks(nsuj);
                    f_width  	= 1;
                case 'beta'
                    f_focus    	= betapeaks(nsuj);
                    f_width    	= 2;
                    
            end
            
            f1                 	= nearest(freq_comb.freq,f_focus-f_width);
            f2                	= nearest(freq_comb.freq,f_focus+f_width);
            
            pow                	= nanmean((nanmean(freq_comb.powspctrm(chan_focus,f1:f2))));
            
            allfft{nsuj,ncond,nband}    = pow; clear pow f1 f2 f_width f_focus
            
        end
        
    end
end

%%

for nsuj = 1:length(suj_list)    
    
    dir_data          	= '~/Dropbox/project_me/data/nback/corr/erf/';
    fname_in         	= [dir_data 'sub' num2str(suj_list(nsuj)) '.allback.allbehav.' ext_erf '.erfComb.mat'];
    
    fprintf('loading %s\n',fname_in);
    load(fname_in,'avg_comb');
    
    t1                	= nearest(avg_comb.time,-0.1);
    t2              	= nearest(avg_comb.time,0);
    bsl              	= mean(avg_comb.avg(:,t1:t2),2);
    avg_comb.avg     	= avg_comb.avg - bsl ; clear bsl t1 t2;
    
    alldata{nsuj,1}   	= avg_comb; clear avg_comb;
    
end

%%

nbsuj                     	= size(alldata,1);
[~,neighbours]             	= h_create_design_neighbours(nbsuj,alldata{1,1},'elekta','t');

cfg                         = [];
cfg.method                  = 'montecarlo';
cfg.latency                 = [0 0.5];
cfg.statistic               = 'ft_statfun_correlationT';
cfg.type                    = 'Spearman';
cfg.clusterstatistics       = 'maxsum';
cfg.correctm                = 'cluster';
cfg.clusteralpha            = 0.05;
cfg.tail                    = 0;
cfg.clustertail             = 0;
cfg.alpha                   = 0.025;
cfg.numrandomization        = 1000;
cfg.minnbchan            	= 3;
cfg.neighbours            	= neighbours;
cfg.ivar                    = 1;

for ncond = 1:size(allfft,2)
    for nband = 1:size(allfft,3)
        
        cfg.design(1,1:nbsuj)      = [allfft{:,ncond,nband}];
        
        stat{ncond,nband} 	= ft_timelockstatistics(cfg, alldata{:});
        [min_p(ncond,nband),p_val{ncond,nband}]         = h_pValSort(stat{ncond,nband});
        
    end
end

%%

plimit                      = 0.15;
nb_sig                      = length(find(min_p < plimit));

nrow                        = 2;
ncol                        = nb_sig * 2;
i                           = 0;


for nband = 1:size(stat,2)
    for ncond = 1:size(stat,1)
        
        if min_p(ncond,nband) < plimit
            
            nw_data         	= alldata;
            nw_stat           	= stat{ncond,nband};
            nw_stat.mask     	= nw_stat.prob < plimit;
            
            statplot         	= [];
            statplot.avg     	= nw_stat.mask .* nw_stat.rho;
            statplot.label    	= nw_stat.label;
            statplot.dimord   	= nw_stat.dimord;
            statplot.time     	= nw_stat.time;
            
            find_sig_time     	= mean(statplot.avg,1);
            find_sig_time     	= find(find_sig_time ~= 0);
            list_time         	= [min(statplot.time(find_sig_time)) max(statplot.time(find_sig_time))];
            
            cfg               	= [];
            cfg.layout        	= 'neuromag306cmb.lay';
            cfg.xlim         	= list_time;
            cfg.zlim        	= [-0.2 0.2];
            cfg.colormap        = brewermap(256,'*RdBu');
            cfg.marker       	= 'off';
            cfg.comment      	= 'no';
            cfg.colorbar      	= 'no';
            
            i = i + 1;
            subplot(nrow,ncol,i)
            ft_topoplotER(cfg,statplot);
            title({[list_band{nband} ' ' list_cond{ncond}], ...
                ['p = ' num2str(round(min_p(ncond,nband),3))]});
            
            set(gca,'FontSize',14,'FontName', 'Calibri','FontWeight','normal');
            
            find_sig_chan       = mean(statplot.avg,2);
            find_sig_chan   	= find(find_sig_chan ~= 0);
            list_chan         	= nw_stat.label(find_sig_chan);
            
            cfg                 = [];
            cfg.channel      	= list_chan;
            cfg.time_limit  	= [-0.1 1]; % nw_stat.time([1 end]);
            cfg.color        	= [0 0 0];
            cfg.lineshape     	= '-k';
            cfg.linewidth    	= 10;
            cfg.z_limit      	= [-0.5e-12 5.5e-12];
            i = i + 1;
            subplot(nrow,ncol,i)
            h_plotSingleERFstat_selectChannel_nobox(cfg,nw_stat,nw_data);
            
            hline(0,'-k');
            vline(0,'-k');
            set(gca,'FontSize',16,'FontName', 'Calibri','FontWeight','normal');
            
        end
        
        
    end
end