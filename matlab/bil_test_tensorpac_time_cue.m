clear ; clc;

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    cu_list = {'pre.cue' 'retro.cue'};
    
    for ncond = 1:2
        subjectName                         = suj_list{nsuj};
        
        fname_out                           = ['F:/bil/pac/' subjectName '.3t5Hz.gc.pac.' cu_list{ncond} '.maxchan.mat'];
        fprintf('loading %s\n',fname_out);
        load(fname_out);
        
        freq                                = [];
        freq.powspctrm(1,:,:)               = py_pac.powspctrm;
        freq.time                           = py_pac.time;
        freq.freq                           = py_pac.freq;
        freq.label                          = {'pac gc'};
        freq.dimord                         = 'chan_freq_time';
        
        alldata{nsuj,ncond}                 = freq; clear avg;
        
    end
end

list_test                               	= [1 2]; 

for nt = 1:size(list_test,1)
    
    cfg                                   	= [];
    cfg.statistic                         	= 'ft_statfun_depsamplesT';
    cfg.method                          	= 'montecarlo';
    cfg.correctm                         	= 'cluster';
    cfg.clusteralpha                      	= 0.05;
    cfg.latency                          	= [-0.1 6];
    cfg.frequency                        	= [7 30];
    cfg.clusterstatistic                  	= 'maxsum';
    cfg.minnbchan                          	= 0;
    cfg.tail                             	= 0;
    cfg.clustertail                       	= 0;
    cfg.alpha                             	= 0.025;
    cfg.numrandomization                    = 1000;
    cfg.uvar                            	= 1;
    cfg.ivar                             	= 2;
    
    nbsuj                               	= size(alldata,1);
    [design,neighbours]                 	= h_create_design_neighbours(nbsuj,alldata{1,1},'gfp','t');
    
    cfg.design                          	= design;
    cfg.neighbours                          = neighbours;
    
    stat{nt}                                = ft_freqstatistics(cfg, alldata{:,list_test(nt,1)}, alldata{:,list_test(nt,2)});
end

for ntest = 1:length(stat)
    [min_p(ntest),p_val{ntest}]         	= h_pValSort(stat{ntest});
end

figure;

i                                           = 0;
nrow                                        = 2;
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
            
            ylabel(nme);
            xlabel('Time');
            title(['p = ' num2str(round(min(min(iy)),3))]);
            
            xticks([0 1.5 3 4.5 5.5]);
            xticklabels({'1st cue' '1st gab' '2nd cue' '2nd gab' 'mean RT'});
            vline([0 1.5 3 4.5 5.5],'--k');
            
            set(gca,'FontSize',14,'FontName', 'Calibri');
            
            i                               = i + 1;
            subplot(nrow,ncol,i)
            avg_over_time                 	= squeeze(nanmean(tmp,3));            
            plot(statplot.freq,avg_over_time,'LineWidth',2);
            xlabel('Frequency');
            set(gca,'FontSize',14,'FontName', 'Calibri');
            xlim(statplot.freq([1 end]));
            ylabel('t values');
            
        end
    end
end