clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

suj_list                                        = [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    list_cond                                   = {'0back','1back','2Back'};
    list_freq                                   = 2:30;
    
    for ncond = 1:length(list_cond)
        
        list_lock                               = {'all.d'}; %'target.d','all.d','nonrand.d'
        pow                                     = [];
        
        for nlock = 1:length(list_lock)
            for nfreq = 1:length(list_freq)
                
                file_list                       = dir(['J:/temp/nback/data/sens_level_auc/cond/sub' num2str(suj_list(nsuj)) '.decoding.' ...
                    list_cond{ncond} '.agaisnt.all.' num2str(list_freq(nfreq)) 'Hz.lockedon.' list_lock{nlock} 'wn70.bsl.excl.auc.mat']);
                
                if isempty(file_list)
                    error('file not found');
                end
                
                tmp                             = [];
                
                for nf = 1:length(file_list)
                    fname                       = [file_list(nf).folder filesep file_list(nf).name];
                    fprintf('loading %s\n',fname);
                    load(fname);
                    tmp                         = [tmp;scores]; clear scores;
                end
                
                pow(nlock,nfreq,:)              = nanmean(tmp,1); clear tmp;
                
            end
        end
        
        
        freq                                    = [];
        freq.time                               =  -1.5:0.02:2;
        freq.label                              = list_lock;
        freq.freq                               = list_freq;
        freq.powspctrm                          = pow;
        freq.dimord                             = 'chan_freq_time';
        
        freq.powspctrm(isnan(freq.powspctrm))   = 0;
        
        if size(freq.powspctrm,1) ~= 2
            error('');
        end
        
        alldata{nsuj,ncond}                     = freq; clear freq pow;
        
    end
    
    alldata{nsuj,4}                             = alldata{nsuj,3};
    alldata{nsuj,4}.powspctrm(:)                = 0.5;
    
    
end

list_cond                               	= {'0back','1back','2Back','chance'};

keep alldata list_*;

list_test                               	= [1 2; 1 3; 2 3];

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
    cfg.numrandomization                        = 1000;
    cfg.uvar                                    = 1;
    cfg.ivar                                    = 2;
    
    nbsuj                                       = size(alldata,1);
    [design,neighbours]                         = h_create_design_neighbours(nbsuj,alldata{1,1},'gfp','t');
    
    cfg.design                                  = design;
    cfg.neighbours                              = neighbours;
    
    stat{ntest}                              	= ft_freqstatistics(cfg, alldata{:,list_test(ntest,1)}, alldata{:,list_test(ntest,2)});
    list_test_name{ntest}                     	= [list_cond{list_test(ntest,1)} ' v ' list_cond{list_test(ntest,2)}];
    
    
    [min_p(ntest),p_val{ntest}]                 = h_pValSort(stat{ntest});
    stat{ntest}                                 = rmfield(stat{ntest},'negdistribution');
    stat{ntest}                                 = rmfield(stat{ntest},'posdistribution');
    
end

save('../data/stat/nback.stim.cond.ag.all.contrast.mtm.mat','stat','list_test','list_test_name');

figure;

i                                           = 0;
nrow                                        = 3;
ncol                                        = 3;

plimit                                      = 0.1;
opac_lim                                    = 0.3;
z_lim                                       = 5;

list_y                                      = [0 4; 0 4; -1 1];

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
            cfg.maskstyle                  	= 'opacity';
            cfg.maskalpha                   = opac_lim;
            
            
            cfg.zlim                      	= [-z_lim z_lim];
            cfg.ylim                        = statplot.freq([1 end]);
            cfg.xlim                        = statplot.time([1 end]);
            nme                           	= statplot.label{nchan};
            
            subplot(nrow,ncol,i)
            ft_singleplotTFR(cfg,statplot);
            
            xticks([0 0.2 0.4 0.8 1]);
            yticks([6 14 22 30]);
            
            %             ylabel({[list_test_name{ntest}],statplot.label{nchan},[' p = ' num2str(round(min(min(iy)),3))],'','Frequency'});
            xlabel('Time');
            title([list_test_name{ntest} ' p = ' num2str(round(min(min(iy)),3))]);
            
            c           = colorbar;
            c.Ticks     = cfg.zlim;
            c.FontSize  = 10;
            set(gca,'FontSize',14,'FontName', 'Calibri');
            
            i                               = i + 1;
            subplot(nrow,ncol,i)
            
            avg_over_time                 	= squeeze(nanmean(tmp,3));
            avg_over_time(isnan(avg_over_time)) = 0;
            
            plot(statplot.freq,avg_over_time,'k','LineWidth',2);
            xlabel('Frequency');
            set(gca,'FontSize',14,'FontName', 'Calibri');
            
            xlim(statplot.freq([1 end]));
            ylim(list_y(ntest,:));
            yticks(list_y(ntest,:));
            
            hline(0,'-k');
            ylabel('t values');
            xticks([2 6 10 14 18 22 26 30]);
            
        end
    end
end