clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

suj_list                                    = [1:33 35:36 38:44 46:51];
list_nback                                  = [0 1 2];


list_cond                                   = {'0back','1back','2back'};
list_cond                                   = list_cond(list_nback+1);

for nback = 1:length(list_nback)
    
    i                                       = 0;
    
    for nsuj = 1:length(suj_list)
        
        ext_lock                            = 'target';
        
        chk                                 = dir(['P:/3015079.01/nback/auc/resp/sub' num2str(suj_list(nsuj)) ...
            '.sess*.' num2str(list_nback(nback)) 'back.10Hz.lockedon.' ext_lock '.auc.correct.mat']);
        
        if ~isempty(chk)
            
            i                               = i+1;
            list_freq                    	= 1:30;
            
            for nfreq = 1:length(list_freq)
                
                file_list                   = dir(['P:/3015079.01/nback/auc/resp/sub' num2str(suj_list(nsuj)) ...
                    '.sess*.' num2str(list_nback(nback)) 'back.' num2str(list_freq(nfreq)) 'Hz.lockedon.' ext_lock '.auc.correct.mat']);
                
                tmp                       	= [];
                
                for nf = 1:length(file_list)
                    fname                       = [file_list(nf).folder '\' file_list(nf).name];
                    fprintf('loading %s\n',fname);
                    load(fname);
                    tmp                         = [tmp;scores]; clear fname;
                end
                
                
                pow(1,nfreq,:)                  = mean(tmp,1); clear tmp;
                
                
                
            end
            
            freq                                = [];
            freq.time                           =  -1.5:0.02:2;
            freq.label                          = {'auc'};
            freq.freq                           = list_freq;
            freq.powspctrm                      = pow;
            freq.dimord                         = 'chan_freq_time';
            
            alldata{nback}{i,1}                	= freq; clear freq;
            alldata{nback}{i,2}                	= alldata{nback}{i,1};
            alldata{nback}{i,2}.powspctrm(:)  	= 0.5;
            
        end
    end
end

keep alldata list_*

cfg                                         = [];
cfg.statistic                               = 'ft_statfun_depsamplesT';
cfg.method                                  = 'montecarlo';
cfg.correctm                                = 'cluster';
cfg.clusteralpha                            = 0.05;
cfg.latency                                 = [-0.1 2];
cfg.frequency                               = [2 30];
cfg.clusterstatistic                        = 'maxsum';
cfg.minnbchan                               = 0;
cfg.tail                                    = 0;
cfg.clustertail                             = 0;
cfg.alpha                                   = 0.025;
cfg.numrandomization                        = 1000;
cfg.uvar                                    = 1;
cfg.ivar                                    = 2;

for nt = 1:3
    nbsuj                                   = size(alldata{nt},1);
    [design,neighbours]                     = h_create_design_neighbours(nbsuj,alldata{nt}{1},'gfp','t');
    
    cfg.design                              = design;
    cfg.neighbours                          = neighbours;
    
    stat{nt}                            	= ft_freqstatistics(cfg, alldata{nt}{:,1},alldata{nt}{:,2});
end

figure;

i                                           = 0;
nrow                                        = 3;
ncol                                        = 3;

plimit                                      = 0.2;

for ns = 1:length(stat)
    
    statplot                             	= stat{ns};
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
            cfg.parameter                  	= 'stat';%'prob';
            cfg.maskparameter            	= 'mask';
            cfg.maskstyle                  	= 'outline';
            cfg.zlim                      	= [-5 5];%[min(min_p) plimit];%
            cfg.ylim                        = [2 30];
            cfg.xlim                        = [-0.2 2];
            nme                           	= statplot.label{nc};
            
            subplot(nrow,ncol,i)
            ft_singleplotTFR(cfg,statplot);
            vline(0,'--k');
            
            list_condition                  = {'0 Back','1 Back','2 Back'};
            
            title([list_condition{ns} ' p = ' num2str(round(min(min(iy)),3))]);
            
            c = colorbar;
            c.Ticks = cfg.zlim;
            c.FontSize = 10;
            
            set(gca,'FontSize',10,'FontName', 'Calibri');
            
            avg_over_time                           = squeeze(nanmean(tmp,3));
            i                                       = i + 1;
            subplot(nrow,ncol,i)
            
            plot(statplot.freq,avg_over_time,'r','LineWidth',2);
            xticks(0:4:30);
            xlabel('Frequency');
            grid on;
            set(gca,'FontSize',10,'FontName', 'Calibri');
            
            i                                       = i + 1;
            subplot(nrow,ncol,i)
            avg_over_time                           = squeeze(nanmean(tmp,2));
            plot(statplot.time,avg_over_time,'b','LineWidth',2);
            xlabel('Time');
            grid on;
            set(gca,'FontSize',10,'FontName', 'Calibri');
            vline(0,'--k');
            
        end
    end
end