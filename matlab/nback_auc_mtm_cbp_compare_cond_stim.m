clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

suj_list    = [1:33 35:36 38:44 46:51];

% list_freq                               	= 1:30;
% 
% for nsuj = 1:length(suj_list)
%     for nback = [0 1 2]
%         for nlock = [1 2 3]
%             for nfreq = 1:length(list_freq)
%                 
%                 fprintf('loading files for %s %s %s %s\n',['sub' num2str(suj_list(nsuj))],[num2str(nback) 'back'],[num2str(nlock) 'lock'],[num2str(list_freq(nfreq)) 'Hz']);
%                 
%                 file_list                  	= dir(['/project/3015039.05/temp/nback/data/decode/stim_break/sub' num2str(suj_list(nsuj)) '.sess*.stim*.' num2str(nback) 'back.' num2str(nlock) 'lock.' num2str(list_freq(nfreq)) 'Hz.auc.collapse.mat']);
%                 
%                 tmp                     	= [];
%                 
%                 for nf = 1:length(file_list)
%                     fname                	= [file_list(nf).folder '/' file_list(nf).name];
%                     load(fname);
%                     tmp                   	= [tmp;scores];
%                 end
%                 
%                 data_matrix(nlock,nfreq,:) 	= mean(tmp,1); clear tmp;
%                 
%             end
%         end
%         
%         freq                              	= [];
%         freq.time                       	= -1.5:0.05:6;
%         freq.label                      	= {'stim1 lock','stim2 lock','stim3 lock'};
%         freq.freq                         	= list_freq;
%         freq.powspctrm                   	= data_matrix;
%         freq.dimord                       	= 'chan_freq_time';
%         alldata{nsuj,nback+1}           	= freq; clear freq data_matrix;
%         
%     end
%     
% end
% 
% keep alldata list_*;
% 
% cfg                                         = [];
% cfg.statistic                               = 'ft_statfun_depsamplesT';
% cfg.method                                  = 'montecarlo';
% cfg.correctm                                = 'cluster';
% cfg.clusteralpha                            = 0.05;
% 
% cfg.latency                                 = [-0.1 6];
% 
% cfg.clusterstatistic                        = 'maxsum';
% cfg.minnbchan                               = 0;
% cfg.tail                                    = 0;
% cfg.clustertail                             = 0;
% cfg.alpha                                   = 0.025;
% cfg.numrandomization                        = 1000;
% cfg.uvar                                    = 1;
% cfg.ivar                                    = 2;
% 
% nbsuj                                       = size(alldata,1);
% [design,neighbours]                         = h_create_design_neighbours(nbsuj,alldata{1,1},'gfp','t');
% 
% cfg.design                                  = design;
% cfg.neighbours                              = neighbours;
% 
% stat{1}                                  	= ft_freqstatistics(cfg, alldata{:,1}, alldata{:,2});
% stat{2}                                    	= ft_freqstatistics(cfg, alldata{:,1}, alldata{:,3});
% stat{3}                                     = ft_freqstatistics(cfg, alldata{:,2}, alldata{:,3});

load('../data/com_compare_cond_stim_mtm.mat','stat');

for ns = 1:length(stat)
    [min_p(ns),p_val{ns}]                	= h_pValSort(stat{ns});
    stat{ns}                              	= rmfield(stat{ns},'negdistribution');
    stat{ns}                              	= rmfield(stat{ns},'posdistribution');
end

figure;

i                                           = 0;
nrow                                        = 4;
ncol                                        = 3;

plimit                                      = 0.05;

for ns = 1:length(stat)
    
    statplot                             	= stat{ns};
    statplot.mask                           = statplot.prob < plimit;
    
    for nc = 1:length(statplot.label)
        
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
            cfg.zlim                      	= [-3 3];%[min(min_p) plimit];
            cfg.ylim                        = [2 30];
            cfg.xlim                        = [0 5];
            nme                           	= statplot.label{nc};
            
            subplot(nrow,ncol,i)
            ft_singleplotTFR(cfg,statplot);
            vline(0,'--k');vline(2,'--k');vline(4,'--k');
            
            
            list_condition                  = {'0 v 1 Back','0 v 2 Back','1 v 2 Back'};
            
            title([nme ' ' list_condition{ns}]);
            
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
            ylim([0 0.5]);
            yticks([0 0.7]);
            
            i                                       = i + 1;
            subplot(nrow,ncol,i)
            avg_over_time                           = squeeze(nanmean(tmp,2));
            plot(statplot.time,avg_over_time,'b','LineWidth',2);
            xlabel('Time');
            grid on;
            set(gca,'FontSize',10,'FontName', 'Calibri');
            ylim([0 1.5]);
            yticks([0 1.5]);
            vline(0,'--k');vline(2,'--k');vline(4,'--k');
            
        end
    end
end