clear ; clc;

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName                     	= suj_list{nsuj};
    fname                               = ['J:\temp\bil\virt\' subjectName '.virtualelectrode.mni.nohemi.mat'];
    fprintf('\nloading %s\n',fname);
    load(fname);
    
    % - - low pass filtering
    cfg                             	= [];
    cfg.demean                          = 'yes';
    cfg.baselinewindow                  = [-0.1 0];
    cfg.lpfilter                     	= 'yes';
    cfg.lpfreq                        	= 20;
    data_preproc                     	= ft_preprocessing(cfg,data); clear data;
    
    % - - computing average
    cfg                                 = [];
    cfg.trials                          = find(data_preproc.trialinfo(:,16) == 1);
    avg                                 = ft_timelockanalysis([],data_preproc);
    avg.avg                             = abs(avg.avg);
    
    alldata{nsuj,1}                     = avg; clear avg;
    
end

keep alldata

gavg                                    = ft_timelockgrandaverage([],alldata{:});

figure;
nrow    = 6;
ncol    = 6;
i       = 0;

for nchan = [1:9 13:length(gavg.label)]
   
    cfg             = [];
    cfg.channel     = nchan;
    cfg.baseline    = [1.4 1.5];
    cfg.xlim        = [1.5 4];
    cfg.ylim        = [0 5e-5];
    
    i               = i + 1;
    subplot(nrow,ncol,i)
    ft_singleplotER(cfg,gavg);
    
end