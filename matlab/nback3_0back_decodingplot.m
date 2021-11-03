clear;clc;

% let's say from 80ms to 280ms

suj_list                = [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    dir_data          	= '~/Dropbox/project_me/data/nback/bin_decode/auc/';
    flist            	= dir([dir_data 'sub' num2str(suj_list(nsuj)) '.0back.decoding.stim*.nodemean.4fold.mat']);
    
    auc                 = [];
    
    for nfile = 1:length(flist)
        
        fname_in     	= [flist(nfile).folder filesep flist(nfile).name];
        fprintf('loading %s\n',fname_in);
        load(fname_in);
        
        auc(nfile,:)    = scores; clear score;
        
    end
    
    
    avg               	= [];
    avg.label         	= {'decoding stim'};
    avg.time          	= time_axis;
    avg.avg          	= mean(auc,1); clear auc;
    avg.dimord       	= 'chan_time';
    
    alldata{nsuj,1}   	= avg; clear avg freq_comb;
    
    
end

keep alldata

%%

close all ; clc; 

max_time                = [];

for nsuj = 1:size(alldata,1)
    
    subplot(6,8,nsuj)
    
    x                   = alldata{nsuj,1}.time;
    y                   = alldata{nsuj,1}.avg;
    
    t1                  = nearest(x,0);
    t2                  = nearest(x,0.3);
    
    sub_data            = y(t1:t2);
    sub_time            = x(t1:t2);
    
    flg                 = find(sub_data == max(sub_data));
    flg                 = sub_time(flg);
    
    max_time(nsuj,1)    = flg; clear t1 t2 sub_* 
    
    plot(x,y);
    xlim([-0.2 1.5]);
    ylim([0.4 0.8]);
    hline(0.5,'-k');
    vline(0,'-k');
    
    vline(flg,'--r');
    
end

%%

cfg                                     = [];
cfg.label                               = 1;
cfg.xlim                                = [-0.4 2];
cfg.vline                               = [0 0.05 0.35];
cfg.color                               = 'k';
cfg.plot_single                         = 'no';
h_plot_erf(cfg,alldata)