clear; clc ; 

filename_in = '~/GoogleDrive/PhD/Fieldtripping/data/paper_data/yc14.CnD.MaxAudVizMotor.BigCov.VirtTimeCourse.mat';
filename_out = '~/GoogleDrive/PhD/Fieldtripping/data/mne_data/yc14.CnD.MaxAudVizMotor.BigCov.VirtTimeCourse.fif';

load(filename_in);

fieldtrip2fiff(filename_out,virtsens)