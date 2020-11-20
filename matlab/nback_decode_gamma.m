clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

suj_list                         	= [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    list_freq                       = 20:2:100;
    
    for nback = 1:2
        
        list_lock                   = {'target.4'}; % 'all.4','nonrand.4','first.4',
        pow                         = [];
        
        for nlock = 1:length(list_lock)
            for nfreq = 1:length(list_freq)
                
                file_list         	= dir(['J:/temp/nback/data/sens_level_auc/cond/sub' num2str(suj_list(nsuj)) '.sess' num2str(nback) '.decoding.' ...
                    num2str(nback-1) 'back.' num2str(list_freq(nfreq)) 'Hz.lockedon.' list_lock{nlock} 'gamma.auc.mat']);
                
                tmp              	= [];
                
                for nf = 1:length(file_list)
                    fname         	= [file_list(nf).folder filesep file_list(nf).name];
                    fprintf('loading %s\n',fname);
                    load(fname);
                    tmp           	= [tmp;scores]; clear scores;
                end
                
                pow(nlock,nfreq,:) 	= nanmean(tmp,1); clear tmp;
                
            end
        end
        
        
        freq                    	= [];
        freq.time               	= -0.5:0.04:2;
        freq.label              	= list_lock;
        freq.freq                	= list_freq;
        freq.powspctrm           	= pow;
        freq.dimord                 = 'chan_freq_time';
        
        if size(freq.powspctrm,1) ~= 2
            error('');
        end
        
        alldata{nsuj,nback}     	= freq; clear freq pow;
        
    end
    
    alldata{nsuj,3}                             = alldata{nsuj,2};
    alldata{nsuj,3}.powspctrm(:)             	= 0.5;
    
    
end

list_cond                                       = {'0v2Back','1v2Back','chance'};

keep alldata list_*;

list_test                                   = [1 3; 2 3; 1 2];

for ntest = 1:size(list_test,1)
    
    cfg                                    	= [];
    cfg.statistic                          	= 'ft_statfun_depsamplesT';
    cfg.method                            	= 'montecarlo';
    cfg.correctm                          	= 'cluster';
    cfg.clusteralpha                      	= 0.05;
    %     cfg.latency                                 = [0 1];
    %     cfg.frequency                               = [2 30];
    cfg.clusterstatistic                  	= 'maxsum';
    cfg.minnbchan                         	= 0;
    cfg.tail                              	= 0;
    cfg.clustertail                        	= 0;
    cfg.alpha                             	= 0.025;
    cfg.numrandomization                 	= 1000;
    cfg.uvar                               	= 1;
    cfg.ivar                             	= 2;
    
    nbsuj                                  	= size(alldata,1);
    [design,neighbours]                    	= h_create_design_neighbours(nbsuj,alldata{1,1},'gfp','t');
    
    cfg.design                            	= design;
    cfg.neighbours                         	= neighbours;
    
    
    stat{ntest}                           	= ft_freqstatistics(cfg, alldata{:,list_test(ntest,1)}, alldata{:,list_test(ntest,2)});
    list_test_name{ntest}                 	= [list_cond{list_test(ntest,1)} ' v ' list_cond{list_test(ntest,2)}];
    
    
    [min_p(ntest),p_val{ntest}]         	= h_pValSort(stat{ntest});
    stat{ntest}                          	= rmfield(stat{ntest},'negdistribution');
    stat{ntest}                           	= rmfield(stat{ntest},'posdistribution');
    
end

figure;

i                                           = 0;
nrow                                        = 6;
ncol                                        = 2;

plimit                                      = 0.2;
opac_lim                                    = 0.3;
z_lim                                       = 5;

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
            cfg.parameter                  	= 'stat';
            cfg.maskparameter            	= 'mask';
            cfg.maskstyle                  	= 'outline';
            
            cfg.zlim                      	= [-z_lim z_lim];
            cfg.ylim                        = statplot.freq([1 end]);
            cfg.xlim                        = statplot.time([1 end]);
            nme                           	= statplot.label{nchan};
            
            subplot(nrow,ncol,i)
            ft_singleplotTFR(cfg,statplot);
            
            ylabel(statplot.label{nchan});
            xlabel('Time');
            title([list_test_name{ntest} ' p = ' num2str(round(min(min(iy)),3))]);
                        
            c           = colorbar;
            c.Ticks     = cfg.zlim;
            c.FontSize  = 10;
            set(gca,'FontSize',14,'FontName', 'Calibri');
            
            i                               = i + 1;
            subplot(nrow,ncol,i)
            avg_over_time                 	= squeeze(nanmean(tmp,3));
            
            plot(statplot.freq,avg_over_time,'LineWidth',2);
            xlabel('Frequency');
            set(gca,'FontSize',14,'FontName', 'Calibri');
            xlim(statplot.freq([1 end]));
            ylabel('t values');
            
            xticks(statplot.freq([1:4:end]));
            
        end
    end
end