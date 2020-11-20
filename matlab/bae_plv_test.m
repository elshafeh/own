clear ; clc ; 

eegData                 = rand(28, 1000, 231);
srate                   = 500; %Hz
filtSpec.order          = 50;
filtSpec.range          = [35 45]; %Hz
dataSelectArr           = rand(231, 1) >= 0.5; % attend trials
dataSelectArr(:, 2)     = ~dataSelectArr(:, 1); % ignore trials

[plv] = pn_eegPLV(eegData, srate, filtSpec, dataSelectArr);

figure; plot((0:size(eegData, 2)-1)/srate, squeeze(plv(:, 17, 20, :)));
xlabel('Time (s)'); ylabel('Plase Locking Value');
