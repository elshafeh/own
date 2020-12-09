% Hesham's pipeline to (pre-)process data for TACO project


%% [1] reads in data locked to first cue
taco_preproc_ds2mat;

%% [2] check four outlier channel/trials and for sensor jumps
taco_preproc_firstReject;

%% [3] compute ICA and remove EO/CG artefacts
taco_preproc_icaCompute;
taco_preproc_icaClean;

%% [4] check AGAIN four outlier channel/trials + muscle artefacts
taco_preproc_secondReject;
