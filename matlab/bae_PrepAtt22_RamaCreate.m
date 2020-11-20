clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

% load /media/hesham.elshafei/PAT_MEG2/Fieldtripping/data/yctot/stat/NewSourceDpssStat.mat
% 
% load rama_index.mat ;
% 
% new_reg_list = FindSigClustersWithIndex(stat{1,2},0.1,rama_where,rama_list);

load('../data_fieldtrip/index/allyoungcontrol_p600p1000lowAlpha_bsl_contrast.mat');

new_reg_list    = new_reg_list{1};
rama_list       = {};
i               = 0;

for n = 1:length(new_reg_list)
   
    if new_reg_list{n,2} > 1
       
        i = i + 1;
        
        rama_list{i,1} = new_reg_list{n,1};
        
        if new_reg_list{n,2} > 5
            rama_list{i,2} = new_reg_list{n,4}(1:5,1);
        else
            rama_list{i,2} = new_reg_list{n,4}(1:end,1);
        end
        
    end
end

clearvars -except rama_list new_reg_list

save('../data_fieldtrip/index/allyoungcontrol_p600p1000lowAlpha_bsl_contrast_select.mat','rama_list');