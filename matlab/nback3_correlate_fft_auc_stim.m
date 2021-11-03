clear;clc;

suj_list                          	= [1:33 35:36 38:44 46:51];
ext_decode                          = 'stim';
list_cond                           = {'allstim.pre' 'allstim.post'}; % {'target.pre' 'target.post' 'first.pre' 'first.post'};% 

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
    
    sujname                           	= ['sub' num2str(suj_list(nsuj))];
    
    dir_files                          	= '~/Dropbox/project_me/data/nback/'; %'P:/3035002.01/nback/';
    flist                               = dir([dir_files 'auc/' sujname '.decoding.stim*.nodemean.leaveone.mat']);
        
    for nstim = 1:length(flist)
        
        % load decoding output
        fname                        	= [flist(nstim).folder filesep flist(nstim).name];
        fprintf('loading %s\n',fname);
        load(fname,'y_array','yproba_array','time_axis','e_array');
        
        % transpose matrices
        y_array                     	= y_array';
        yproba_array                  	= yproba_array';
        e_array                      	= e_array';
        measure                      	= 'yproba'; % auc yproba
        
        idx_trials                      = 1:size(yproba_array,1);
        
        AUC_bin_test                 	= [];
        disp('computing AUC');
        
        for ntime = 1:size(y_array,2)
            
            if strcmp(measure,'yproba')
                
                yproba_array_test     	= yproba_array(idx_trials,ntime);
                
                if min(unique(y_array(:,ntime))) == 1
                    yarray_test        	= y_array(idx_trials,ntime) - 1;
                else
                    yarray_test       	= y_array(idx_trials,ntime);
                end
                
                [~,~,~,AUC_bin_test(ntime)]	= perfcurve(yarray_test,yproba_array_test,1);
                
            elseif strcmp(measure,'auc')
                AUC_bin_test(ntime)     = mean(e_array(idx_trials,ntime));
            end
        end
        
        avg                             = [];
        avg.avg                         = AUC_bin_test;
        avg.time                        = time_axis;
        avg.label                       = {['decoding ' ext_decode]};
        avg.dimord                      = 'chan_time';
        
        tmp{nstim}                      = avg; clear avg;
        
    end
    
    alldata{nsuj,1}                     = ft_timelockgrandaverage([],tmp{:}); clear tmp;
    
end

%%

cfg                         = [];
cfg.method                  = 'montecarlo';
cfg.latency                 = [0 1];
cfg.statistic               = 'ft_statfun_correlationT';
cfg.clusterstatistics       = 'maxsum';
cfg.correctm                = 'cluster';
cfg.clusteralpha            = 0.05;
cfg.tail                    = 0;
cfg.clustertail             = 0;
cfg.alpha                   = 0.025;
cfg.numrandomization        = 1000;
cfg.ivar                    = 1;
cfg.type                    = 'Spearman';

nb_suj                      = size(alldata,1);
[~,neighbours]              = h_create_design_neighbours(nb_suj,alldata{1,1},'gfp','t');
cfg.neighbours              = neighbours;

for ncond = 1:size(allfft,2)
    for nband = 1:size(allfft,3)
        
        cfg.design(1,1:nb_suj)      = [allfft{:,ncond,nband}];
        
        stat{ncond,nband} 	= ft_timelockstatistics(cfg, alldata{:});
        [min_p(ncond,nband),p_val{ncond,nband}]         = h_pValSort(stat{ncond,nband});
        
    end
end

%%

i                                       = 0;
nrow                                    = size(stat,2);
ncol                                    = size(stat,1);
plimit                                  = 0.15;

for nband = 1:size(stat,2)
    for ncond = 1:size(stat,1)
        
        
        statplot                        = stat{ncond,nband};
        statplot.mask               	= statplot.prob < plimit;
        
        for nchan = 1:length(statplot.label)
            
            tmp                     	= statplot.mask(nchan,:,:) .* statplot.rho(nchan,:,:);
            iy                        	= unique(tmp);
            iy                       	= iy(iy~=0);
            
            tmp                         = statplot.mask(nchan,:,:) .* statplot.prob(nchan,:,:);
            ix                          = unique(tmp);
            ix                          = ix(ix~=0);
            
            i                           = i + 1;
            subplot(nrow,ncol,i)
            
            cfg                         = [];
            cfg.channel                 = nchan;
            cfg.p_threshold             = plimit;
            
            cfg.time_limit              = [-0.1 1];
            list_color                  = 'k';
            cfg.color                   = list_color(nchan);
            cfg.lineshape               = '-r';
            cfg.linewidth               = 5;
            
            if strcmp(ext_decode,'condition')
                cfg.z_limit     	= [0.2 0.6];
            elseif strcmp(ext_decode,'target')
                cfg.z_limit       	= [0.2 1];
            elseif strcmp(ext_decode,'first')
                cfg.z_limit       	= [0.1 0.4];
            elseif strcmp(ext_decode,'stim')
                cfg.z_limit       	= [0.05 0.2];
            end
            
            h_plotSingleERFstat_selectChannel_nobox(cfg,statplot,alldata);
            
            if strcmp(ext_decode,'condition')
                hline(0.35,'--k');
            elseif strcmp(ext_decode,'target')
                hline(0.35,'--k');
            elseif strcmp(ext_decode,'first')
                hline(0.17,'--k');
            elseif strcmp(ext_decode,'stim')
                hline(0.07,'--k');
            end
            
            ylabel(statplot.label{nchan});
            
            title({[list_band{nband} ' ' list_cond{ncond}],['p = ' num2str(round(min(ix),3)) ' r = ' num2str(round(min(iy),1))]});
            set(gca,'FontSize',16,'FontName', 'Calibri');
            vline(0,'--k');
            
            
            
        end
    end
end