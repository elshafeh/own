clear ; clc ;

[~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');

suj_group{1}    = allsuj(2:15,1);
suj_group{2}    = allsuj(2:15,2);
suj_group{3}    = allsuj(16:end,1);
suj_group{4}    = allsuj(16:end,2);
lst_group       = {'Old','Young','Patients','Controls'};

for ngrp = 1:length(suj_group)
    
    suj_list = suj_group{ngrp};
    
    for sb = 1:length(suj_list)
        
        suj             = suj_list{sb};
        cond_main       = 'CnD';
        fname_in        = ['../data/' suj '/field/' suj '.' cond_main '.bpOrder2Filt0.2t20Hz.pe.mat'];
        fprintf('Loading %s\n',fname_in);
        load(fname_in);
        
        cfg                 = [];
        cfg.baseline        = [-0.1 0];
        allsuj_data{ngrp}{sb}    = ft_timelockbaseline(cfg,data_pe);
        
        clear data_pe
        
    end
    
    gavg_data{ngrp} = ft_timelockgrandaverage([],allsuj_data{ngrp}{:});
    
end

clearvars -except *_data

cfg             = [];
cfg.layout      = 'CTF275.lay';
cfg.xlim        = [0.6 1.1];
cfg.zlim        = [-50 50];
ft_topoplotER(cfg,gavg_data{1:2})

% cfg             = [];
% cfg.layout      = 'CTF275.lay';
% cfg.xlim        = -0.2:0.2:1.2;
% cfg.zlim        = [-25 25];
% for ngrp = 1:2
%     figure;
%     ft_topoplotER(cfg,gavg_data{ngrp})
% end
