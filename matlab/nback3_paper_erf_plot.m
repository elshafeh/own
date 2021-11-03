clear;clc;

suj_list                   	= [1:33 35:36 38:44 46:51];
suj_list(suj_list == 19)  	= [];
suj_list(suj_list == 38)  	= [];

list_chan                   = {};

for nsuj = 1:length(suj_list)
    
    dir_data                = '~/Dropbox/project_me/data/nback/0back/erf/';
    fname_in                = [dir_data 'sub' num2str(suj_list(nsuj)) '.0back.erf.mat'];
    fprintf('loading %s\n',fname_in);
    load(fname_in);
    
    t1                      = nearest(avg_comb.time,-0.1);
    t2                      = nearest(avg_comb.time,0);
    
    bsl                     = mean(avg_comb.avg(:,t1:t2),2);
    avg_comb.avg            = avg_comb.avg - bsl ; clear bsl t1 t2;
    
    alldata{nsuj,1}         = avg_comb; clear avg_comb;
    
    dir_data                = '~/Dropbox/project_me/data/nback/peak/';
    fname_in                = [dir_data 'sub' num2str(suj_list(nsuj)) '.alphabeta.peak.package.0back.fixed.mat'];
    fprintf('loading %s\n',fname_in);
    load(fname_in);
    
    list_chan               = [list_chan;max_chan];
    
    
end

%%
clc; keep alldata list_chan;

gavg                        = alldata{1};
pow                         = [];

for nsuj = 1:size(alldata,1)
    pow(nsuj,:,:)           = alldata{nsuj,1}.avg;
end

gavg.avg                    = squeeze(nanmean(pow,1));

list_channel                = unique(list_chan);
% % {'MEG1912+1913', 'MEG1922+1923', 'MEG2012+2013', ... 
% %     'MEG2022+2023', 'MEG2032+2033', 'MEG2042+2043', 'MEG2312+2313', 'MEG2342+2343'};

cfg                         = [];
cfg.layout                  = 'neuromag306cmb_helmet.mat';
cfg.ylim                    = 'maxabs';
cfg.marker                  = 'off';
cfg.comment                 = 'no';
cfg.colormap                = brewermap(256,'Reds');
cfg.colorbar                = 'yes';
cfg.xlim                    = [0.05 0.2];
cfg.highlight               = 'on';
cfg.highlightchannel        =  list_channel;
cfg.highlightsymbol         = '.';
cfg.highlightcolor          = [0 0 0];
cfg.highlightsize           = 10;
cfg.figure                  = subplot(2,2,1);
ft_topoplotER(cfg, gavg);

cfg                      	= [];
cfg.label                   = list_channel;
cfg.xlim                 	= [-0.05 1];
cfg.color               	= 'k';
cfg.plot_single           	= 'no';
subplot(2,2,2);
h_plot_erf(cfg,alldata);
vline(0,'-k');
hline(0,'-k');
ylim([-0.2e-12 4e-12]);
yticks([-0.2e-12 4e-12]);

xticks([0 0.2 0.4 0.6 0.8 1]);
set(gca,'FontSize',16,'FontName', 'Calibri','FontWeight','normal');