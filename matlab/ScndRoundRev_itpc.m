clear ; clc ;
addpath('/Users/heshamelshafei/fieldtrip/'); ft_defaults;
addpath('DrosteEffect-BrewerMap-b6a6efc/');

global ft_default
ft_default.spmversion = 'spm12';

% [~,suj_list,~]              = xlsread('../../documents/PrepAtt22_PreProcessingIndex.xlsx','A:B');
% suj_list                    = suj_list(2:22,2);
% 
% ilu                         = 0;
% 
% for sb = 1:21
%     
%     suj                     = suj_list{sb};
%     list_cond               = {'DIS','fDIS'};
%     
%     for ncond = 1:length(list_cond)
%         
%         fname                                   = ['/Volumes/hesham_megabup/pat22_fieldtrip_data/' suj '.' list_cond{ncond} '.mat'];
%         fprintf('\nLoading %20s\n',fname);
%         load(fname);
%         
%         tlim                                    =2;
%         
%         cfg                                     = [];
%         cfg.latency                             = [-tlim tlim];
%         cfg.channel                             = {'MLC17', 'MLC25', 'MLF67', 'MLP44', 'MLP45', 'MLP56','MLP57', ...
%             'MLT14', 'MLT15', 'MRF66', 'MRF67', 'MRT13', 'MRT14', 'MRT24'};
%         data_elan                               = ft_selectdata(cfg,data_elan);
%         
%         data                                    = data_elan ; clear data_elan fname;
%         data                                    = h_removeEvoked(data);
%         
%         cfg                                     = [];
%         cfg.method                              = 'wavelet';
%         cfg.output                              = 'fourier'; 
%         cfg.keeptrials                          = 'yes';
%         cfg.width                               = 7;
%         cfg.gwidth                              = 4;
%         cfg.toi                                 = -tlim:0.01:tlim;
%         cfg.foi                                 = 1:120;
%         freq{ncond}                             = ft_freqanalysis(cfg, data);
%         freq{ncond}                             = rmfield(freq{ncond},'cfg');
%         
%     end
%     
%     [phi, itcA, itcB]                           = obob_itc_pbi(freq{1},freq{2});
%     
%     allsuj_phi(sb,:,:,:)                        = phi; clear phi;
%     allsuj_it1(sb,:,:,:)                        = squeeze(itcA); clear itcA;
%     allsuj_it2(sb,:,:,:)                        = squeeze(itcB); clear itcB;
%     
%     template.freq                               = freq{1}.freq;
%     template.time                               = freq{1}.time;
%     template.dimord                             = 'chan_freq_time';
%      
% end
% 
% clearvars -except allsuj_* template;

load ../../data/scnd_round/itc_kit_with_evoked.mat

meanPHI             = nanmean(squeeze(nanmean(allsuj_phi,1)),1);

dataplot            = template;
dataplot.label      = {'avg'};
dataplot.powspctrm  = meanPHI;

cfg                 = [];
cfg.xlim            = [0 0.3];
cfg.ylim            = [20 120];
zlim                = 0.002;
cfg.zlim            = [-zlim zlim];
subplot(2,2,1);
ft_singleplotTFR(cfg,dataplot);
title('');