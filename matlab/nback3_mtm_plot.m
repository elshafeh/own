clear;clc;

suj_list            	= [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    % load in 0back data for baseline correction
    dir_data          	= '~/Dropbox/project_me/data/nback/0back/mtm/';
    fname_in         	= [dir_data 'sub' num2str(suj_list(nsuj)) '.0back.avgtrial.mtm.mat'];
    fprintf('loading %s\n',fname_in);
    load(fname_in);
    
    % select data
    freq_bounds        	= [3 30];
    time_bounds        	= [-0.5 1];
    freq_comb        	= h_selectfreq(freq_comb,freq_bounds,time_bounds);
    
    % baseline correction
    t1                 	= nearest(freq_comb.time,-0.4);
    t2                 	= nearest(freq_comb.time,-0.2);
    bsl                	= nanmean(freq_comb.powspctrm(:,:,t1:t2),3);
    freq_comb.powspctrm	= (freq_comb.powspctrm-bsl) ./ bsl; clear bsl;
    
    alldata{nsuj,1}  	= freq_comb; clear freq_comb;
    
end

%%

keep alldata; clc;
gavg                  	= ft_freqgrandaverage([],alldata{:});

%%

cfg                     = [];
cfg.xlim                = [-0.1 1];
cfg.ylim                = [5 40];
cfg.layout              = 'neuromag306cmb.lay';
cfg.zlim                = [-0.2 0.2];
cfg.colormap            = brewermap(256,'*RdBu');
cfg.marker              = 'off';
cfg.comment             = 'no';
cfg.colorbar            = 'no';
ft_topoplotTFR(cfg,gavg);
