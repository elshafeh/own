clear;clc;
clc; global ft_default;
ft_default.spmversion = 'spm12';

load /Users/heshamelshafei/Dropbox/project_me/data/bil/virt/sub001.virtualelectrode.wallis.mat;
chan_list = data.label; clear data;

load ../data/bil_goodsubjectlist.27feb20.mat

lim_suj     = length(dir('~/Dropbox/project_me/data/bil/virt/*.wallis.5t6Hz.chan22.gc.correct.pac.mat'));

for nsuj = 1:length(suj_list)
    
    subjectName                            	= suj_list{nsuj};
    list_low                               	= {'1t2Hz' '2t3Hz' '3t4Hz' '4t5Hz' '3t5Hz' };
    
    for nfreq = 1:length(list_low)
        
        freq                              	= [];
        freq.powspctrm                   	= [];
        
        for nchan = 1:22
            
            fname                         	= ['~/Dropbox/project_me/data/bil/virt/' subjectName '.wallis.' ...
                list_low{nfreq} '.chan' num2str(nchan) '.gc.correct.pac.mat'];
            fprintf('loading %s\n',fname);
            load(fname);
            
            freq.powspctrm(nchan,:,:)      	= py_pac.powspctrm;
            freq.time                     	= py_pac.time;
            freq.freq                     	= py_pac.freq;
            freq.label                    	= chan_list;
            freq.dimord                  	= 'chan_freq_time';
            
        end
        
        period_baseline                  	= [-0.4 -0.2];
        period_interest                  	= [-0.2 5.5];
        freq_interest                       = [5 40];
        [act,bsl]                           = h_prepareBaseline(freq,freq_interest,period_baseline,period_interest,'na');
        alldata{nsuj,nfreq,1}            	= act; clear act;
        alldata{nsuj,nfreq,2}             	= bsl; clear bsl;
    end
    
end

%%

keep alldata list_low

for ntest = 1:size(alldata,2)
    
    cfg                                   	= [];
    cfg.statistic                         	= 'ft_statfun_depsamplesT';
    cfg.method                          	= 'montecarlo';
    cfg.correctm                         	= 'cluster';
    cfg.clusteralpha                      	= 0.05;
    cfg.clusterstatistic                  	= 'maxsum';
    cfg.minnbchan                          	= 0;
    cfg.tail                             	= 1;
    cfg.clustertail                       	= cfg.tail;
    cfg.alpha                             	= 0.025;
    cfg.numrandomization                    = 1000;
    cfg.uvar                            	= 1;
    cfg.ivar                             	= 2;
    
    nbsuj                               	= size(alldata,1);
    [design,neighbours]                 	= h_create_design_neighbours(nbsuj,alldata{1,1},'gfp','t');
    
    cfg.design                          	= design;
    cfg.neighbours                          = neighbours;
    
    stat{ntest}                          	= ft_freqstatistics(cfg, alldata{:,ntest,1}, alldata{:,ntest,2});
    
end

for ntest = 1:length(stat)
    [min_p(ntest),p_val{ntest}]         	= h_pValSort(stat{ntest});
end

%%

i                                           = 0;
nrow                                        = 3;
ncol                                        = 6;

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
            title({list_low{ntest},statplot.label{nchan},['p = ' num2str(round(min(min(iy)),3))]});
            
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
            xticks(statplot.freq([1:4:end]));
            
            i                               = i + 1;
            subplot(nrow,ncol,i)
            avg_over_time                 	= squeeze(nanmean(tmp,2));
            plot(statplot.time,avg_over_time,'LineWidth',2);
            xlabel('Time');
            set(gca,'FontSize',14,'FontName', 'Calibri');
            xlim(statplot.time([1 end]));
            ylabel('t values');
            xticks([0 1.5 3 4.5 5.5]);
            xticklabels({'1st cue' '1st gab' '2nd cue' '2nd gab' 'mean RT'});
            vline([0 1.5 3 4.5 5.5],'--k');
            
        end
    end
end