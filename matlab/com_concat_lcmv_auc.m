clear ;

suj_list                        = [1:4 8:17];

for ns = 1:length(suj_list)
    
    fname                       = ['/Volumes/heshamshung/alpha_compare/decode/meeg_dec/yc' num2str(suj_list(ns)) '.meeg.dec.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    avg                         = [];
    avg.avg                     = scores; clear scores;
    avg.label                   = {'MEG VS EEG'};
    avg.dimord                  = 'chan_time';
    
    avg.time                    = time_axis;
    alldata{ns,1}               = avg;
    
end

cfg                             = [];
cfg.color                       = 'k';
cfg.plot_single                 = 'no';

cfg.vline                       = [0 1.2];
cfg.ylim                        = [0.49 1];
% cfg.xlim                        = [-0.2 2];

h_plot_erf(cfg,alldata(:));

yticks(cfg.ylim)

xlabel('Time (s)')
ylabel('AUC')

title(alldata{1,1}.label{1});
set(gca,'FontSize',20,'FontName', 'Calibri');
