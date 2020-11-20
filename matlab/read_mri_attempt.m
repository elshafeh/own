clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));


fname = '/Users/heshamelshafei/GoogleDrive/PhD/Fieldtripping/patient_mri/p12/images/*';

mri = ft_read_mri(fname,'dataformat','dicom')