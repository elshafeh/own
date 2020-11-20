clear; clc ; dleiftrip_addpath ;

for sb = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))];
    
    ext_essai   = '.m1000p2000.1t100Hz.itc.mat';
    
    fname_in = [suj ext_essai];
    fprintf('\nLoading %50s \n\n',fname_in);
    load(['../data/tfr/' fname_in]);
    
    avg_itpc(sb,:,:,:) = itc.itpc;
    avg_itlc(sb,:,:,:) = itc.itlc;

    if sb ==14
        
        gavg_itc        = itc;
        gavg_itc.itpc   = squeeze(mean(avg_itpc,1));
        gavg_itc.itlc   = squeeze(mean(avg_itpc,1));
        
    end
    
    clear itc ;
    
    
end

clearvars -except gavg_itc

figure
subplot(2, 1, 1);
imagesc(gavg_itc.time, gavg_itc.freq, squeeze(gavg_itc.itpc(1,:,:)));
axis xy
title('inter-trial phase coherence');
ylim([4 15])
zlim([0 0.25])
subplot(2, 1, 2);
imagesc(gavg_itc.time, gavg_itc.freq, squeeze(gavg_itc.itpc(1,:,:)));
axis xy
title('inter-trial phase coherence');
ylim([50 100])
zlim([0 0.25])



% subplot(2, 1, 2);
% imagesc(gavg_itc.time, gavg_itc.freq, squeeze(gavg_itc.itlc(1,:,:)));
% axis xy
% title('inter-trial linear coherence');
% ylim([4 15])