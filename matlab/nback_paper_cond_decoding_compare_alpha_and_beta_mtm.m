clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

suj_list                            = [1:33 35:36 38:44 46:51];
allpeaks                            = [];

for nsuj = 1:length(suj_list)
    load(['J:/nback/peak/sub' num2str(suj_list(nsuj)) '.alphabeta.peak.package.mat']);
    allpeaks(nsuj,1)                = apeak; clear apeak;
    allpeaks(nsuj,2)                = bpeak; clear bpeak;
end

allpeaks(isnan(allpeaks(:,2)),2)  	= nanmean(allpeaks(:,2));

keep suj_list allpeaks

for nsuj = 1:length(suj_list)
    
    list_freq                     	= 2:30;
    
    list_lock                    	= {'1back' '2back'}; % 'all.dwn70' 'first.dwn70' 'target.dwn70'
    
    pow                           	= [];
    
    for nfreq = 1:length(list_freq)
        for nlock = 1:length(list_lock)
            
            fname               	= ['J:/nback/sens_level_auc/cond/sub' num2str(suj_list(nsuj)) '.decoding.' list_lock{nlock} '.agaisnt.all.' ...
                num2str(list_freq(nfreq)) 'Hz.lockedon.target.dwn70.bsl.excl.auc.mat'];
            
            fprintf('loading %s\n',fname);
            load(fname);
            pow(nlock,nfreq,:)  	= scores; clear scores;
        end
    end
    
    list_peak                       = [allpeaks(nsuj,1) allpeaks(nsuj,2)];
    list_width                      = [1 2];
    i                               = 0;
    
    for nlock = 1:size(pow,1)
        
        freq                    	= [];
        freq.time               	= time_axis;
        freq.label                  = {'auc'};
        freq.freq               	= list_freq;
        freq.powspctrm            	= pow(nlock,:,:);
        freq.dimord               	= 'chan_freq_time';
        
        i                           = i + 1;
        alldata{nsuj,i}             = freq; clear freq;
        
        
    end
    
    keep alldata nsuj suj_list allpeaks
    
end

keep alldata

list_test                                       = [1 2];

for ntest = 1:size(list_test,1)
    
    cfg                                         = [];
    cfg.statistic                               = 'ft_statfun_depsamplesT';
    cfg.method                                  = 'montecarlo';
    cfg.correctm                                = 'cluster';
    cfg.clusteralpha                            = 0.05;
    cfg.latency                                 = [0 1];
    cfg.frequency                               = [2 30];
    cfg.clusterstatistic                        = 'maxsum';
    cfg.minnbchan                               = 0;
    cfg.tail                                    = 0;
    cfg.clustertail                             = 0;
    cfg.alpha                                   = 0.025;
    cfg.numrandomization                        = 5000;
    cfg.uvar                                    = 1;
    cfg.ivar                                    = 2;
    
    nbsuj                                       = size(alldata,1);
    [design,neighbours]                         = h_create_design_neighbours(nbsuj,alldata{1,1},'gfp','t');
    
    cfg.design                                  = design;
    cfg.neighbours                              = neighbours;
    
    stat{ntest}                              	= ft_freqstatistics(cfg, alldata{:,list_test(ntest,1)}, alldata{:,list_test(ntest,2)});    
    
    [min_p(ntest),p_val{ntest}]                 = h_pValSort(stat{ntest});
    stat{ntest}                                 = rmfield(stat{ntest},'negdistribution');
    stat{ntest}                                 = rmfield(stat{ntest},'posdistribution');
    
end

%%

figure;

i                                           = 0;
nrow                                        = 2;
ncol                                        = 2;

plimit                                      = 0.1;
opac_lim                                    = 0.3;
z_lim                                       = 5;

list_y                                      = [-1 0];

for ntest = 1:length(stat)
    
    statplot                             	= stat{ntest};
    statplot.mask                           = statplot.prob < plimit;
    
    for nchan = 1:length(statplot.label)
        
        tmp                             	= statplot.mask(nchan,:,:) .* statplot.prob(nchan,:,:);
        iy                               	= unique(tmp);
        iy                                 	= iy(iy~=0);
        iy                                 	= iy(~isnan(iy));
        
        tmp                             	= statplot.mask(nchan,:,:) .* statplot.stat(nchan,:,:);
        ix                               	= unique(tmp);
        ix                                 	= ix(ix~=0);
        ix                                 	= ix(~isnan(ix));
        
        if ~isempty(ix)
            
            i                             	= i + 1;
            
            cfg                            	= [];
            cfg.colormap                  	= brewermap(256, '*RdBu');
            cfg.channel                   	= nchan;
            cfg.parameter                  	= 'prob';
            cfg.maskparameter            	= 'mask';
            cfg.maskstyle                  	= 'outline';
            cfg.maskstyle                  	= 'opacity';
            cfg.maskalpha                   = opac_lim;
            
            cfg.zlim                      	= [0 plimit];
            cfg.ylim                        = statplot.freq([1 end]);
            cfg.xlim                        = statplot.time([1 end]);
            nme                           	= statplot.label{nchan};
            
            subplot(nrow,ncol,i)
            ft_singleplotTFR(cfg,statplot);
            
            xticks([0 0.2 0.4 0.6 0.8 1]);
            yticks([6 14 22 30]);
            
            %             ylabel({[list_test_name{ntest}],statplot.label{nchan},[' p = ' num2str(round(min(min(iy)),3))],'','Frequency'});
            xlabel('Time');
            title([' p = ' num2str(round(min(min(iy)),3))]);
            
            c           = colorbar;
            c.Ticks     = cfg.zlim;
            c.FontSize  = 10;
            set(gca,'FontSize',12,'FontName', 'Calibri');
            
            i                               = i + 1;
            subplot(nrow,ncol,i)
            
            avg_over_time                 	= squeeze(nanmean(tmp,3));
            avg_over_time(isnan(avg_over_time)) = 0;
            
            plot(statplot.freq,avg_over_time,'k','LineWidth',2);
            xlabel('Frequency');
            set(gca,'FontSize',12,'FontName', 'Calibri');
            
            xlim(statplot.freq([1 end]));
            ylim(list_y(ntest,:));
            yticks(list_y(ntest,:));
            
            hline(0,'-k');
            ylabel('t values');
            xticks([2 6 10 14 18 22 26 30]); clc;
            
        end
    end
end