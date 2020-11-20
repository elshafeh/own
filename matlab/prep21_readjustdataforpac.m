clear ; clc ; addpath(genpath('/Users/heshamelshafei/GoogleDrive/PhD/Fieldtripping/scripts_fieldfieldtrip-20151124/'));

for sb = [1:4 8:17]
    
    suj                                 = ['yc' num2str(sb)];
    
    list_ix_cue                         = {0:2,0,1,2};
    list_ix_tar                         = {1:4,1:4,1:4,1:4};
    list_ix_dis                         = {0,0,0,0};
    list_ix_name                        = {'','N','L','R'};
    
    main_cond                           = 'CnD';
    data_ext                            = 'prep21.maxAVMsepVoxels.1t120Hz.m800p2000msCov';
    fname                               = ['../data/paper_data/' suj '.' main_cond '.' data_ext '.mat'];
    
    fprintf('Loading %s\n',fname);
    load(fname);
    
    for ncue = 1:length(list_ix_name)
        
        cfg                                 = [];
        cfg.trials                          = h_chooseTrial(virtsens,list_ix_cue{ncue},list_ix_dis{ncue},list_ix_tar{ncue});
        sub_virtsens                        = ft_selectdata(cfg,virtsens);
        sub_virtsens                        = h_removeEvoked(sub_virtsens); % % ! ! ! % %
       
        cfgTF                               = [];
        cfgTF.output                        = 'fourier';
        cfgTF.method                        = 'mtmconvol';
        cfgTF.taper                         = 'hanning';
        cfgTF.foi                           = 1:120;
        cfgTF.t_ftimwin                     = 0.3.*ones(1,numel(cfgTF.foi));
        t_step                              = 0.01;
        cfgTF.toi                           = -2:t_step:2;
        
        cfg                                 = []; 
        cfg.channel                         = 11:30;
        cfg.numcycle_ax                     = 1;                                    % number of cycles of the low frequyency signal to consider around the peaks/trough;
        cfg.freq_TF                         = 5:15;                                 % frequencies of the TFR aligned on the peaks/troughs
        cfg.freq                            = 5:15;                                 % frequency of the signal from which the peaks/troughts are extracted (low frequency in general)
        Fs                                  = 100;
        cfg.axwidth                         = ceil((cfg.numcycle_ax./cfg.freq)*Fs);     % time window around the peak/trough (ceil((numcycle_ax./cfg.freq)*Fs))
        cfg.meth                            = 'TF';                                 % how to get the phase of the signal ('TF' or 'filter')
        cfg.timewin                         = [-2 2];
            
        [sph, spow, phase_alltr, peaks_all] = ft_PAC(cfgTF,cfg,sub_virtsens);
        
    end
end