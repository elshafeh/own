clear ; clc;

if ispc
    start_dir = 'D:/Dropbox/project_me/data/taco/';
else
    start_dir = '~/Dropbox/project_me/data/taco/';
end

suj_list                    = {'tac001'};

for nsuj = 1:length(suj_list)
    
    subjectName                 = suj_list{nsuj};
    subject_folder              = [start_dir 'preproc/'];
    ext_lock                    = 'localizerlock';
    fname                       = [subject_folder subjectName '_' ext_lock '_icalean_finalrej.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    % - - low pass filtering
    cfg                         = [];
    cfg.demean                  = 'yes';
    cfg.baselinewindow          = [-0.1 0];
    cfg.lpfilter                = 'yes';
    cfg.lpfreq                  = 20;
    data_axial                  = ft_preprocessing(cfg,dataPostICA_clean); clear dataPostICA_clean;

    
    cfg                         = [];
    avg                         = ft_timelockanalysis(cfg, data_axial);
    
    %-- combine planar
    cfg                         = [];
    cfg.feedback                = 'yes';
    cfg.method                  = 'template';
    cfg.neighbours              = ft_prepare_neighbours(cfg, avg); close all;
    cfg.planarmethod            = 'sincos';
    avg_planar                  = ft_megplanar(cfg, avg);
    avg_comb                    = ft_combineplanar([],avg_planar);
    avg_comb                    = rmfield(avg_comb,'cfg');
    
    alldata{nsuj}               = avg_comb; clear avg_comb;
    
end

keep alldata decode_data

%%

list_channel                        = {'MLO11','MLO12','MLO13','MLO21','MLO22','MLO23', ... 
    'MLO31','MLO32','MLP51','MLP52','MLP53','MRO11','MRO21','MRO31','MRP51','MZO01','MZO02'};

cfg                                 = [];
cfg.marker                          = 'off';
cfg.layout                          = 'CTF275_helmet.mat';
cfg.comment                         = 'no';
cfg.colormap                        = brewermap(256, 'Reds');
cfg.colorbar                        = 'yes';
cfg.zlim                            = 'zeromax';
subplot(2,2,1)
ft_topoplotER(cfg,ft_timelockgrandaverage([],alldata{:}));

cfg                                 = [];
cfg.xlim                            = [-0.1 1.5];
cfg.channel                         = list_channel;
cfg.figure                          =  0;
cfg.linewidth                       = 2;
cfg.linecolor                       = 'k';
subplot(2,2,2)
ft_singleplotER(cfg,ft_timelockgrandaverage([],alldata{:}));
title('');
vline(0,'--k');