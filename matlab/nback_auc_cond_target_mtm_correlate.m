clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

suj_list                	= [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    list_nback          	= [0 1 2];
    list_cond              	= {'0back','1back','2back'};
    list_color           	= 'rgb';
    
    list_cond              	= list_cond(list_nback+1);
    list_color            	= list_color(list_nback+1);
    list_freq               = 1:30;
    
    for nback = 1:length(list_nback)
        for nfreq = 1:length(list_freq)
            
            file_list    	= dir(['J:/temp/nback/data/stim_per_cond_mtm/sub' num2str(suj_list(nsuj)) '.sess*.' ...
                num2str(list_nback(nback)) 'back.' num2str(list_freq(nfreq)) 'Hz.target.auc.mat']);
            
            tmp            	= [];
            
            for nf = 1:length(file_list)
                fname      	= [file_list(nf).folder '\' file_list(nf).name];
                fprintf('loading %s\n',fname);
                load(fname);
                tmp        	= [tmp;scores]; clear fname;
            end
            
            pow(1,nfreq,:)	= mean(tmp,1);
            
        end
        
        freq                = [];
        freq.time         	=  -1.5:0.02:2;
        freq.label         	= {'auc'};
        freq.freq          	= list_freq;
        freq.powspctrm     	= pow;
        freq.dimord        	= 'chan_freq_time';
        
        alldata{nsuj,nback}	= freq; clear freq pow;
        
    end
    
    behav_struct            = h_nbk_exctract_behav(suj_list(nsuj));
    
    for nback = 1:3
        allbehav{nsuj,nback,1} = [behav_struct(nback).rt];
        allbehav{nsuj,nback,2} = [behav_struct(nback).correct];
    end
    
    list_behav              = {'rt','correct'};
    
end

keep alldata allbehav list_*;

cfg                     = [];
cfg.method              = 'montecarlo';
% cfg.latency             = [0.6 1.1];
% cfg.frequency           = [7 15];
cfg.statistic           = 'ft_statfun_correlationT';
cfg.clusterstatistics   = 'maxsum';
cfg.correctm            = 'cluster';
cfg.clusteralpha        = 0.05;
cfg.tail                = 0;
cfg.clustertail         = 0;
cfg.alpha               = 0.025;
cfg.numrandomization    = 1000;
cfg.ivar                = 1;

list_corr               = {'Spearman'};

for nback = 1:size(alldata,2)
    for nbehav = 1:size(allbehav,3)
        for ncorr = 1:length(list_corr)
            
            nb_suj                        	= size(alldata,1);
            cfg.type                      	= list_corr{ncorr};
            cfg.design(1,1:nb_suj)          = [allbehav{:,nback,nbehav}];
            stat{nback,nbehav,ncorr}      	= ft_freqstatistics(cfg, alldata{:,nback});
            
        end
    end
end

figure;

i                                           = 0;
nrow                                        = 2;
ncol                                        = 3;

plimit                                      = 0.1;

for nbehav = 1:size(stat,2)
    for nback = 1:size(stat,1)
        for ncorr = 1:size(stat,3)
            
            statplot                        = stat{nback,nbehav,ncorr};
            statplot.mask                   = statplot.prob < plimit;
            
            for nc = 1:length(statplot.label)
                
                tmp                         = statplot.mask(nc,:,:) .* statplot.prob(nc,:,:);
                iy                          = unique(tmp);
                iy                         	= iy(iy~=0);
                iy                        	= iy(~isnan(iy));
                
                tmp                         = statplot.mask(nc,:,:) .* statplot.rho(nc,:,:);
                ix                        	= unique(tmp);
                ix                         	= ix(ix~=0);
                ix                       	= ix(~isnan(ix));
                
                if ~isempty(ix)
                    
                    i                   	= i + 1;
                    
                    cfg                    	= [];
                    cfg.colormap          	= brewermap(256, '*RdBu');
                    cfg.channel          	= nc;
                    cfg.parameter         	= 'rho';%'prob';
                    cfg.maskparameter      	= 'mask';
                    cfg.maskstyle         	= 'outline';
                    cfg.zlim              	= [-1 1];%[min(min_p) plimit];%
                    cfg.ylim                = [2 30];
                    cfg.xlim                = [-0.2 2];
                    
                    subplot(nrow,ncol,i)
                    ft_singleplotTFR(cfg,statplot);
                    vline(0,'--k');
                    title([num2str(nback-1) 'Back w ' upper(list_behav{nbehav}) ' p = ' num2str(round(min(iy),3))]);
                    
                    c = colorbar;
                    c.Ticks = cfg.zlim;
                    c.FontSize = 10;
                    set(gca,'FontSize',10,'FontName', 'Calibri');
                    
                    %                     avg_over_time                           = squeeze(nanmean(tmp,3));
                    %                     i                                       = i + 1;
                    %                     subplot(nrow,ncol,i)
                    %
                    %                     plot(statplot.freq,avg_over_time,'r','LineWidth',2);
                    %                     xticks(0:4:30);
                    %                     xlabel('Frequency');
                    %                     grid on;
                    %                     set(gca,'FontSize',10,'FontName', 'Calibri');
                    %                     ylim([-0.1 0.1]);
                    %                     xlim(statplot.freq([1 end]))
                    %                     hline(0,'--k');
                    %
                    %                     i                                       = i + 1;
                    %                     subplot(nrow,ncol,i)
                    %                     avg_over_time                           = squeeze(nanmean(tmp,2));
                    %                     plot(statplot.time,avg_over_time,'b','LineWidth',2);
                    %                     xlabel('Time');
                    %                     grid on;
                    %                     set(gca,'FontSize',10,'FontName', 'Calibri');
                    %                     hline(0,'--k');
                    %                     ylim([-0.1 0.1]);
                    %                     xlim(statplot.time([1 end]))
                    
                end
            end
        end
    end
end