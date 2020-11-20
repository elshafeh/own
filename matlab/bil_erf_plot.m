clear ; clc;

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName                  	= suj_list{nsuj};
    fname                       	= ['J:\temp\bil\erf\' subjectName '.1stcue.lock.correct.erfComb.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    alldata{nsuj}                   = avg_comb; clear avg_comb;
    
end

clearvars -except alldata;
gavg                                = ft_timelockgrandaverage([],alldata{:});

cfg                                 = [];
cfg.layout                          = 'CTF275_helmet.mat';
cfg.marker                          = 'off';
% cfg.comment                         = 'no';
cfg.colormap                        = brewermap(256,'*RdBu');
cfg.colorbar                        = 'no';
cfg.baseline                        = [-0.2 0];
cfg.xlim                            = [0:0.3:2];
ft_topoplotER(cfg,gavg);

% cfg                                     = [];
% cfg.label                               = 'M*O*';
% cfg.label                               ={'MLO11', 'MLO12', 'MLO21', 'MLO22', 'MLO31', 'MLO32', ...
%     'MRO11', 'MRO12', 'MRO21', 'MRO22', 'MRO23', 'MZO01'};
% cfg.xlim                                = [-0.2 1];
% cfg.vline                               = [0];
% cfg.rect_ax                             = rect_ax;
% cfg.plot_single                         = 'no';
%
% i                                       = i +1;
% subplot(2,4,i:i+3);
% h_plot_erf(cfg,alldata)
%
% % i                                       = 0;
% %
% % rect_ax                                 = [];
% %
% % for nt = 1:length(list_time)
% %
% %     cfg                                 = [];
% %     cfg.layout                          = 'CTF275_helmet.mat';
% %     cfg.ylim                            = 'maxabs';
% %     cfg.marker                          = 'off';
% %     cfg.comment                         = 'no';
% %     cfg.colormap                        = brewermap(256,'Reds');
% %     cfg.colorbar                        = 'no';
% %
% %     ax1                                 = list_time(nt)+0.08;
% %     ax2                                 = list_time(nt)+0.2;
% %
% %     cfg.xlim                            = [ax1 ax2];
% %
% %     i                                   = i +1;
% %     subplot(2,4,i)
% %     ft_topoplotER(cfg, gavg);
% %
% %     rect_ax                             = [rect_ax;cfg.xlim];
% %
% % end
% %
%
