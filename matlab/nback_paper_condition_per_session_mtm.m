clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

suj_list                                    = [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    list_cond                               = {'0back','1back'};
    list_freq                               = 2:30;
    
    for nback = 1:length(list_cond)
        
        list_lock                           = {'all.b','target.b','nonrand.b','first.b'};
        
        pow                                 = [];
        
        for nfreq = 1:length(list_freq)
            for nlock = 1:length(list_lock)
                fname                       = ['J:/temp/nback/data/sens_level_auc/cond/sub' num2str(suj_list(nsuj)) '.sess' num2str(nback) '.decoding.' ...
                    list_cond{nback} '.' num2str(list_freq(nfreq)) 'Hz.lockedon.' list_lock{nlock} 'sl.excl.auc.mat'];
                fprintf('loading %s\n',fname);
                load(fname);
                pow(nlock,nfreq,:)          = scores; clear scores;
            end
        end
        
        freq                                    = [];
        freq.time                               =  -1.5:0.02:2;
        freq.label                              = list_lock;
        freq.freq                               = list_freq;
        freq.powspctrm                          = pow;
        freq.dimord                             = 'chan_freq_time';
        
        if size(freq.powspctrm,1) ~= 2
            error('');
        end
        
        alldata{nsuj,nback}                     = freq; clear freq pow;
        
    end
    
    alldata{nsuj,3}                         = alldata{nsuj,1};
    alldata{nsuj,3}.powspctrm(:)            = 0.5;
    
    for nback = 1:3
        if size(alldata{nsuj,nback}.powspctrm,1) ~= 2
            error('');
        end
    end
    
end

keep alldata list_*;

list_cond                                       = {'0and2','1and2','chance'};
list_test                                       = [1 2];

for ntest = 1:size(list_test,1)
    cfg                                         = [];
    cfg.statistic                               = 'ft_statfun_depsamplesT';
    cfg.method                                  = 'montecarlo';
    cfg.correctm                                = 'cluster';
    cfg.clusteralpha                            = 0.05;
    cfg.latency                                 = [-0.1 1.5];
    cfg.frequency                               = [3 30];
    cfg.clusterstatistic                        = 'maxsum';
    cfg.minnbchan                               = 0;
    cfg.tail                                    = 0;
    cfg.clustertail                             = 0;
    cfg.alpha                                   = 0.025;
    cfg.numrandomization                        = 1000;
    cfg.uvar                                    = 1;
    cfg.ivar                                    = 2;
    
    nbsuj                                       = size(alldata,1);
    [design,neighbours]                         = h_create_design_neighbours(nbsuj,alldata{1,1},'gfp','t');
    
    cfg.design                                  = design;
    cfg.neighbours                              = neighbours;
    
    
    stat{ntest}                                = ft_freqstatistics(cfg, alldata{:,list_test(ntest,1)}, alldata{:,list_test(ntest,2)});
    list_test_name{ntest}                      = [list_cond{list_test(ntest,1)} ' v ' list_cond{list_test(ntest,2)}];
    
    
    [min_p(ntest),p_val{ntest}]                	= h_pValSort(stat{ntest});
    stat{ntest}                              	= rmfield(stat{ntest},'negdistribution');
    stat{ntest}                              	= rmfield(stat{ntest},'posdistribution');
end

figure;

i                                           = 0;
nrow                                        = 4
ncol                                        = 2;

plimit                                      = 0.2;

for ntest = 1:length(stat)
    
    statplot                             	= stat{ntest};
    statplot.mask                           = statplot.prob < plimit;
    
    for nc = 1:length(statplot.label)
        
        tmp                             	= statplot.mask(nc,:,:) .* statplot.prob(nc,:,:);
        iy                               	= unique(tmp);
        iy                                 	= iy(iy~=0);
        iy                                 	= iy(~isnan(iy));
        
        tmp                             	= statplot.mask(nc,:,:) .* statplot.stat(nc,:,:);
        ix                               	= unique(tmp);
        ix                                 	= ix(ix~=0);
        ix                                 	= ix(~isnan(ix));
        
        if ~isempty(ix)
            
            i                             	= i + 1;
            
            cfg                            	= [];
            cfg.colormap                  	= brewermap(256, '*RdBu');
            cfg.channel                   	= nc;
            cfg.parameter                  	= 'stat';
            cfg.maskparameter            	= 'mask';
            cfg.maskstyle                  	= 'outline';
            cfg.zlim                      	= [-5 5];
            cfg.ylim                        = statplot.freq([1 end]);
            cfg.xlim                        = [-0.2 2];
            nme                           	= statplot.label{nc};
            
            subplot(nrow,ncol,i)
            ft_singleplotTFR(cfg,statplot);
            vline(0,'--k');
            
            %' ' statplot.label{nc}
            ylabel(nme);
            xlabel('Time');
            title([list_test_name{ntest} ' p = ' num2str(round(min(min(iy)),3))]);
            
            c           = colorbar;
            c.Ticks     = cfg.zlim;
            c.FontSize  = 10;
            
            set(gca,'FontSize',14,'FontName', 'Calibri');
            
            avg_over_time                 	= squeeze(nanmean(tmp,3));
            i                               = i + 1;
            subplot(nrow,ncol,i)
            
            plot(statplot.freq,avg_over_time,'k','LineWidth',2);
            xlabel('Frequency');
            grid on;
            set(gca,'FontSize',14,'FontName', 'Calibri');
            xlim(statplot.freq([1 end]));
            ylim([0 3]);
            yticks([0 3]);
            ylabel('t values');
            
        end
    end
end