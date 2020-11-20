clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

% load suj_list_peak.mat
%
% list_freq                                                   = 1:30;
%
% for nsuj = 1:length(suj_list)
%
%
%     for nlock = [1 2 3]
%         for nback = [0 1 2]
%
%             for nfreq = 1:length(list_freq)
%
%                 fprintf('loading files for %s %s %s %s\n',['sub' num2str(suj_list(nsuj))],[num2str(nback) 'back'],[num2str(nlock) 'lock'],[num2str(list_freq(nfreq)) 'Hz']);
%
%                 file_list                                   = dir(['/project/3015039.05/temp/nback/data/decode/stim_break/sub' num2str(suj_list(nsuj)) '.sess*.stim*.' num2str(nback) 'back.' num2str(nlock) 'lock.' num2str(list_freq(nfreq)) 'Hz.auc.collapse.mat']);
%
%                 tmp                                         = [];
%
%                 for nf = 1:length(file_list)
%                     fname                                   = [file_list(nf).folder '/' file_list(nf).name];
%                     %                     fprintf('loading %s\n',fname);
%                     load(fname);
%                     tmp                                     = [tmp;scores];
%                 end
%
%                 data_matrix(nlock,nback+1,nfreq,:)          = mean(tmp,1); clear tmp;
%
%             end
%         end
%     end
%
%     freq                                                    = [];
%     freq.time                                               = -1.5:0.05:6;
%     freq.label                                              = {'stim1 lock','stim2 lock','stim3 lock'};
%     freq.freq                                               = list_freq;
%     freq.powspctrm                                          = squeeze(mean(data_matrix,2));
%     freq.dimord                                             = 'chan_freq_time';
%     alldata{nsuj,1}                                         = freq; clear freq data_matrix;
%
%     alldata{nsuj,2}                                         = alldata{nsuj,1};
%     alldata{nsuj,2}.powspctrm(:)                            = 0.5;
%
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
% stat                                        = ft_freqstatistics(cfg, alldata{:,1}, alldata{:,2});

load('../data/com_emergence_stim_mtm.mat');

[min_p,p_val]                               = h_pValSort(stat);

stat                                        = rmfield(stat,'negdistribution');
stat                                        = rmfield(stat,'posdistribution');

figure;

i                                           = 0;
nrow                                        = 2;
ncol                                        = 3;

plimit                                      = 0.05;
stat.mask                                   = stat.prob < plimit;

for nc = 1:length(stat.label)
    
    tmp                                     = stat.mask(nc,:,:) .* stat.stat(nc,:,:);
    ix                                      = unique(tmp);
    ix                                      = ix(ix~=0);
    
    if ~isempty(ix)
        
        i                                   = i + 1;
        
        cfg                                 = [];
        cfg.colormap                        = brewermap(256, '*RdBu');
        cfg.channel                         = nc;
        cfg.parameter                       = 'prob';
        cfg.maskparameter                   = 'mask';
        cfg.maskstyle                       = 'outline';
        cfg.zlim                            = [min(min_p) plimit];
        
        nme                                 = stat.label{nc};
        
        subplot(nrow,ncol,i)
        ft_singleplotTFR(cfg,stat);
        title(nme);
        
        c = colorbar;
        c.Ticks = cfg.zlim;
        
        set(gca,'FontSize',16,'FontName', 'Calibri');
        
    end
end

tmp                                     = stat.mask .* stat.stat;


avg_over_time                           = squeeze(nanmean(tmp,3));
i                                       = i + 1;
subplot(nrow,ncol,i)
hold on;

for nc = 1:length(stat.label)
    plot(stat.freq,avg_over_time(nc,:),'LineWidth',2);
end
legend(stat.label);
xticks(0:5:30);
xlabel('Frequency');
grid on;
set(gca,'FontSize',16,'FontName', 'Calibri');
ylim([0 0.7]);
yticks([0 0.7]);

avg_over_time                           = squeeze(nanmean(tmp,2));
i                                       = i + 1;
subplot(nrow,ncol,i)
hold on;
for nc = 1:length(stat.label)
    plot(stat.time,avg_over_time(nc,:),'LineWidth',2);
end
legend(stat.label);
xlabel('Time');
grid on;
set(gca,'FontSize',16,'FontName', 'Calibri');
ylim([0 2.5]);
yticks([0 2.5]);