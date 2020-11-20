
clear ; clc ;
addpath('/Users/heshamelshafei/fieldtrip/'); ft_defaults;
addpath('DrosteEffect-BrewerMap-b6a6efc/');

global ft_default
ft_default.spmversion = 'spm12';

suj_list                                        = [1:4 8:17] ;

for sb = 1:length(suj_list)
    
    suj                                         = ['yc' num2str(suj_list(sb))] ;
    
    ext_data                                    = 'CnD.PaperAudVisTD.1t20Hz.m800p2000msCov';
    
    fname                                       = ['../data/conn/' suj '.' ext_data '.mat'];
    fprintf('Loading %s\n',fname);
    load(fname);
    
    cond_ix_sub                                 = {'N','L','R','NL','NR'}; %{''};
    cond_ix_cue                                 = {0,1,2,0,0};%{0:2};
    cond_ix_dis                                 = {0,0,0,0,0};%{0};
    cond_ix_tar                                 = {1:4,1:4,1:4,[1 3],[2 4]};%{1:4};
    
    for ncue = 1:length(cond_ix_sub)
        
        cfg                                     = [];
        cfg.trials                              = h_chooseTrial(virtsens,cond_ix_cue{ncue},cond_ix_dis{ncue},cond_ix_tar{ncue});
        data{1}                                 = ft_selectdata(cfg,virtsens);
        data{2}                                 = h_removeEvoked(data{1});
        
        cfg                                     = [];
        cfg.method                              = 'wavelet';
        cfg.output                              = 'fourier';
        cfg.keeptrials                          = 'yes';
        cfg.width                               = 7;
        cfg.gwidth                              = 4;
        cfg.toi                                 = -2:0.01:2;
        cfg.foi                                 = 1:20;
        
        for nevo = 1:2
            
            freq                                = ft_freqanalysis(cfg, data{nevo});
            list_evoked                         = {'eEvoked','mEvoked'};
            fname_out                           = ['../data/conn/' suj '.' cond_ix_sub{ncue} ext_data '.fourier.' list_evoked{nevo} '.mat'];
            fprintf('Saving %s\n',fname_out);
            save(fname_out,'freq','-v7.3');
            
        end
    end
end