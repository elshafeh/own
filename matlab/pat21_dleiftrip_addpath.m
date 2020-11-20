% if ismac
%     st_dir = '/Volumes/PAT_MEG/Fieldtripping/';
% else 
%     st_dir = '/media/hesham.elshafei/PAT_MEG/Fieldtripping/';
% end

addpath(genpath(['../fieldtrip-20151124/']));
rmpath(['../fieldtrip-20151124/external/spm8']);
rmpath(['..//fieldtrip-20151124/external/spm2']);

clear stdir