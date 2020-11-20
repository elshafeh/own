clear; clc;

mat_name  = '/Users/heshamelshafei/GoogleDrive/PhD/Fieldtripping/data/ageing_data/yc1.CnD.AV.1t20Hz.M.1t40Hz.m800p2000msCov.mat';

load(mat_name);

fname_out = '/Users/heshamelshafei/GoogleDrive/PhD/Fieldtripping/data/data4python.mat';

h_field2py(virtsens,fname_out)