clear ; clc ; dleiftrip_addpath ;

for sb = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))];
    
    clist           = {'bsl','actv'};
    
    for t = 1:length(clist)
        load(['../data/tfr/' suj '.CnD.plvPrimer.' clist{t} '.mat']);
        data_carr{t}    = coh; clear coh ;
    end
    
    template                = data_carr{1};
    %     pow                     = (data_carr{2}.plvspctrm - data_carr{1}.plvspctrm) ./ data_carr{1}.plvspctrm ;
    %     pow                     = (data_carr{2}.plvspctrm - data_carr{1}.plvspctrm);
    
    allsuj(sb,1,:,:,:) = data_carr{1}.plvspctrm;
    allsuj(sb,2,:,:,:) = data_carr{2}.plvspctrm;

    clear data_carr pow;
    
end

clearvars -except allsuj template

for cnd = 1:2
    gavg{cnd}                    = template;
    gavg{cnd}.plvspctrm          = squeeze(mean(allsuj(:,cnd,:,:,:),1));
end

% cfg                     = [];
% cfg.parameter           = 'plvspctrm';
% cfg.zlim                = [0.05 0.1];
% ft_connectivityplot(cfg, gavg{:});

chn1 = 1;
chn2 = 9;

figure; hold on;
for cnd = 1:2
    plot(gavg{cnd}.freq,squeeze(gavg{cnd}.plvspctrm(chn1,chn2,:)),'LineWidth',4);
    xlim([6 15])
end
legend({'Baseline','Post-Cue'});