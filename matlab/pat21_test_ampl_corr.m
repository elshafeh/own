clear ; clc ; dleiftrip_addpath ;

for sb = 1:14;
    
    suj_list                    = [1:4 8:17];
    suj                         = ['yc' num2str(suj_list(sb))];
    
    fprintf('Loading %s\n',suj);
    load(['../data/all_data/' suj '.CnD.RamaBigCov.mat'])
    
    data = virtsens;
    
    cfg             = [];
    cfg.method      = 'mtmconvol';
    cfg.channel     = 88;
    cfg.output      = 'pow';
    cfg.taper       = 'hanning';
    cfg.foi         = 2:2:60;
    cfg.toi         = data.time{1}(1800:2400);
    cfg.t_ftimwin   = 4./cfg.foi;
    cfg.keeptrials  = 'yes';
    freq            = ft_freqanalysis(cfg,data);
    
    cfg = [];
    cfg.covariance         = 'yes';
    cfg.keeptrials         = 'no';
    cfg.removemean         = 'yes';
    timelock               = ft_timelockanalysis(cfg,freq);
    freqlabel              = round(freq.freq);
    
    %     figure; imagesc(freqlabel,freqlabel,timelock.cov)
    %     title('covariance')
    %     colorbar
    %     axis xy
    
    % calculate correlation
    
    cov             = timelock.cov; % all trials
    d               = sqrt(diag(cov)); % SD, diagonal is variance per channel
    r_value(sb,:,:) = cov ./ (d*d');
    %     figure;
    %     imagesc(freqlabel,freqlabel,r,[0 1])
    %     title('correlation')
    %     colorbar
    %     axis xy
    
end

clearvars -except r_value

figure;
imagesc(2:2:60,2:2:60,squeeze(mean(r_value,1)),[0 2])
title('correlation')
colorbar
axis xy









% figure;
% imagesc(freq.time, freq.freq, squeeze(freq.powspctrm(1,1,:,:))); axis xy
%
% x1 = find(round(freq.freq)==8);
% x2 = find(round(freq.freq)==12);
% x3 = find(round(freq.freq)==24);
% x4 = find(round(freq.freq)==40);
%
% pow = squeeze(mean(freq.powspctrm,1));
%
% figure; plot(freq.time,squeeze(mean(pow(x1:x2,:),1)))   % at 6 Hz
% hold on
% plot(freq.time,squeeze(mean(pow(x3:x4,:),1)),'r')      % at 20 Hz
% hold on
% legend('power at 9 Hz','power at 26 Hz','location','Best')

% calculate covariance with ft_timelockanalysis




% cfg             = [];
% cfg.channel     = 88;
% cfg.hilbert     = 'abs';
% cfg.bpfilt      = 'yes';
% cfg.bpfreq      = [7 15];
% a_bp            = ft_preprocessing(cfg,virtsens);
% a_bp.label      = {'low'};
% cfg.bpfreq      = [18 49];
% b_bp            = ft_preprocessing(cfg,virtsens);
% b_bp.label      = {'high'};
%
% data_bp = ft_appenddata([], a_bp, b_bp);
% figure
% plot(data_bp.time{1}, data_bp.trial{1}); legend(data_bp.label)
% xlim([-0.2 1.2]);
%
% % cfg             = [];
% % cfg.method      = 'mtmfft';
% % cfg.output      = 'powandcsd';
% % cfg.taper       = 'hanning';
% % cfg.channel     = [88 89];
% % cfg.foilim      = [1 40];
% % cfg.keeptrials  = 'no';
% % freq            = ft_freqanalysis(cfg, virtsens);
% %
% %
% % a               = squeeze(nw.powspctrm(1,:)');
% % b               = squeeze(nw.powspctrm(2,:)');
% % [xc,lags]       = xcorr(a,b,'coeff');
% %
% % stem(lags*0.001,xc);