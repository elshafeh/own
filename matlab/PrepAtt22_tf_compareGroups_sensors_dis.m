clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');

suj_group{1}    = allsuj(2:15,1);
suj_group{2}    = allsuj(2:15,2);

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        list_ix_cue    = {''};
        
        for ncue = 1:length(list_ix_cue)
            
            suj                 = suj_list{sb};
            fname_in            = ['../data/' suj '/field/' suj '.' list_ix_cue{ncue} 'DIS.waveletPOW.40t150Hz.m1000p1000.AvgTrials.mat'];
            
            fprintf('Loading %s\n',fname_in);
            
            load(fname_in)
            
            if isfield(freq,'check_trialinfo')
                freq = rmfield(freq,'check_trialinfo');
            end
            
            tmp{1}              = freq; clear freq ;
            
            fname_in            = ['../data/' suj '/field/' suj '.' list_ix_cue{ncue} 'fDIS.waveletPOW.40t150Hz.m1000p1000.AvgTrials.mat'];
            
            fprintf('Loading %s\n',fname_in);
            
            load(fname_in)
            
            if isfield(freq,'check_trialinfo')
                freq = rmfield(freq,'check_trialinfo');
            end
            
            tmp{2}  = freq; clear freq ;
            
            cfg                          = [];
            cfg.parameter                = 'powspctrm';
            cfg.operation                = 'x1-x2';
            allsuj_data{ngroup}{sb,ncue} = ft_math(cfg,tmp{1},tmp{2});
            
        end
    end
end

clearvars -except allsuj_*;

[~,neighbours]                  = h_create_design_neighbours(length(allsuj_data{1}),allsuj_data{1}{1},'meg','t'); clc;

cfg                             = [];
cfg.statistic                   = 'indepsamplesT';
cfg.method                      = 'montecarlo';
cfg.correctm                    = 'cluster';
cfg.clusteralpha                = 0.05;
cfg.clusterstatistic            = 'maxsum';
cfg.tail                        = 0;
cfg.clustertail                 = 0;
cfg.alpha                       = 0.025;
cfg.numrandomization            = 1000;
cfg.neighbours                  = neighbours;
nsubj                           = 14;
cfg.design                      = [ones(1,nsubj) ones(1,nsubj)*2];
cfg.ivar                        = 1;
cfg.minnbchan                   = 2;
cfg.frequency                   = [60 100];
cfg.latency                     = [-0.1 0.6];

% cfg.avgovertime                 = 'yes';
% cfg.avgoverfreq                 = 'yes';

for ncue = 1:size(allsuj_data{1},2)
    stat{ncue}                    = ft_freqstatistics(cfg, allsuj_data{2}{:,ncue}, allsuj_data{1}{:,ncue}); % young minus control
    [min_p(ncue), p_val{ncue}]    = h_pValSort(stat{ncue}) ;
end

for ncue = 1:length(stat)
    
    figure;
    
    plimit                  = 0.14;
    stat2plot               = h_plotStat(stat{ncue},0.00001,plimit);
    zlimit                  = 0.1;
    
    cfg                     = [];
    cfg.layout              = 'CTF275.lay';
    cfg.zlim                = [-zlimit zlimit];
    cfg.marker              = 'off';
    cfg.comment             = 'no';
    ft_topoplotTFR(cfg,stat2plot);
    %     ft_singleplotTFR(cfg,stat2plot);
    
end