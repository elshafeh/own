function [currentThresh] = ade_pre_staircase_calcul(P,Info,currentThresh,TrialCount)

% basically this sets the threshold of the following of trial
% if it's it's STARTING THRESHOLD
% also for visual stimuli SNR does not go below zero

if TrialCount == 1
    currentThresh(TrialCount)     = P.StartingThreshold;
end

if strcmp(Info.modality,'vis') && currentThresh(TrialCount) < 0
    currentThresh(TrialCount) = 0;
end