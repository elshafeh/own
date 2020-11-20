clear ; clc ;

% [~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');
%
% suj_group{1}    = allsuj(2:15,1);
% suj_group{2}    = allsuj(2:15,2);
% suj_group{3}    = allsuj(16:end,1);
% suj_group{4}    = allsuj(16:end,2);
% lst_group       = {'Old','Young','Patients','Controls'};

[~,suj_group{1},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_group{1}        = suj_group{1}(2:22);

for ngrp = 1:length(suj_group)
    
    suj_list = suj_group{ngrp};
    
    for sb = 1:length(suj_list)
        
        list_cue                        = {'RnDT','NLnDT'};
        
        suj                             = suj_list{sb};
        
        for ncue = 1:length(list_cue)
            
            fname_in                    = ['../data/' suj '/field/' suj '.' list_cue{ncue} '.bpOrder2Filt0.5t20Hz.pe.mat'];
            fprintf('Loading %s\n',fname_in);
            load(fname_in);
            
            cfg                         = [];
            cfg.baseline                = [-0.1 0];
            allsuj_data{ngrp}{sb,ncue}  = ft_timelockbaseline(cfg,data_pe);
            
        end
        
        clear data_pe
        
    end
    
    %     gavg_data{ngrp} = ft_timelockgrandaverage([],allsuj_data{ngrp}{:});
    
end

clearvars -except *_data

right_cue       = ft_timelockgrandaverage([],allsuj_data{:}{:,1});
left_cue        = ft_timelockgrandaverage([],allsuj_data{:}{:,2});

cfg             = [];
cfg.layout      = 'CTF275.lay';
cfg.xlim        = [0.07 1.7];
cfg.zlim        = [-30 30];
subplot(1,2,1)
ft_topoplotER(cfg,right_cue)
subplot(1,2,2)
ft_topoplotER(cfg,left_cue)

chan_list{1}    = {'MLO14', 'MLP35', 'MLP44', 'MLP45', 'MLP55', 'MLP56', 'MLP57', 'MLT14', 'MLT15', 'MLT16', 'MLT26', 'MLT27'};
chan_list{2}    = {'MRC17', 'MRF67', 'MRP56', 'MRP57', 'MRT13', 'MRT14', 'MRT15', 'MRT24', 'MRT25'};

for nchan = 1:2
    
    subplot(1,2,nchan)
    
    cfg             = [];
    cfg.xlim        = [-0.1 0.35];
    cfg.ylim        = [-150 150];
    cfg.channel     = chan_list{nchan};
    ft_singleplotER(cfg,right_cue,left_cue);
   
    legend({'right','left'})
    
end

% cfg             = [];
% cfg.layout      = 'CTF275.lay';
% cfg.xlim        = -0.2:0.2:1.2;
% cfg.zlim        = [-25 25];
% for ngrp = 1:2
%     figure;
%     ft_topoplotER(cfg,gavg_data{ngrp})
% end
