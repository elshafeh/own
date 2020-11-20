clear ; clc ; 

fieldtrip_path = '/Users/heshamelshafei/fieldtrip/';
addpath(fieldtrip_path);
ft_defaults

clear ; clc ;

suj_list = {'oc1','oc12','oc2','oc5','oc8','yc1','yc12','yc15','yc18','yc20','yc4','yc7', ...
    'oc10','oc13','oc3','oc6','oc9','yc10','yc13','yc16','yc19','yc21','yc5','yc8','oc11',...
    'oc14','oc4','oc7','yc11','yc14','yc17','yc2','yc3','yc6','yc9'};

for sb = 1
    
    suj = suj_list{sb};
    
    ds_name                     = '/Users/heshamelshafei/GoogleDrive/NeuroProj/Fieldtripping/data/resting_state/';
    ds_name                     = [ds_name  suj '.pat2.restingstate.thrid_order.ds'];
    
    cfg                         = [];
    cfg.dataset                 = ds_name ;
    cfg.channel                 = 'MEG';
    data_raw                    = ft_preprocessing(cfg);
    
    cfg                         = [];
    cfg.resamplefs              = 150;
    cfg.detrend                 = 'no';
    data_resamp                 = ft_resampledata(cfg, data_raw);
    
    cfg                         = [];
    cfg.bpfilter                = 'yes';
    cfg.bpfreq                  = [0.5 40];
    cfg.bpfiltord               = 3;
    data_resamp_filt            = ft_preprocessing(cfg,data_resamp);
    
    cfg                         = [];
    cfg.method                  = 'fastica';
    ica_comp                    = ft_componentanalysis(cfg, data_resamp_filt);
    
    cfg                         = [];
    cfg.component               = 1:20;       % specify the component(s) that should be plotted
    cfg.layout                  = 'CTF275.lay'; % specify the layout file that should be used for plotting
    cfg.comment                 = 'no';
    cfg.marker                  = 'off';
    ft_topoplotIC(cfg, ica_comp)
    
    cfg                         = [];
    cfg.channel                 = 1:20; % components to be plotted
    cfg.viewmode                = 'component';
    cfg.layout                  = 'CTF275.lay'; % specify the layout file that should be used for plotting
    ft_databrowser(cfg, ica_comp)
    
end