clear;

% clear;

list_suj                      	= {};
for j = 1:9
    list_suj{j,1}              	= ['sub00', num2str(j)];
end
for k = [10:12,17,18,20:22,24:30]
    j                          	= j+1;
    list_suj{j,1}            	= ['sub0', num2str(k)];
end

keep list_suj

for nsuj = 1:length(list_suj)
    
    suj_name                            = list_suj{nsuj};
    fname                               = ['/project/3015039.05/data/' suj_name '/preproc/' suj_name '_stimLock_ICAlean_finalrej.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    cfg                                 = [];
    cfg.trials                          = find(dataPostICA_clean.trialinfo(:,5) < 3);
    dataPostICA_clean                   = ft_selectdata(cfg,dataPostICA_clean);
    
    newdata                             = dataPostICA_clean;
    newdata                             = rmfield(newdata,'sampleinfo');
    newdata                             = rmfield(newdata,'cfg');
    
    for ntrial = 1:length(dataPostICA_clean.trialinfo)
        
        time_axis                       = dataPostICA_clean.time{ntrial};
        new_time_axis                   = time_axis - (-dataPostICA_clean.trialinfo(ntrial,5));
        
        t                               = find(round(new_time_axis,2) == round(0,2));
        t                               = t(1);
        
        sin_trl_data                    = dataPostICA_clean.trial{ntrial}(:,t-300:t+300);
        sin_trl_time                    = -1:1/dataPostICA_clean.fsample:1;
        
        newdata.trial{ntrial}           = sin_trl_data;
        newdata.time{ntrial}            = sin_trl_time;
        
        clear *axis *_trl_*
        
    end
    
    cfg                                 = [];
    cfg.demean                          = 'yes';
    cfg.baselinewindow                  = [-0.2 0];
    cfg.lpfilter                        = 'yes';
    cfg.lpfreq                          = 20;
    newdata                          	= ft_preprocessing(cfg,newdata);
    
    avg                                 = ft_timelockanalysis([], newdata);
    
    cfg                                 = [];
    cfg.feedback                        = 'yes';
    cfg.method                          = 'template';
    cfg.neighbours                      = ft_prepare_neighbours(cfg, avg); close all;
    cfg.planarmethod                    = 'sincos';
    avg_planar                          = ft_megplanar(cfg, avg);
    avg_comb                            = ft_combineplanar([],avg_planar);
    
    alldata{nsuj,1}                     = avg_comb; clear avg* newdata
    
end

keep alldata

gavg                                    = ft_timelockgrandaverage([],alldata{:});

cfg                                     = [];
cfg.layout                              = 'CTF275_helmet.mat';
cfg.ylim                                = 'maxabs';
cfg.marker                              = 'off';
cfg.comment                             = 'no';
cfg.colormap                            = brewermap(256,'Reds');
cfg.colorbar                            = 'no';
ft_topoplotER(cfg, gavg);