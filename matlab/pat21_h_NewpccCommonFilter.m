function h_NewpccCommonFilter(suj,n_prt,data,list_time,time_win,trilili,f_focus,tap,formul)

for t = 1:length(list_time)
    
    lm1             = list_time(t)-trilili;
    lm2             = list_time(t)+time_win+trilili;
    
    cfg             = [];
    cfg.toilim      = [lm1 lm2];
    poi{t}          = ft_redefinetrial(cfg, data);
    
end

data = poi{1};
data.trial = {};

data = rmfield(data,'sampleinfo');
data = rmfield(data,'time');

for n = 1:length(poi{2}.trial)
    data.trial{1,n} = [poi{1}.trial{n} poi{2}.trial{n}];
    data.time{1,n} = [poi{1}.time{n} poi{2}.trial{n}];
end

clear poi

cfg               = [];
cfg.method        = 'mtmfft';
cfg.foi           = f_focus;
cfg.tapsmofrq     = tap;
cfg.output        = 'fourier';
cfg.keeptrials    = 'yes';
freq              = ft_freqanalysis(cfg,data);


fprintf('\nLoading Leadfield\n');
load(['../data/' suj '/headfield/' suj '.pt' num2str(n_prt) '.adjusted.leadfield.5mm.mat']);
load(['../data/' suj  '/headfield/' suj '.VolGrid.5mm.mat']);

cfg                     = [];
cfg.method              = 'pcc';
cfg.frequency           = freq.freq;
cfg.grid                = leadfield;
cfg.headmodel           = vol;
cfg.pcc.projectnoise    = 'yes';
cfg.pcc.lambda          = '5%';
cfg.pcc.keepfilter      = 'yes';
cfg.keeptrials          = 'yes';
cfg.pcc.fixedori        = 'yes';
source                  = ft_sourceanalysis(cfg, freq);
com_filter              = source.avg.filter;

ext_com = '.pcc.Fixed' ;

FnameFilterOut = [suj '.pt' num2str(n_prt) '.CnD.4KT.' num2str(f_focus-formul) 't' num2str(f_focus+formul) 'Hz' ...
    '.commonFilter' ext_com];

fprintf('\n\nSaving %50s \n\n',FnameFilterOut);
save(['../data/' suj '/filter/' FnameFilterOut '.mat'],'com_filter','-v7.3');