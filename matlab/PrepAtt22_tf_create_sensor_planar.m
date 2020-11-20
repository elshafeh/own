clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');

suj_group{1}    = allsuj(2:15,1);
suj_group{2}    = allsuj(2:15,2);
suj_list            = [suj_group{1};suj_group{2}];
suj_list            = unique(suj_list);

clearvars -except suj_list

for sb = 1:length(suj_list)
    
    suj                 = suj_list{sb};
    
    for cond_main           = {'CnD'}
        
        fname_in            = ['../data/' suj '/field/' suj '.' cond_main{:} '.mat'];
        
        fprintf('Loading %s\n',fname_in);
        
        load(fname_in)
        
        cfg                 = [];
        cfg.method          = 'triangulation';
        cfg.layout          = 'CTF275.lay';
        neighbours          = ft_prepare_neighbours(cfg);
        
        cfg                 = [];
        cfg.planarmethod    = 'sincos';
        cfg.neighbours      = neighbours;
        data_planar         = ft_megplanar(cfg,data_elan);
                
        cfg                 = [];
        cfg.method          = 'wavelet';
        cfg.output          = 'pow';
        cfg.toi             = -3:0.05:3;
        cfg.foi             = 1:20 ;
        cfg.keeptrials      = 'no';
        freq                = ft_freqanalysis(cfg, data_planar);
        freq                = rmfield(freq,'cfg');
        
        cfg                 = [];
        freq_planar         = ft_combineplanar(cfg,freq);
        freq_planar.grad    = data_elan.grad;
        
        freq                = freq_planar ; clear freq_planar data_planar;
        
        fname               = ['../data/' suj '/field/' suj '.' cond_main{:} '.waveletPOW.1t20Hz.m3000p3000.AvgTrials.Planar.mat'];
        fprintf('Saving %s\n',fname);
        
        save(fname,'freq','-v7.3');
        
        clear freq
        
    end
end
