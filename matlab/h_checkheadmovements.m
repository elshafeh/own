function [maxposchange] = h_checkheadmovements(headpos)

% Based on the fieldtrip tutorial
% http://www.fieldtriptoolbox.org/example/how_to_incorporate_head_movements_in_meg_analysis/

ntrials         = length(headpos.trial);

for t = 1:ntrials
    coil1(:,t)  = [mean(headpos.trial{1,t}(1,:)); mean(headpos.trial{1,t}(2,:)); mean(headpos.trial{1,t}(3,:))];
    coil2(:,t)  = [mean(headpos.trial{1,t}(4,:)); mean(headpos.trial{1,t}(5,:)); mean(headpos.trial{1,t}(6,:))];
    coil3(:,t)  = [mean(headpos.trial{1,t}(7,:)); mean(headpos.trial{1,t}(8,:)); mean(headpos.trial{1,t}(9,:))];
end

% calculate the headposition and orientation per trial (for function see bottom page)
cc              = circumcenter(coil1, coil2, coil3);
cc_rel          = [cc - repmat(cc(:,1),1,size(cc,2))]';

% plot translations
subplot(2,1,1);
plot(cc_rel(:,1:3)*1000) % in mm
title('translations');

% plot rotations
subplot(2,1,2);
plot(cc_rel(:,4:6))
title('rotations');

maxposchange = max(abs(cc_rel(:,1:3)*1000)); % in mm