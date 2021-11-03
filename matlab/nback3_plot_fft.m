clear;clc;

suj_list                   	= [1:33 35:36 38:44 46:51];

list_channel              	= [];

for nsuj = 1:length(suj_list)
    
    subjectname             = ['sub' num2str(suj_list(nsuj))];
    
    % load peak
    dir_data                = '~/Dropbox/project_me/data/nback/peak/';
    fname                   = [dir_data subjectname '.alphabeta.peak.package.0back.equalhemi.mat']; % fixed
    fprintf('loading %s\n',fname);
    load(fname);
    
    dataplot(nsuj,1)        = apeak;
    dataplot(nsuj,2)        = bpeak;
    
    dir_data               	= '~/Dropbox/project_me/data/nback/fft/';
    fname                   = [dir_data subjectname '.alphabeta.peak.fft.0back.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    gavg                    = freq_comb;
    
    cfg                     = [];
    cfg.channel             = max_chan;
    cfg.avgoverchan         = 'yes';
    freq_peak               = ft_selectdata(cfg,freq_comb); clear freq_comb
    freq_peak.label         = {'avg'};
    
    alldata{nsuj,1}         = freq_peak; 
    
    list_channel            = [list_channel;max_chan];
    
    clc;
    
end

dataplot(isnan(dataplot(:,2)),2)        = round(nanmean(dataplot(:,2)));

keep alldata dataplot list_channel gavg

%%
clc;
close all;

subplot(2,2,1)
hold on;

cfg                         = [];
cfg.label                   = {'avg'};
cfg.xlim                    = [1 30];
cfg.color                   = 'k';
cfg.plot_single             = 'no';
h_plot_erf(cfg,alldata);

vline(round(median(dataplot(:,1))),'--k');
vline(round(median(dataplot(:,2))),'--k');

title('Occipital power spectrum');
set(gca,'FontSize',14,'FontName', 'Calibri','FontWeight','normal');

gavg.powspctrm(:)           = 0;

cfg                         = [];
cfg.layout                  = 'neuromag306cmb.lay';
cfg.ylim                    = 'maxabs';
cfg.marker                  = 'on';
cfg.comment                 = 'no';
cfg.colormap                = brewermap(256,'*RdBu');
cfg.colorbar                = 'no';
cfg.highlight               = 'on';
cfg.highlightchannel        = unique(list_channel);
cfg.highlightcolor          = [0 0 0];
cfg.highlightsize           = 18;
cfg.highlightsymbol         = '.';
cfg.figure                  = subplot(2,2,2);
ft_topoplotER(cfg, gavg);

