clear ; clc ; dleiftrip_addpath ;

load ../data/template/source_struct_template_MNIpos.mat  

new_source.pos = source.pos ;

new_source.pow      = source.avg.pow;
new_source.pow(:)           = 0 ;

indx        = h_createIndexfieldtrip;

roi         = 79:82;

for n = 1:length(roi)
    new_source.pow(indx(indx(:,2)==roi(n),1)) = n*10;
end

clearvars -except new_source; 

save /Users/heshamelshafei/source_for_python.mat;
