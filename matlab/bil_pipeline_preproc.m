% Hesham's pipeline to (pre-)process data for the Oscillatory building
% blocks project

% [1] bil_preproc_ds2mat: 
% reads in data locked to first cue
% this downsamples data/saves them in single precision + bandstop filter
% adds in behavioral information 
% adds in timestamps of all other events

% [2] bil_preproc_firstReject:
% check four outlier channel/trials and for sensor jumps

% [3] bil_preproc_icaCompute / bil_preproc_icaClean:
% compute ICA and remove EO/CG artefacts

% [4] bil_preproc_secondReject:
% check AGAIN four outlier channel/trials + muscle artefacts