clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

load ../data_fieldtrip/stat/young_old_gamma_nDT.mat

stat = stat{1};

zlimit                  = 0.1;
plimit                  = 0.1;
stat2plot               = h_plotStat(stat,0.00001,plimit);

cfg         = [];
cfg.layout  = 'CTF275.lay';
cfg.zlim    = [-zlimit zlimit];
cfg.marker  = 'off';
ft_topoplotER(cfg,stat2plot);

chan_group{1} = {'MLC13', 'MLC21', 'MLC22', 'MLC31', 'MLC41', 'MLC51', 'MLC52', 'MLC53', 'MLC61', 'MLC62', 'MZC02', 'MZC03'};
chan_group{2} = {'MLC11', 'MLC12', 'MLC13', 'MLC14', 'MLC15', 'MLC16', 'MLC17', 'MLC21', 'MLC22', 'MLC23', 'MLC24', 'MLC25', ...
    'MLC31', 'MLC32', 'MLC41', 'MLC42', 'MLC51', 'MLC52', 'MLC53', 'MLC54', 'MLC55', 'MLC61', 'MLC62', 'MLC63', 'MLF14', 'MLF24', ...
    'MLF25', 'MLF32', 'MLF33', 'MLF34', 'MLF35', 'MLF41', 'MLF42', 'MLF43', 'MLF44', 'MLF45', 'MLF46', 'MLF51', 'MLF52', 'MLF53', ...
    'MLF54', 'MLF55', 'MLF56', 'MLF61', 'MLF62', 'MLF63', 'MLF64', 'MLF65', 'MLF66', 'MLF67', 'MLP11', 'MLP12', 'MLP21', 'MLP22',...
    'MLP23', 'MLP31', 'MLP32', 'MLP33', 'MLP34', 'MLP35', 'MLP42', 'MLP43', 'MLP44', 'MLP45', 'MLP55', 'MLP56', 'MLP57', 'MLT11', ...
    'MLT12', 'MLT13', 'MLT14', 'MLT15', 'MLT16', 'MLT21', 'MLT22', 'MLT23', 'MLT24', 'MLT25', 'MLT31', 'MLT32', 'MLT33', 'MLT34', ...
    'MLT35', 'MLT41', 'MLT42', 'MLT43', 'MLT44', 'MLT51', 'MLT52', 'MLT53', 'MRC51', 'MRC61', 'MRC63', 'MRP21', 'MZC01', 'MZC02', 'MZC03', 'MZC04', 'MZF03'};

figure ; 
i = 0 ;

for nchan = 1:2
   
    cfg             = [];
    cfg.channel     = chan_group{nchan};
    cfg.avgoverchan = 'yes';
    nw_data         = ft_selectdata(cfg,stat2plot);
    
    i = i +1 ;
    
    subplot(2,2,i)
    plot(nw_data.freq,squeeze(mean(nw_data.powspctrm,3)));
    xlim([nw_data.freq(1) nw_data.freq(end)])
    
    
    i = i +1 ;
    
    subplot(2,2,i)
    plot(nw_data.time,squeeze(mean(nw_data.powspctrm,2)));
    xlim([nw_data.time(1) nw_data.time(end)])
    
end

% clear ; clc ; dleiftrip_addpath ;
%
% suj_list = [1:4 8:17];
%
% for sb = 1:length(suj_list)
%
%     suj         = ['yc' num2str(suj_list(sb))];
%     fname_in    = ['/Volumes/Pat22Backup/meg21_fieldtrip_data_backup/data/all_data/' suj ...
%         '.CnD.MaxAudVizMotor.BigCov.VirtTimeCourse.KeepTrial.wav.1t20Hz.m3000p3000..mat'];
%
%     load(fname_in);
%
%     freq                = ft_freqdescriptives([],freq);
%
%     cfg                 = [];
%     cfg.baseline        = [-0.6 -0.2];
%     cfg.baselinetype    = 'relchange';
%     freq                = ft_freqbaseline(cfg,freq);
%
%     cfg                 = [];
%     cfg.frequency       = [7 15];
%     cfg.avgoverchan     = 'yes';
%     cfg.channel         = 2:4;
%     tmp{sb,1}           = ft_selectdata(cfg,freq);
%     cfg.channel         = 1:2;
%     tmp{sb,2}           = ft_selectdata(cfg,freq);
%
%     clearvars -except tmp suj_list sb
%
% end